#!/usr/bin/env bash
#
# deploy-home.sh
#
# Remote deploy script for home manager (standalone) via ssh
#
# Source:  https://github.com/brokenpip3/my-binaries/blob/main/productivity/nix-specific/home-manager-remote/home-manager-remote.sh
#
# Warning: mkOutOfStoreSymlink would NOT work if the target machine doesn't have its own flake.
#          Changes made to those mkOutOfStoreSymlink files cannot be applied via this script.
#
# Changes: Refactor copy_git_to_target() to accept uncommitted changes and remote repo with git-lfs
#          Drop randomized directory name, use /tmp/nix-config instead
#
# Usage:   ./deploy-home.sh <flake_path> <user@host> [--build-on-target]

set +u

log() {
  local user host
  IFS='@' read -r user host <<<"$1"

  if [ -z "$NO_COLOR" ]; then
    echo -e "\033[36m[$(date '+%Y-%m-%d %H:%M:%S')]\033[0m \033[35m$host[$user]\033[0m: $2"
  else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $user at $host: $2"
  fi
}

yesno() {
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

_prepare_temp() {
  local target="$1"
  ssh "$target" "rm -rf /tmp/nix-config && mkdir -p /tmp/nix-config"
  [ $? -ne 0 ] && {
    log "$target" "Failed to create temporary directory."
    exit 1
  }
}

_sshexec() {
  local target="$1"
  local command="$2"
  ssh "$target" "$command"
  [ $? -ne 0 ] && {
    log "$target" "Failed to execute command $command."
    exit 1
  }
}

github_ref_to_clone_url() {
  local ref="$1"
  if [[ "$ref" == github:* ]]; then
    echo "https://github.com/${ref#github:}.git"
  else
    echo "$ref"
  fi
}

copy_source_to_target() {
  local target="$1"
  local flake_path="$2"

  if [[ "$flake_path" == /* || "$flake_path" == .* ]]; then
    log "$target" "Copying local working directory..."
    tar --exclude='.git' -cf - "$flake_path" | ssh "$target" "tar -xmf - -C /tmp/nix-config"
  else
    log "$target" "Remote flake detected!"

    local git_rev
    read -rp "Enter git branch, tag, or commit to checkout (default: main): " git_rev
    git_rev="${git_rev:-main}"

    local use_lfs
    use_lfs=$(yesno "Does this repository need Git LFS objects pulled?")

    local git_url
    git_url=$(github_ref_to_clone_url "$flake_path")

    ssh "$target" "
      export PATH=\$PATH:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin
      git clone '$git_url' /tmp/nix-config &&
      cd /tmp/nix-config &&
      git checkout '$git_rev' &&
      if [ '$use_lfs' = 'y' ]; then
        if command -v git-lfs &>/dev/null; then
          git lfs pull || echo 'Warning: git lfs pull encountered an issue.'
        elif command -v nix &>/dev/null; then
          nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#git-lfs --command git lfs pull || echo 'Warning: nix shell git-lfs failed.'
        else
          echo 'Warning: git-lfs not found and Nix is unavailable to fallback.'
        fi
      fi
    "
  fi

  [ $? -ne 0 ] && {
    log "$target" "Failed to copy source repository. Aborting."
    exit 1
  }
}

local_build_and_copy() {
  local target="$1"
  local flake_path="$2"
  local local_build_output
  log "$target" "Building locally..."
  local_build_output=$(nix build "$flake_path#homeConfigurations.$(_sshexec "$target" 'whoami')@$(_sshexec "$target" "echo \$HOSTNAME").activationPackage" --json | jq -r '.[].outputs.out')
  [ $? -ne 0 ] && {
    log "$target" "Local build failed. Aborting."
    exit 1
  }

  log "$target" "Copying the closure..."
  nix copy --verbose --to "ssh://$target" "$local_build_output"
  [ $? -ne 0 ] && {
    log "$target" "Failed to copy closure. Aborting."
    exit 1
  }
}

help() {
  echo "Usage: $0 <flake_path> <user@host> [--build-on-target]"
  exit 1
}

main() {
  [ "$#" -lt 1 ] && help

  local flake_path="$1"
  local target="$2"
  local build_on_target=false

  [[ "$3" = "--build-on-target" ]] && build_on_target=true
  [[ -z "$target" ]] && read -rp "Enter the target host: " target
  ssh -q "$target" true || {
    log "$target" "Unable to connect to the target."
    exit 1
  }

  _prepare_temp "$target"
  log "$target" "Temporary directory '/tmp/nix-config' created."

  copy_source_to_target "$target" "$flake_path"

  if [ "$build_on_target" = true ]; then
    log "$target" "Building on target..."
    _sshexec "$target" "cd /tmp/nix-config && sh -c '\$HOME/.nix-profile/bin/home-manager build --flake .#\$(whoami)@\$(hostname || echo \$HOSTNAME)'"
  else
    local_build_and_copy "$target" "$flake_path"
  fi

  log "$target" "Switching to the new configuration..."
  _sshexec "$target" "cd /tmp/nix-config && sh -c '\$HOME/.nix-profile/bin/home-manager switch --flake .#\$(whoami)@\$(hostname || echo \$HOSTNAME)'"

  log "$target" "Cleaning up temporary files..."
  _sshexec "$target" "rm -rf /tmp/nix-config"

  log "$target" "Running home-manager expire-generations..."
  _sshexec "$target" "\$HOME/.nix-profile/bin/home-manager expire-generations 7d"

  log "$target" "Home-manager remote completed."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
