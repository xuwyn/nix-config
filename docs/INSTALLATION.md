# Installation

This file documents the steps to install all my current NixOS, nix-darwin and
hjem standalone configurations along with some miscellaneous commands for
maintenance.

## Add New Host

Add a new host entry under `laminaOutputs` in [flake.nix](../flake.nix)

```nix
laminaOutputs = lamina.mkLaminaOutputs {
  modules = [./modules];
  inherit overlays;
  specialArgs = {
    users = ["username"];
  };
  nixos.hostname.tags = ["desktop" "nvidia"];
};
```

Create host-specific config file in [modules/hosts](../modules/hosts/)

```sh
cd ~/nix-config
mkdir -p modules/hosts/hostname
vi modules/hosts/hostname/configuration.nix
```

<details>
  <summary>Example of host-specific configuration</summary>

```nix
{
  target = "lettuce";
  module = {
    self,
    system,
    ...
  }: let
    wm = self.wrapperModules.${system};
  in {
    environment.systemPackages = with wm; [
      (bottom {})
      (yazi {})
      (nvf {})
    ];

    custom = {
      binfmt.enable = false;
      nix-ld.enable = false;
    };
  };
}
```

</details>

## Install Nix

### NixOS

**Create [disko](https://github.com/nix-community/disko/tree/master)
configuration**

1. Follow the
   [quickstart.md](https://github.com/nix-community/disko/blob/master/docs/quickstart.md)
   to get a disko template
2. Replace `device` with disk name or id obtained by running `lsblk -f` and
   `ls -la /dev/disk/by-id`
3. Edit partition values to match hardware and personal preferences

**Reformat and install NixOS with disko**

Boot into an external drive with [NixOS](https://nixos.org/download/) ISO or any
distro with Nix installed and do the following:

```sh
# Use nix-shell to get all required tools
nix-shell -p git age sops ssh-to-age

# Clone repo
git clone https://github.com/xuwyn/nix-config.git ~/nix-config

# Format disk with disko
sudo nix --experimental-features "nix-command flakes" \
run github:nix-community/disko -- --mode disko --flake ./nix-config#new-host

# Generate ssh key directly on the target disk
# (sshd-keygen won't run until first boot)
sudo mkdir -p /mnt/etc/ssh
sudo ssh-keygen -t ed25519 -f /mnt/etc/ssh/ssh_host_ed25519_key -N ""

# Derive age key from the host's ssh key and add it to .sops.yaml
cat /mnt/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
vi nix-config/modules/common/sops/.sops.yaml

# Create user password in hash
mkpasswd -m yescrypt

# Add the hashed password to new-host.yaml
sops nix-config/modules/common/sops/new-host.yaml

# Install NixOS
sudo nixos-install --root /mnt --flake ./nix-config#new-host

# Copy host keys to /persist/etc
sudo cp -r /mnt/etc/ssh /mnt/persist/etc/

# Copy current repo to /persist/home/new-user
sudo cp -r nix-config /mnt/persist/home/new-user/

# Fix ownership (might not work if new-user is not defined in the ISO)
sudo chown -R new-user:users /mnt/persist/home/new-user/nix-config

# Reboot into UEFI
systemctl reboot --firmware-setup
```

### Other Distros

Install Nix package manager following the
[official guide](https://nixos.org/download/#nix-install-linux)

```sh
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --daemon
```

And add `hjem` to `nix profile` (more convenient than `nix run` it all the time)

```sh
nix profile add github:feel-co/hjem#hjem
```

Also remember to add the current profile to `$PATH`

```sh
# bash/zsh
export PATH="~/.local/state/hjem/standalone/current-profile/bin:$PATH"

# fish
fish_add_path ~/.local/state/hjem/standalone/current-profile/bin
```

### MacOS

Install [Lix](https://lix.systems/install/) instead cause the official installer
from Nix didn't work for me

```sh
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

### Raspberry Pi

Use
[nvmd/nixos-raspberrypi](https://github.com/nvmd/nixos-raspberrypi/tree/develop#installer-configurations)
installer for sd-image to minimize cache misses

```sh
# build sd-image (X: [02, 3, 4, 5])
nix build github:nvmd/nixos-raspberrypi#installerImages.rpiX --accept-flake-config

# decompress and write the image to the sd card
# find /dev/sdX with `lsblk -f`
zstdcat result/sd-image/nixos-*.img.zst | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
```

Boot into the pi with monitor and keyboard connected to set root password for
first switch

```sh
sudo passwd root

# (Optional) Connect to wifi via iwd
# (stock image use iwd instead of wpa_supplicant)
iwctl station wlan0 connect SSID
```

Connect to the pi via ethernet/wifi and execute first switch with
`nixos-rebuild`. It's also possible to do this with `nixos-anywhere` but not
necessary since no disko was used and the image was already configured on the sd
card

```sh
# Get host ssh key for sops
ssh root@nixos-installer.local "cat /etc/ssh/ssh_host_ed25519_key.pub" | nix run nixpkgs#ssh-to-age

# Add key to current flake (not located on the pi)
vi ./path/to/flake/modules/common/sops/.sops.yaml

# Set user password and add it to rpi secret
mkpasswd -m yescrypt
cd ./path/to/flake/modules/common/sops && sops rpi.yaml

# Remember to updatekeys for other secrets that rpi might need
sudo -E sops updatekeys ./path/to/flake/modules/common/sops/access-tokens.yaml

# First switch
nixos-rebuild switch --flake ./path/to/flake#rpi --accept-flake-config \
--target-host root@nixos-installer.local --build-host root@nixos-installer.local
```

## Apply Configurations

### NixOS Switch

Run initial build with `nixos-rebuild`

```sh
cd /path/to/flake

# use `dry-activate` to preview changes without applying them
sudo nixos-rebuild dry-activate --flake .#host

# use `switch` to apply changes after build
sudo nixos-rebuild switch --flake .#host

# use `boot` to apply changes after a reboot
sudo nixos-rebuild boot --flake .#host
```

Use `nh`

```sh
# use flag `--dry` to preview changes without applying them
nh os switch --dry

# use `switch` to apply changes after build
nh os switch

# use `boot` to apply change after a reboot
nh os boot
```

### Darwin Switch

Run initial build with `nix-darwin`

```sh
cd /path/to/flake
sudo nix run nix-darwin -- switch --flake .#host
```

Subsequent rebuilds can be run with `darwin-rebuild`

```sh
darwin-rebuild switch --flake .#host
```

Use `nh`

```sh
# use flag `--dry` to preview changes without applying them
nh darwin switch --dry

# use `switch` to apply changes after build
nh darwin switch
```

### Hjem Switch

By default, `hjem standalone switch --flake` assumes
`hjemConfigurations."$USER"` as the output, use `--flake-attr` to select output
keyed as `"$USER@$HOST"`

```sh
hjem standalone switch --flake-attr hjemConfigurations.\"$USER@$HOST\" --flake /path/to/flake

# or use shell abbr. (see ../modules/_wrappers/shell/aliases.nix)
hjsw
```

## Flake Update

This flake uses [tack](https://github.com/manic-systems/tack) to fetch inputs

```sh
# add new input
tack add <name> <url>

# remove an input
tack rm <name>

# update inputs
tack update [names...]
```

## Garbage Collector

```sh
# hjem
hjem standalone expire-generations --keep-last 1

# or
hjgc

# use `nh`
nh clean all

# or
ncg
```
