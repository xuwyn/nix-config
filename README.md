<h2 align="center">Half-baked Dendritic Nix Config</h2>

My personal config for NixOS and Home Manager (standalone) running on `x86_64-linux` and `aarch64-darwin`.
Currently, I have no desire to fully transform every hosts I have into NixOS,
so most features are in Home Manager for portability.

## Previews

### Hyprland + Noctalia

![Hyprland + Noctalia Screenshot](./assets/previews/hyprland-noctalia.png)

### i3 + Polybar

![i3 + Polybar Screenshot](./assets/previews/i3-polybar.png)

## Overview

This flake implements a half-baked [dendritic pattern](https://github.com/mightyiam/dendritic).
Why half-baked? Because mixing different classes (i.e., `nixos`, `homeManager`, and `darwin`)
into the same aspect doesn't feel right to me.
From what I learned, there are two main ways of setting up dendritic pattern:

- **`<class>.<aspect>`** which is the standard [flake-parts](https://flake.parts)
- **`<aspect>.<class>`** which can be achieved with [den](https://github.com/denful/den) or just [flake-aspects](https://github.com/denful/flake-aspects)

I went with **`<class>.<aspect>`** since it's easier to separate aspects by class this way.

## Layout

```
./
├── .tack/                 # flake inputs
├── flake.nix              # flake outputs
├── assets/                # desktop screenshots, wallpapers, etc.
└── modules/
    ├── _overlays/         # overlays for nixpkgs
    ├── lib/
    │   ├── options.nix    # options declaration for dendritic structure
    │   └── builders.nix   # nixos and homeManager configuration wrappers
    ├── sops/              # secret management
    ├── hosts/             # host-specific configurations
    ├── nixos/             # nixos modules (e.g., boot, system, network, etc.)
    └── home/              # homeManager modules (e.g., cli, terminals, hyprland, etc.)
```

> [!TIP]
>
> - Naming scheme: **`modules.<class>.<aspect>`** with **`options.<class>.<aspect>.<module>`**
>   - **`<class>`**: `nixos` or `homeManager`
>   - **`<aspect>`**: Usually the same as the folder name
>   - **`<module>`**: Usually the same as the filename (some files has multiple modules in them)
>   - If a file does not belong to any aspect folder, its filename becomes the aspect, and there is no **`<module>`** level in its option path. These standalone aspects are also enabled by default.
> - `nixpkgs-stable` is just a pinned commit of `nixpkgs` (which tracks `nixos-unstable`) from a
>   previous flake update and is **NOT** the actual NixOS stable release (`26.05`)
> - `aarch64-darwin` platform follows this `nixpkgs-stable` input (see `./modules/lib/builders.nix`)
> - `import-tree` does not import files and folders with underscore `_` prefix, so none of those should
>   contain flake module declaration.

## Hosts

| Host       | Platform         | OS            | Modules               | WM + Bar            |
| ---------- | ---------------- | ------------- | --------------------- | ------------------- |
| `apricot`  | `aarch64-darwin` | MacOS         | `homeManager`         | Aerospace           |
| `capybara` | `x86_64-linux`   | CachyOS       | `homeManager`         |
| `lettuce`  | `x86_64-linux`   | WSL           | `nixos`+`homeManager` |
| `mango`    | `x86_64-linux`   | NixOS         | `nixos`+`homeManager` | Hyprland + Noctalia |
| `potato`   | `x86_64-linux`   | Debian Trixie | `homeManager`         | i3 + Polybar        |

## Installation

This section is mainly for my poor memory.

### Add New Host

Create host-specific config file

```sh
cd ~/nix-config
mkdir -p modules/hosts/new-host
touch modules/hosts/new-host/configuration.nix
```

<details>
  <summary>Example of host configuration</summary>

```nix
{ config, ... }: let
wallpaper = ../../../wallpapers/default.png;
in {
  nixos.new-host = {
    system = "x86_64-linux";
    host = "new-host";
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
      hyprland
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
          hyprland.enable = true;
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

> [!NOTE]
> [Impermanence](https://github.com/nix-community/impermanence#home-manager) only supports `home-manager` as a NixOS module so create a subvolume for `/home` to exclude it from impermanence

1. Follow the [quickstart.md](https://github.com/nix-community/disko/blob/master/docs/quickstart.md) to get a disko template
2. Replace `device` with disk name or id, obtains by

   ```sh
   lsblk -f
   ls -la /dev/disk/by-id
   ```

3. Edit partition values to match hardware and personal preferences

**Install NixOS with disko from a flash drive**

1. Get an ISO image from [NixOS](https://nixos.org/download/) onto a flash drive and boot into it
2. Step-by-step commands to format disk with disko and install NixOS

   ```sh
   # Use nix-shell to get all required tools
   nix-shell -p git age sops

   # Clone repo
   git clone https://github.com/xuwyn/nix-config.git ~/nix-config

   # Create age key for host
   age-keygen -o keys.txt

   # Copy host public age key to .sops.yaml
   age-keygen -y keys.txt
   vi nix-config/modules/sops/.sops.yaml

   # Create user password in hash
   mkpasswd -m yescrypt

   # Add the hashed password to new-host.yaml
   sops nix-config/modules/sops/new-host.yaml

   # Format disk with disko
   sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko --flake nix-config#new-host

   # Copy host keys to newly formatted disk
   sudo mkdir -p /mnt/etc/sops/age
   sudo cp keys.txt /mnt/etc/sops/age

   # Install NixOS
   sudo nixos-install --root /mnt --flake nix-config#new-host

   # Copy host keys to /persist (just in case)
   sudo cp -r /mnt/etc/sops /mnt/persist/root/etc

   # Copy current repo to new-user's home
   sudo cp -r nix-config /mnt/home/new-user
   sudo chown -R new-user:new-user /mnt/home/new-user/nix-config

   # Reboot into UEFI
   systemctl reboot --firmware-setup
   ```

#### Other Distros

Install Nix package manager following the [official guide](https://nixos.org/download/#nix-install-linux).

```sh
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --daemon
```

Or install [Determinate Nix](https://docs.determinate.systems/determinate-nix/) instead (flake enabled by default)

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

#### MacOS

Install Nix package manager following the [official guide](https://nixos.org/download/#nix-install-macos).

```sh
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
```

Or install [Determinate Nix](https://docs.determinate.systems/determinate-nix/) instead (flake enabled by default)

### Install Home Manager (Standalone)

Follow the [official guide](https://nix-community.github.io/home-manager/installation/standalone.html) to install Home Manager

```sh
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

### Enable Flake

If not using Determinate, enable flake before running `nixos-rebuild` and/or `home-manager switch`

```sh
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Nix Rebuild (NixOS Only)

> [!NOTE]
> This step can be skipped for hosts that only use Home Manager

Run initial build with `nixos-rebuild`

```sh
cd ~/nix-config

# (Optional) fetch assets/ on fresh install (no git-lfs)
nix-shell -p git git-lfs
git lfs install
git lfs fetch
git lfs checkout

# use `dry-activate` to preview changes without applying them
sudo nixos-rebuild dry-activate --flake .#new-host

# use `switch` to apply changes after build
sudo nixos-rebuild switch --flake .#new-host

# use `boot` to apply changes after a reboot
sudo nixos-rebuild boot --flake .#new-host
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

### Home Manager Switch

Run initial build with `home-manager`

```sh
# use flag `--dry-run` to preview changes without applying them
home-manager switch --flake .#new-user@new-host --dry-run

# apply changes after build
home-manager switch --flake .#new-user@new-host

# high-chance it will complain about backup files
# use `-b bak` to backup files with .bak
home-manager switch -b bak --flake .#new-user@new-host
```

If `nh` is enabled with the initial `home-manager switch`, subsequent builds can be executed with

```sh
# use flag `--dry` to preview changes without applying them
nh home switch --dry

# apply changes after build
nh home switch
```

### Flake Update

This flake uses [tack](https://github.com/manic-systems/tack) to lazily fetch inputs

```sh
# add new input
tack add <name> <url>

# remove an input
tack rm <name>

# update inputs
tack update [names...]
```

### Garbage Collector

```sh
# use `nh`
nh clean all

# use shell abbr. (see ./modules/home/cli/shell.nix)
ncg
```

## Troubleshoot

### NVIDIA Shenanigans

- Use open-sourced driver for RTX 50xx (see `./modules/nixos/drivers/nvidia.nix`)
- Use `offload` mode for laptop with NVIDIA GPU
- Use `sync` mode for desktop with NVIDIA GPU
- Standalone Home Manager running on non-NixOS Linux hosts with NVIDIA GPU
  should enable `targets.genericLinux.gpu.nvidia`

  ```nix
  # example for _gpu.nix
  { lib, ... }: {
    nixpkgs.config.nvidia.acceptLicense = true;
    targets = {
      genericLinux = {
        enable = true;
        gpu = {
          enable = true;
          nvidia = {
            enable = true;
            # Run `nvidia-smi` to get the exact driver version
            version = "595.71.05";
            # Run `home-manager switch` once to get the actual hash then replace it here
            sha256 = lib.fakeHash;
          };
        };
      };
    };
  }
  ```

### Fix `pkg-config` Path on Non-NixOS Hosts

When Nix is installed on a non-NixOS host, it puts its own path at the beginning of `$PATH`.
This leads to errors running updates with the host's native package manager (e.g., `apt`, `yay`, etc.)
because the nix version of `pkg-config` points to the `nix-store` instead of the host system.

#### Arch-based Distros

Because AUR helpers like `yay` and `paru` rely on `makepkg` (from `pacman`) to compile packages:

```sh
mkdir -p ~/.config/pacman
echo 'PKG_CONFIG_PATH="/usr/lib/pkgconfig:/usr/share/pkgconfig"' >> ~/.config/pacman/makepkg.conf
```

## Acknowledgement

Huge thanks to everyone whose configurations I have referenced for the past two months learning Nix!
I also want to extend my sincere thank you to all the nixpkgs maintainers, as well as the authors
and contributors of open-source projects I used in my setup!

### References

- **[ZaneyOS](https://gitlab.com/Zaney/zaneyos)**: Best starting point for beginner (especially for non-coders like me 🥲)
- **[linusammon](https://github.com/linusammon/nixos-config)**: Thank you for the helpful tips migrating away from `flake-parts` and `import-tree`
- **[dendritic-design-with-flake-parts](https://github.com/Doc-Steve/dendritic-design-with-flake-parts)**: Guide to setup dendritic pattern
- **[denful/den](https://github.com/denful/den)**: A complex den framework
- **[ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)**: Server stuffs
- **[Vortriz/dotfiles](https://github.com/Vortriz/dotfiles)**: Custom zed theme using stylix colors
- **[AlexNabokikh/nix-config](https://github.com/AlexNabokikh/nix-config)**: Simple dendritic nix
- **[MatthiasBenaets/nix-config](https://github.com/MatthiasBenaets/nix-config)**: Dev shell layout and Aerospace WM
