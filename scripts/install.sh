#!/usr/bin/env bash
#
# install.sh
#
# Wipe and partition the target drive with disko, then install
# nixosConfigurations.<hostname> from the current repository.
#
# Usage: ./install.sh

set -o errexit
set -o nounset
set -o pipefail

cat <<'Introduction'

This script wipes the target drive with disko, generates
_hardware-configuration.nix without filesystem, and installs NixOS with
preservation enabled. A copy of the updated repository will be placed at
/persist/$HOME/nix-config after installation.

** BEFORE YOU RUN THIS **
  - The host public key must be listed in modules/common/sops/.sops.yaml,
    with all relevant secret files (including the user password) re-keyed
    to it. The matching private key (ssh_host_ed25519_key) must also exist on
    this ISO (default: /tmp/ssh_host_ed25519_key).
  - nixosConfigurations.<hostname> must exist and define the target disk(s)
    in its disko config.
  - The host's config must already import _hardware-configuration.nix. The
    script generates the file, but it does not add the import line.

** NOTE **
Only x86_64-linux is supported. A binary cache for disko is not guaranteed
on other platforms, which can force a build from source and exhaust memory
on low-memory systems.

** WARNING **
Disko will DESTROY ALL DATA on the target disk(s) unless you choose to
mount an existing layout instead. You will be asked for confirmation before
any disk is wiped.

Introduction

# ---------------------------------------------------------------- settings --
REPO_URL="${REPO_URL:-https://github.com/xuwyn/nix-config.git}"
REPO_DIR="${REPO_DIR:-$HOME/nix-config}"
REPO_BRANCH="${REPO_BRANCH:-}" # empty = remote default branch

# Where a host's files live in the repo (relative to repo root, %s = hostname).
HOST_DIR_FMT="${HOST_DIR_FMT:-modules/hosts/%s}"

# Pre-generated host private key (scp'd or copied from USB onto the ISO).
KEY_SRC="${KEY_SRC:-/tmp/ssh_host_ed25519_key}"

# Name of the LUKS mapper in disko (used to close it before and after)
MAPPER_NAME="cryptroot"

NIX_FEATURES="nix-command flakes pipe-operators"
export NIX_CONFIG="experimental-features = $NIX_FEATURES"

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
  git -C "$REPO_DIR" fetch origin
  if [[ -n "$REPO_BRANCH" ]]; then
    git -C "$REPO_DIR" checkout "$REPO_BRANCH"
  fi
  git -C "$REPO_DIR" pull --ff-only
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

# ---------------------------------------------------- generate hardware config --
echo "Generating hardware-configuration.nix"
nixos-generate-config --no-filesystems --show-hardware-config >"$HOST_DIR/_hardware-configuration.nix"
git -C "$REPO_DIR" add -f "$HOST_DIR/_hardware-configuration.nix"

nix eval "$REPO_DIR#nixosConfigurations.$HOST.config.system.build.toplevel.drvPath" >/dev/null

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

# ------------------------------------------------------------------ disko ----
# Make sure nothing from an earlier run is still mounted
sudo swapoff -a || true
sudo umount -R /mnt 2>/dev/null || true
sudo cryptsetup close "$MAPPER_NAME" 2>/dev/null || true

echo
echo "Disks defined for $HOST in the disko config:"
nix eval --raw "$REPO_DIR#nixosConfigurations.$HOST.config.disko.devices.disk" \
  --apply 'd: builtins.concatStringsSep "\n" (map (x: x.device) (builtins.attrValues d))' ||
  echo "(could not read the disk list from the config)"
echo

if yesno "Skip formatting and only mount an existing disko layout?"; then
  DISKO_MODE="mount"
else
  echo "!! Disko will WIPE the disk(s) listed above !!"
  yesno "Continue?" || {
    echo "Aborting."
    exit 1
  }
  DISKO_MODE="destroy,format,mount"
fi

# Disko asks for the LUKS passphrase itself
sudo nix --experimental-features "$NIX_FEATURES" \
  run github:nix-community/disko -- --mode "$DISKO_MODE" --flake "$REPO_DIR#$HOST"

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
sudo rm -rf "/mnt/persist/home/$USERNAME/nix-config"
sudo cp -a "$REPO_DIR" "/mnt/persist/home/$USERNAME/nix-config"
# The user doesn't exist on the ISO, so use numeric uid:gid (1000:users=100)
sudo chown -R 1000:100 "/mnt/persist/home/$USERNAME"

cat <<EOF

Installation complete.

Repo copied to /persist/home/$USERNAME/nix-config.
Don't forget to commit ${HOST_DIR_FMT//%s/$HOST}/_hardware-configuration.nix
EOF
echo

if yesno "Unmount and reboot into firmware setup now?"; then
  sudo swapoff -a || true
  sudo umount -R /mnt
  sudo cryptsetup close "$MAPPER_NAME" || true
  systemctl reboot --firmware-setup
fi
