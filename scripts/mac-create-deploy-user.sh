#!/usr/bin/env bash
#
# mac-create-deploy-user.sh
#
# Creates a 'deploy' user on macOS for headless nix-darwin/deploy-rs deployment
#
# Usage: sudo ./mac-create-deploy-user.sh

set -euo pipefail

USERNAME="deploy"
HOME_DIR="/Users/${USERNAME}"

if [ "$EUID" -ne 0 ]; then
  echo "Run this with sudo." >&2
  exit 1
fi

if dscl . -list /Users | grep -qx "$USERNAME"; then
  echo "User '$USERNAME' already exists. Delete it first with:"
  echo "  sudo sysadminctl -deleteUser $USERNAME"
  exit 1
fi

echo "Currently taken UIDs:"
dscl . -list /Users UniqueID | sort -k2 -n | awk '{printf "  %-6s %s\n", $2, $1}'

echo
echo "Note: UID < 500 is conventional for non-interactive/service accounts."
echo

while true; do
  read -rp "Enter UID for '$USERNAME': " UID_INPUT

  if ! [[ "$UID_INPUT" =~ ^[0-9]+$ ]]; then
    echo "Not a number, try again."
    continue
  fi

  if dscl . -list /Users UniqueID | awk '{print $2}' | grep -qx "$UID_INPUT"; then
    echo "UID $UID_INPUT is already taken, pick another."
    continue
  fi

  break
done

echo
echo "Creating user '$USERNAME' (UID $UID_INPUT, home $HOME_DIR)..."
sysadminctl -addUser "$USERNAME" -fullName "$USERNAME" -home "$HOME_DIR" -shell /bin/zsh -UID "$UID_INPUT"

echo "Hiding '$USERNAME' from the login window (dscl IsHidden = 1)..."
dscl . -create "/Users/${USERNAME}" IsHidden 1

echo "Granting Remote Login (SSH) access..."
dseditgroup -o create com.apple.access_ssh 2>/dev/null || true
dseditgroup -o edit -a "$USERNAME" -t user com.apple.access_ssh

echo
echo "Done. Summary:"
dscl . -read "/Users/${USERNAME}" UniqueID NFSHomeDirectory UserShell IsHidden
