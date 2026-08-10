<h2 align="center">Half-baked Dendritic Nix Config</h2>

<p align="center">
  <a href="#installation"><strong>Installation</strong></a> ❄️
  <a href="./docs/DEPLOYMENT.md"><strong>Deployment</strong></a> ❄️
  <a href="./docs/TROUBLESHOOT.md"><strong>Troubleshoot</strong></a>
</p>

My personal config for nixos, nix-darwin and home-manager (standalone) running on `x86_64-linux` and `aarch64-darwin`.
I currently have no desire to fully transform every hosts I have into NixOS,
so most features are in Home Manager for portability.

## Previews

<details>
<summary>Niri + Noctalia</summary>

<table align="center" style="width: 600px;">
  <tr>
    <td align="center">
      <img src="https://media.githubusercontent.com/media/xuwyn/nix-config/refs/heads/main/assets/previews/niri-noctalia.png" width="100%" />
    </td>
  </tr>
</table>

</details>

<details>
<summary>Hyprland + DankMaterialShell</summary>

<table align="center" style="width: 600px;">
  <tr>
    <td align="center">
      <img src="https://media.githubusercontent.com/media/xuwyn/nix-config/refs/heads/main/assets/previews/hyprland-dms.png" width="100%" />
    </td>
  </tr>
</table>

</details>

<details>
<summary>i3 + Polybar</summary>

<table align="center" style="width: 600px;">
  <tr>
    <td align="center">
      <img src="https://media.githubusercontent.com/media/xuwyn/nix-config/refs/heads/main/assets/previews/i3-polybar.png" width="100%" />
    </td>
  </tr>
</table>

</details>

## Overview

This flake implements a half-baked dendritic pattern. Why half-baked?
Because mixing different classes (i.e., `nixos`, `darwin`, and `homeManager`) into the same aspect doesn't feel right to me.
From what I learned, there are two main ways to set up dendritic pattern:

- **`<class>.<aspect>`** which is the standard [flake-parts](https://flake.parts)
- **`<aspect>.<class>`** which can be achieved with [den](https://github.com/denful/den) or just [flake-aspects](https://github.com/denful/flake-aspects)

I went with **`<class>.<aspect>`** since it's easier to separate aspects by class this way.

I use den pattern as a guideline to modularly divide my config, though adopting it isn't necessary for a modular approach.
As a disclaimer, **none** of tools listed above are actually implemented in my current config, since they are a bit overkill
for what I need. But if I have to compare, my setup is closest to `flake-parts` cause I used it at one point before
learning how to replicate `flake-parts` structure with just pure Nix.

## Layout

```hs
./
├── .tack/                 # flake inputs
├── flake.nix              # flake outputs
├── nvfetcher.toml         # nvfetcher inputs
├── _sources/              # nvfetcher outputs
├── scripts/               # helper scripts
├── assets/                # screenshots, wallpapers, etc.
└── modules/
    ├── lib/
    │   ├── options.nix    # options declaration for dendritic structure
    │   └── builders.nix   # nixos, darwin and homeManager wrappers
    ├── _overlays/         # overlays for nixpkgs
    ├── hosts/             # host-specific configurations
    ├── common/            # common features across classes
    ├── nixos/             # nixos features
    ├── darwin/            # darwin features
    └── home/              # homeManager features
```

<details>
<summary>Design considerations for my half-baked dendritic set up</summary>

- Naming scheme: **`modules.<class>.<aspect>`** with **`options.<class>.<aspect>.<feature>`**
  - **`<class>`**: `nixos` or `darwin` or `homeManager`
  - **`<aspect>`**: Usually the same as the folder name
  - **`<feature>`**: Usually the same as the filename (some files have multiple features in them)
  - If a file does not belong to any folder, its filename becomes the aspect, and there is no **`<feature>`** level
    in its option path. These standalone aspects are also enabled by default
- [modules/common](./modules/common/) stores aspects shared across multiple classes. The goal is to reduce code
  duplication, so even if `darwin` and `nixos` both have `network.nix`, there's no real benefit to combining them into
  a single file
- `nixpkgs-stable` is just a pinned commit of `nixpkgs` (which tracks `nixos-unstable`) from a
  previous flake update and is **NOT** the actual NixOS stable release (`26.05`)
- `aarch64-darwin` platform follows this `nixpkgs-stable` input due to `darwin` not being a high priority in `nixpkgs`
  updates (see [builder.nix](./modules/lib/builders.nix))
- `import-tree` does not import files and folders with underscore `_` prefix, so none of those should
  contain aspect declaration (see [flake.nix](./flake.nix))

</details>

## Hosts

| Host       | Platform         | OS            | Modules                | DE                                                                             |
| ---------- | ---------------- | ------------- | ---------------------- | ------------------------------------------------------------------------------ |
| `apricot`  | `aarch64-darwin` | MacOS         | `darwin`+`homeManager` | Aerospace                                                                      |
| `capybara` | `x86_64-linux`   | CachyOS       | `homeManager`          | Hyprland+[DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) |
| `lettuce`  | `x86_64-linux`   | WSL           | `nixos`+`homeManager`  |
| `mango`    | `x86_64-linux`   | NixOS         | `nixos`+`homeManager`  | Niri+[Noctalia](https://github.com/noctalia-dev/noctalia)                      |
| `potato`   | `x86_64-linux`   | Debian Trixie | `homeManager`          | i3+Polybar                                                                     |

## Installation

This section is mainly for my poor memory.

### Add New Host

Create host-specific config file

```sh
cd ~/nix-config
mkdir -p modules/hosts/new-host
vi modules/hosts/new-host/configuration.nix
```

<details>
  <summary>Example of host configuration</summary>

```nix
{ config, ... }: let
wallpaper = ../../../assets/wallpapers/default.png;
in {
  nixos.new-host = {
    system = "x86_64-linux";
    users = ["new-user"];
    modules = with config.modules.nixos; [
      ./_disko.nix
      drivers
      sops
      system
      boot
      network
      users
      desktop
      (_: {
        nixos = {
          drivers = {
            amdcpu.enable = true;
            nvidia.enable = true;
            nvidia-amd-hybrid = {
                enable = true;
                mode = "offload";
                nvidiaBusID = "PCI:1:0:0";
                amdgpuBusID = "PCI:15:0:0";
            };
          };
          desktop.hyprland.enable = true;
        };
      })
    ];
  };

  home."new-user@new-host" = {
    system = "x86_64-linux";
    username = "new-user";
    modules = with config.modules.homeManager; [
      home
      sops
      cli
      terminals
      desktop
      hyprland
      noctalia
      theme
      (_: {
        homeManager = {
          cli = {
            zsh.enable = true;
            git = {
              enable = true;
              username = "git-username";
              email = "email@example.com";
            };
          };
          terminals.kitty.enable = true;
          theme = { matugen = { enable = true; inherit wallpaper; }; };
        };
      })
    ];
  };
}
```

</details>

### Install Nix

#### NixOS

**Create [disko](https://github.com/nix-community/disko/tree/master) configuration**

1. Follow the [quickstart.md](https://github.com/nix-community/disko/blob/master/docs/quickstart.md) to get a disko template
2. Replace `device` with disk name or id obtained by running `lsblk -f` and `ls -la /dev/disk/by-id`
3. Edit partition values to match hardware and personal preferences

**Install NixOS with disko from a flash drive**

Boot into an external drive with [NixOS](https://nixos.org/download/) ISO or any distro with Nix installed and do the following:

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

#### Other Distros

Install Nix package manager following the [official guide](https://nixos.org/download/#nix-install-linux).

```sh
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --daemon
```

#### MacOS

Install [Lix](https://lix.systems/install/) instead cause the official installer from Nix didn't work for me

```sh
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

### Install Home Manager

> [!NOTE]
> This step can be skipped for hosts that use both `nixos` and `homeManager`

Follow the [official guide](https://nix-community.github.io/home-manager/installation/standalone.html) to install Home Manager standalone

```sh
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

Or use `nix-shell` just to get the binary

```sh
nix-shell -p home-manager
```

### Enable Flake

> [!NOTE]
> This step can be skipped for NixOS installed via `disko`

Enable flake locally before running `nixos-rebuild` and/or `home-manager switch`

```sh
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

## Apply Configurations

### NixOS Switch

> [!NOTE]
> This step can be skipped for hosts that only use `homeManager`

Run initial build with `nixos-rebuild`

```sh
cd /path/to/flake

# (Optional) fetch assets/ on fresh install (no git-lfs)
nix-shell -p git git-lfs
git lfs install
git lfs fetch
git lfs checkout

# use `dry-activate` to preview changes without applying them
sudo nixos-rebuild dry-activate --flake .#host

# use `switch` to apply changes after build
sudo nixos-rebuild switch --flake .#host

# use `boot` to apply changes after a reboot
sudo nixos-rebuild boot --flake .#host
```

If `nh` is enabled with the initial `home-manager switch`, subsequent rebuilds can be executed with

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

If `nh` is enabled with the initial `home-manager switch`, subsequent rebuilds can be executed with

```sh
# use flag `--dry` to preview changes without applying them
nh darwin switch --dry

# use `switch` to apply changes after build
nh darwin switch
```

### Home Manager Switch

Run initial build with `home-manager`

```sh
cd /path/to/flake

# use flag `--dry-run` to preview changes without applying them
home-manager switch --flake .#user@host --dry-run

# apply changes after build
home-manager switch --flake .#user@host

# high-chance it will complain about backup files
# overwriteBackup was not an option in standalone
# use `-b bak` to backup files with .bak
home-manager switch -b bak --flake .#user@host
```

If `nh` is enabled with the initial `home-manager switch`, subsequent builds can be executed with

```sh
# use flag `--dry` to preview changes without applying them
nh home switch --dry

# apply changes after build
nh home switch
```

## Flake Update

This flake uses [tack](https://github.com/manic-systems/tack) to lazily fetch inputs

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
# use `nh`
nh clean all

# use shell abbr. (see ./modules/home/cli/shell.nix)
ncg
```

## Acknowledgement

Huge thanks to everyone whose configurations I have ~~stolen~~ referenced for the past two months learning Nix.
I also want to extend my sincere thank you to all the nixpkgs maintainers, as well as the authors
and contributors of all open-source projects I used in my nix!

### References

- **[Zaney/zaneyos](https://gitlab.com/Zaney/zaneyos):** Best starting point for beginner (especially for non-coders like me 🥲)
- **[linusammon/nixos-config](https://github.com/linusammon/nixos-config):** Tips to migrate away from `flake-parts` and `import-tree`
- **[iynaix/dotfiles](https://github.com/iynaix/dotfiles):** where I learned about cool stuffs like `tack`, `nvfetcher`, `nix repl`
- **[iStellanova/Stellyrland](https://github.com/iStellanova/Stellyrland):** Tips to set up `preservation` and homebrew
- **[rysieko.pl/nixossmth](https://tangled.org/rysieko.pl/nixossmth):** Tips to set up `preservation`
- **[LucasOe/nixos-config](https://github.com/LucasOe/nixos-config):** Home Manager globbing mimeApps
- **[Doc-Steve/dendritic-design-with-flake-parts](https://github.com/Doc-Steve/dendritic-design-with-flake-parts):** Guide to setup dendritic pattern
- **[Vortriz/dotfiles](https://github.com/Vortriz/dotfiles):** Custom zed theme using stylix colors
- **[AlexNabokikh/nix-config](https://github.com/AlexNabokikh/nix-config):** Simple dendritic structure
- **[MatthiasBenaets/nix-config](https://github.com/MatthiasBenaets/nix-config):** Dev shell layout and Aerospace WM
- **[Baitinq/nixos-config](https://github.com/Baitinq/nixos-config):** Use `deploy-rs` for remote deployment
