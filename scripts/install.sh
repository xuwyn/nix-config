#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# ---------------------------------------------------------------- settings --
REPO_URL="${REPO_URL:-https://github.com/xuwyn/nix-config.git}"
REPO_DIR="${REPO_DIR:-$HOME/nix-config}"
REPO_BRANCH="${REPO_BRANCH:-}" # empty = remote default branch

# Where a host's files live in the repo (relative to repo root, %s = hostname).
HOST_DIR_FMT="${HOST_DIR_FMT:-modules/hosts/%s}"

# Pre-generated host private key (scp'd or copied from USB onto the ISO).
KEY_SRC="${KEY_SRC:-/tmp/ssh_host_ed25519_key}"

BOOT_LABEL="NIXBOOT"       # FAT32 filesystem label
LUKS_PARTLABEL="cryptroot" # GPT partition label (/dev/disk/by-partlabel/...)
MAPPER_NAME="cryptroot"    # /dev/mapper/<name>
BTRFS_LABEL="nixos"

export NIX_CONFIG="experimental-features = nix-command flakes pipe-operators"

yesno() {
  local prompt="$1" yn
  while true; do
    read -rp "$prompt [y/n] " yn
    case $yn in
    [Yy]*) return 0 ;;
    [Nn]*) return 1 ;;
    *) echo "Please answer yes or no." ;;
    esac
  done
}

prompt_secret() { # prompt_secret "label" VARNAME
  local a b
  while true; do
    read -rsp "$1: " a
    echo
    read -rsp "Repeat $1: " b
    echo
    if [[ -n "$a" && "$a" == "$b" ]]; then
      printf -v "$2" '%s' "$a"
      return
    fi
    echo "Empty or mismatched, try again."
  done
}

cleanup() {
  sudo umount -R /mnt 2>/dev/null || true
  sudo cryptsetup close "$MAPPER_NAME" 2>/dev/null || true
}

[[ -d /sys/firmware/efi ]] || {
  echo "Not booted in UEFI mode, aborting."
  exit 1
}

# ------------------------------------------------------------------- repo ----
if [[ -z "$REPO_BRANCH" ]]; then
  read -rp "Branch to use [repo default]: " REPO_BRANCH
fi

if [[ -d "$REPO_DIR/.git" ]]; then
  echo "Updating existing repo at $REPO_DIR"
  git -C "$REPO_DIR" fetch origin || true
  if [[ -n "$REPO_BRANCH" ]]; then
    git -C "$REPO_DIR" checkout "$REPO_BRANCH"
  fi
  git -C "$REPO_DIR" pull --ff-only || true
else
  if [[ -n "$REPO_BRANCH" ]]; then
    git clone --branch "$REPO_BRANCH" "$REPO_URL" "$REPO_DIR"
  else
    git clone "$REPO_URL" "$REPO_DIR"
  fi
fi

while true; do
  read -rp "Hostname to install: " HOST
  if [[ "$HOST" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*$ ]]; then
    break
  fi
  echo "Invalid hostname (letters, digits and hyphens only)."
done

while true; do
  read -rp "Primary username: " USERNAME
  if [[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
    break
  fi
  echo "Invalid username (lowercase letters, digits, '_' and '-', must not start with a digit or '-', max 32 chars)."
done

HOST_DIR="$REPO_DIR/${HOST_DIR_FMT//%s/$HOST}"
mkdir -p "$HOST_DIR"

# ------------------------------------------------------------ read host key ----
while true; do
  read -rep "Path to host private key [$KEY_SRC]: " key_input
  key_input="${key_input:-$KEY_SRC}"
  key_input="${key_input/#\~/$HOME}" # expand a leading ~
  if [[ -f "$key_input" ]]; then
    KEY_SRC="$key_input"
    break
  fi
  echo "No file at $key_input, try again."
done

# do this to fix permission shenanigan
tmp_key="$(mktemp)"
trap 'rm -f "$tmp_key"' EXIT
install -m 600 "$KEY_SRC" "$tmp_key"
KEY_PUB="$(ssh-keygen -y -f "$tmp_key")"
rm -f "$tmp_key"

# -------------------------------------------------------------- pick disk ----
echo
lsblk -o NAME,SIZE,TYPE,MODEL,TRAN
echo
mapfile -t disks < <(lsblk -dnpo NAME,SIZE,MODEL,TYPE | awk '$NF=="disk"')
((${#disks[@]} > 0)) || {
  echo "No disks found."
  exit 1
}

echo "Available disks:"
for i in "${!disks[@]}"; do
  printf "%d) %s\n" $((i + 1)) "${disks[i]%% disk}"
done

while true; do
  read -rp "Number of the disk to install to: " sel
  if [[ "$sel" =~ ^[0-9]+$ ]] && ((sel >= 1 && sel <= ${#disks[@]})); then
    break
  fi
  echo "Invalid selection."
done
DISK="$(awk '{print $1}' <<<"${disks[sel - 1]}")"

# nvme0n1 / mmcblk0 need a "p" before the partition number, sda / vda don't.
if [[ "$DISK" =~ [0-9]$ ]]; then PART_SEP="p"; else PART_SEP=""; fi
BOOT_PART="${DISK}${PART_SEP}1"
ROOT_PART="${DISK}${PART_SEP}2"

echo
echo "Boot partition: $BOOT_PART"
echo "LUKS partition: $ROOT_PART"
echo
echo "!! The ENTIRE disk $DISK will be wiped !!"
read -rp "Type the disk path again to confirm: " confirm
[[ "$confirm" == "$DISK" ]] || {
  echo "Mismatch, aborting."
  exit 1
}

prompt_secret "LUKS passphrase" LUKS_PASS

# ----------------------------------------------------------- partitioning ----
cleanup
echo "Partitioning $DISK"
sudo swapoff -a || true
sudo wipefs -af "$DISK"
sudo sgdisk --zap-all "$DISK"
sudo sgdisk -n1:1M:+1G -t1:EF00 -c1:"$BOOT_LABEL" "$DISK"
sudo sgdisk -n2:0:0 -t2:8309 -c2:"$LUKS_PARTLABEL" "$DISK"
sudo partprobe "$DISK" || true
sudo udevadm settle
sleep 2

echo "Formatting boot"
sudo mkfs.fat -F 32 -n "$BOOT_LABEL" "$BOOT_PART"

echo "Setting up LUKS"
printf '%s' "$LUKS_PASS" | sudo cryptsetup luksFormat --batch-mode --type luks2 --key-file=- "$ROOT_PART"
printf '%s' "$LUKS_PASS" | sudo cryptsetup open --allow-discards --key-file=- "$ROOT_PART" "$MAPPER_NAME"
unset LUKS_PASS

echo "Creating btrfs"
sudo mkfs.btrfs -f -L "$BTRFS_LABEL" "/dev/mapper/$MAPPER_NAME"
sudo mount "/dev/mapper/$MAPPER_NAME" /mnt
for sv in root nix persist; do
  sudo btrfs subvolume create "/mnt/$sv"
done
sudo umount /mnt

OPTS="compress=zstd,noatime"
sudo mount -o "$OPTS,subvol=root" "/dev/mapper/$MAPPER_NAME" /mnt
sudo mkdir -p /mnt/{boot,nix,persist}
sudo mount -o "$OPTS,subvol=nix" "/dev/mapper/$MAPPER_NAME" /mnt/nix
sudo mount -o "$OPTS,subvol=persist" "/dev/mapper/$MAPPER_NAME" /mnt/persist
sudo mount -o umask=0077 "$BOOT_PART" /mnt/boot

# ---------------------------------------------------- generate hardware config --
echo "Generating hardware-configuration.nix"
nixos-generate-config --no-filesystems --show-hardware-config >"$HOST_DIR/_hardware-configuration.nix"
git -C "$REPO_DIR" add -f "$HOST_DIR/_hardware-configuration.nix"

# ------------------------------------------------- generate identity files --
echo "Installing host key and machine-id in /persist"
sudo mkdir -p /mnt/persist/etc/ssh
sudo install -m 600 -o root -g root "$KEY_SRC" /mnt/persist/etc/ssh/ssh_host_ed25519_key
printf '%s\n' "$KEY_PUB" | sudo tee /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub >/dev/null
sudo chmod 644 /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub

tr -d '-' </proc/sys/kernel/random/uuid | sudo tee /mnt/persist/etc/machine-id >/dev/null
sudo chmod 444 /mnt/persist/etc/machine-id

# not sure if this step is necessary...
sudo mkdir -p /mnt/etc/ssh
sudo cp -a /mnt/persist/etc/ssh/. /mnt/etc/ssh/
sudo cp /mnt/persist/etc/machine-id /mnt/etc/machine-id

# ---------------------------------------------------------------- install ----
echo "Installing NixOS ($HOST)"
sudo nixos-install --root /mnt --flake "$REPO_DIR#$HOST" --no-root-password \
  --option extra-experimental-features "pipe-operators"

# ---------------------------------------------------------- post-install ----
echo "Copying repo to /persist/home/$USERNAME/nix-config"
sudo mkdir -p "/mnt/persist/home/$USERNAME"
sudo cp -a "$REPO_DIR" "/mnt/persist/home/$USERNAME/nix-config"
# The user doesn't exist on the ISO, so use numeric uid:gid (1000:users=100)
sudo chown -R 1000:100 "/mnt/persist/home/$USERNAME"

cat <<EOF

Installation complete.

Repo copied to /persist/home/$USERNAME/nix-config.
Don't forget to commit $HOST_DIR/_hardware-configuration.nix.

EOF

if yesno "Unmount and reboot into firmware setup now?"; then
  sudo umount -R /mnt
  sudo cryptsetup close "$MAPPER_NAME"
  systemctl reboot --firmware-setup
fi
