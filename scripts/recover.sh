#!/usr/bin/env bash
#
# recover.sh
#
# Recover a btrfs+LUKS+preservation NixOS externally
# without reformatting or destroying any data in /persist.
# This only works if the keys to decrypt user password
# are still intact in /persist.
#
# Use this script for cases like boot freezes and/or
# user environment being inaccessible to run nixos-rebuild

set -o errexit
set -o nounset
set -o pipefail

DEFAULT_FLAKE="github:xuwyn/nix-config"
DEFAULT_MAPPER_NAME="cryptroot"

# Mounting order matters: parent dirs before children
declare -A SUBVOLS=(
  [root]="/"
  [nix]="/nix"
  [persist]="/persist"
)

function yesno() {
  local prompt="$1"
  while true; do
    read -rp "$prompt [y/n] " yn
    case $yn in
    [Yy]*)
      echo "y"
      return
      ;;
    [Nn]*)
      echo "n"
      return
      ;;
    *) echo "Please answer yes or no." >&2 ;;
    esac
  done
}

function require_root_priv() {
  if [[ $EUID -eq 0 ]]; then
    echo "Don't run this as root directly -- it calls sudo where needed." >&2
    exit 1
  fi
}

function check_nixos_install_tools() {
  if command -v nixos-install &>/dev/null; then
    return
  fi
  echo "nixos-install not found on this system!"

  if [[ "$0" == /proc/self/fd/* || "$0" == /dev/fd/* ]]; then
    echo "To run this script as a one-liner, please wrap it in a nix shell like this:"
    echo
    echo "  nix shell nixpkgs#nixos-install-tools --command bash <(curl -L <script-url>)"
    echo
    exit 1
  fi

  echo "Start a nix shell with nixos-install-tools."
  exec nix shell nixpkgs#nixos-install-tools --command bash "$0"
}

function select_disk_partitions() {
  echo "Current block devices:"
  lsblk -f
  echo

  read -rp "Enter the /boot (ESP) partition (e.g. /dev/sda1): " BOOTDISK
  read -rp "Enter the LUKS-encrypted root partition (e.g. /dev/sda2): " LUKSDISK

  if [[ ! -b "$BOOTDISK" ]]; then
    echo "Error: $BOOTDISK is not a block device." >&2
    exit 1
  fi
  if [[ ! -b "$LUKSDISK" ]]; then
    echo "Error: $LUKSDISK is not a block device." >&2
    exit 1
  fi
}

function open_luks() {
  local mapper_name
  read -rp "Mapper name to use (default: $DEFAULT_MAPPER_NAME): " mapper_name
  mapper_name="${mapper_name:-$DEFAULT_MAPPER_NAME}"

  if [[ -e "/dev/mapper/$mapper_name" ]]; then
    echo "Mapper /dev/mapper/$mapper_name already open, reusing."
  else
    echo "Decrypting $LUKSDISK -> /dev/mapper/$mapper_name"
    sudo cryptsetup luksOpen "$LUKSDISK" "$mapper_name"
  fi

  MAPPER_DEV="/dev/mapper/$mapper_name"
}

function mount_subvols() {
  echo "Mounting btrfs subvolumes"

  # root first, since everything else nests under /mnt
  sudo mkdir -p /mnt
  sudo mount -o subvol=root "$MAPPER_DEV" /mnt

  for subvol in "${!SUBVOLS[@]}"; do
    [[ "$subvol" == "root" ]] && continue
    local mountpoint="/mnt${SUBVOLS[$subvol]}"
    sudo mkdir -p "$mountpoint"
    sudo mount -o "subvol=$subvol" "$MAPPER_DEV" "$mountpoint"
  done

  sudo mkdir -p /mnt/boot
  sudo mount "$BOOTDISK" /mnt/boot
}

function restore_secrets() {
  echo "Restoring host identity/secrets so nixos-install can find them"

  if [[ -d /mnt/persist/etc/ssh ]]; then
    sudo cp -r /mnt/persist/etc/ssh /mnt/etc/
  else
    echo "  (no /persist/etc/ssh found, skipping)" >&2
  fi

  if [[ -f /mnt/persist/etc/machine-id ]]; then
    sudo cp /mnt/persist/etc/machine-id /mnt/etc/
  else
    echo "  (no /persist/etc/machine-id found, skipping)" >&2
  fi
}

function github_ref_to_clone_url() {
  local ref="$1"
  if [[ "$ref" == github:* ]]; then
    echo "https://github.com/${ref#github:}.git"
  else
    echo "$ref"
  fi
}

function fetch_flake_with_lfs() {
  local git_url="$1" rev="$2" clone_dir="$3"

  echo "Cloning $git_url @ $rev to fetch real git-lfs content"

  rm -rf "$clone_dir"

  nix shell nixpkgs#git nixpkgs#git-lfs --command git clone "$git_url" "$clone_dir"
  (
    cd "$clone_dir"
    nix shell nixpkgs#git nixpkgs#git-lfs --command git checkout "$rev"
    nix shell nixpkgs#git nixpkgs#git-lfs --command git lfs pull
    rm -rf "$clone_dir/.git"
  )
}

function run_rebuild() {
  local flake_ref host git_rev flake_uri use_lfs git_url clone_dir

  read -rp "Enter flake path/URL (default: $DEFAULT_FLAKE): " flake_ref
  flake_ref="${flake_ref:-$DEFAULT_FLAKE}"

  read -rp "Enter hostname to install (e.g. mango): " host
  if [[ -z "$host" ]]; then
    echo "Error: hostname is required." >&2
    exit 1
  fi

  if [[ "$flake_ref" == /* || "$flake_ref" == .* ]]; then
    # relative path to flake on local host
    # assume LFS content checked out, so no LFS handling needed
    flake_uri="${flake_ref}#${host}"
  else
    # flake on remote repo
    read -rp "Enter git branch, tag, or commit to checkout (default: main): " git_rev
    git_rev="${git_rev:-main}"

    use_lfs=$(yesno "Does this flake need git-lfs objects fetched?")
    if [[ "$use_lfs" == "y" ]]; then
      git_url=$(github_ref_to_clone_url "$flake_ref")
      clone_dir="/tmp/nix-config-lfs"
      fetch_flake_with_lfs "$git_url" "$git_rev" "$clone_dir"
      flake_uri="${clone_dir}#${host}"
    else
      flake_uri="${flake_ref}/${git_rev}#${host}"
    fi
  fi

  echo "Rebuilding: $flake_uri"
  sudo env "PATH=$PATH" nixos-install \
    --root /mnt \
    --flake "$flake_uri" \
    --no-root-password
}

function main() {
  require_root_priv

  echo "================ NixOS btrfs/LUKS recovery ================"
  echo

  check_nixos_install_tools
  select_disk_partitions
  open_luks
  mount_subvols
  restore_secrets
  run_rebuild

  echo
  echo "Rebuild complete."
  local uefi_reboot
  uefi_reboot=$(yesno "Reboot now?")
  if [[ "$uefi_reboot" == "y" ]]; then
    sudo systemctl reboot --firmware-setup
  fi
}

main "$@"
