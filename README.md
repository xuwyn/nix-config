<h2 align="center">Half-baked Dendritic Nix Config</h2>

My personal config for NixOS and Home Manager running on `x86_64-linux` and `aarch64-darwin`.
Currently, I have no desire to fully transform every hosts I have into NixOS,
so most features are in Home Manager for portability.

## Previews

### Hyprland + Noctalia

![Hyprland + Noctalia Screenshot](./previews/hyprland-noctalia.png)

### i3 + Polybar

![i3 + Polybar Screenshot](./previews/i3-polybar.png)

## Overview

This config uses [flake](https://nix.dev/concepts/flakes.html) and [flake-parts](https://flake.parts)
to implement a half-baked [dendritic pattern](https://github.com/mightyiam/dendritic).
Why half-baked? Because mixing different classes (i.e., `nixos`, `homeManager`, and `darwin`)
into the same aspect doesn't feel right to me.
From what I learned, there are two main ways of setting up dendritic pattern:

- **`<class>.<aspect>`** which is the standard [flake-parts](https://flake.parts)
- **`<aspect>.<class>`** which can be achieved with [den](https://github.com/denful/den) or just [flake-aspects](https://github.com/denful/flake-aspects)

I went with **`<class>.<aspect>`** since I like to separate classes explicitly but this may change in the future.
Sure hope one day my brain will cooperate enough to refactor this mess into [denful](https://github.com/denful) ecosystem.

## Layout

```
./
├── modules/
│   ├── _drivers/          # hardware drivers (see ./modules/nixos/profiles)
│   ├── _overlays/         # overlays for nixpkgs (see ./modules/flake/builders.nix)
│   ├── flake/
│   │   ├── builders.nix   # nixos and homeManager configuration wrappers
│   │   └── meta.nix       # flake outputs (e.g., formatter, check, etc.)
│   ├── hosts/             # host-specific configurations
│   ├── nixos/             # nixos modules (e.g., boot, system, network, etc.)
│   └── home/              # homeManager modules (e.g., cli, terminals, hyprland, etc.)
├── wallpapers/            # symlinked to ~/Pictures/Wallpapers (see ./modules/home/dotfiles)
├── previews/              # desktop screenshots
├── flake.lock             # pining flake input versions
└── flake.nix              # flake entry point, inputs, import-tree and binary caches
```

> [!TIP]
>
> - Naming scheme: **`modules.<class>.<aspect>`** with **`options.<class>.<aspect>.<module>`**
>   - **`<class>`**: `nixos` or `homeManager`
>   - **`<aspect>`**: Usually the same as the folder name. (The two exceptions are `./modules/nixos/profiles` and `./modules/home/extra`)
>   - **`<module>`**: Usually the same as the filename. (Some files has multiple modules in them)
>   - If a file does not belong to any aspect folder, its filename becomes the aspect, and there is no **`<module>`** level in its option path. These standalone aspects are also enabled by default.
> - `nixpkgs-stable` is just a pinned commit of `nixpkgs` (which tracks `nixos-unstable`) from a
>   previous flake update and is **NOT** the actual NixOS stable release (`26.05`).
> - `aarch64-darwin` platform follows this `nixpkgs-stable` input. (See `./modules/flake/builders.nix`)
> - No need to import modules from `./modules/nixos/profiles/` in host configs because the
>   `nixosConfigurations` wrapper already does this. (See `./modules/flake/builders.nix`)
> - `import-tree` does not import files and folders with underscore `_` prefix, so none of those should
>   contain flake module declaration.

## Hosts

| Host       | Platform         | Hardware Profile  | Modules               | WM + Bar            |
| ---------- | ---------------- | ----------------- | --------------------- | ------------------- |
| `apricot`  | `aarch64-darwin` |                   | `homeManager`         | Aerospace           |
| `capybara` | `x86_64-linux`   |                   | `homeManager`         |
| `lettuce`  | `x86_64-linux`   | `wsl`             | `nixos`+`homeManager` |
| `mango`    | `x86_64-linux`   | `amd-nvidia-sync` | `nixos`+`homeManager` | Hyprland + Noctalia |
| `potato`   | `x86_64-linux`   |                   | `homeManager`         | i3 + Polybar        |

## Installation

This section is mainly for my poor memory.

### Install Nix

#### NixOS

> **TODO:** Use [disko](https://github.com/nix-community/disko) to skip this step

Install NixOS according to the [NixOS Manual](https://nixos.org/manual/nixos/stable/).

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

### Clone This Repository

Assuming fresh install, use `nix-shell` to get `git`

```sh
nix-shell -p git --run "git clone https://github.com/xuwyn/nix-config.git ~/nix-config"

# Or use this to skip downloading wallpapers/ (~150MB)
nix-shell -p git git-lfs --run "GIT_LFS_SKIP_SMUDGE=1 git clone https://github.com/xuwyn/nix-config.git ~/nix-config"
```

If `git` is already installed, clone as usual

```sh
git clone https://github.com/xuwyn/nix-config.git ~/nix-config

# Or skip cloning wallpapers/ if git-lfs is installed
GIT_LFS_SKIP_SMUDGE=1 git clone https://github.com/xuwyn/nix-config.git ~/nix-config
```

### Add New Host

Create host-specific config file

```sh
cd ~/nix-config
mkdir -p modules/hosts/new-host
touch modules/hosts/new-host/default.nix
```

<details>
  <summary>Example modules/hosts/new-host/default.nix</summary>

```nix
{ config, ... }: let
stylixImage = ../../../wallpapers/default.png;
in {
  nixos.new-host = {
    host = "new-host";
    profile = "amd-nvidia-offload";
    username = "new-user";
    modules = with config.flake.modules.nixos; [
      ./_hardware.nix
      nix-conf
      system
      boot
      network
      user
      desktop
      ({ pkgs, ... }: {
        nixos = {
          amd-nvidia-sync = {
            nvidiaID = "PCI:1:0:0";
            amdgpuID = "PCI:15:0:0";
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
          theme = { stylix  = { enable = true; image = stylixImage; }; };
        };
      })
    ];
  };
}
```

</details>

### Add Hardware Configuration (NixOS Only)

> [!WARNING]
> Skip this step for hosts running on WSL/VMs, as well as hosts that only use Home Manager

```sh
# Create hardware configuration
nixos-generate-config --show-hardware-config > ~/nix-config/modules/hosts/new-host/_hardware.nix

# Or copy existing one (assuming default NixOS installation)
cp /etc/nixos/hardware-configuration.nix ~/nix-config/modules/hosts/new-host/_hardware.nix
```

### Enable Flake

If not using Determinate, enable flake before running `nixos-rebuild` and `home-manager switch`

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

### Garbage Collector

```sh
# use `nh`
nh clean all

# use shell abbr. (see ./modules/home/cli/shell.nix)
ncg
```

## Troubleshoot

### NVIDIA Shenanigans

- Use open-sourced driver for RTX 50xx (see `./modules/_drivers/nvidia.nix`)
- Use `nvidia-offload` profile for laptop with NVIDIA GPU
- Use `nvidia-sync` profile for desktop with NVIDIA GPU
- Standalone Home Manager running on non-NixOS Linux hosts with NVIDIA GPU
  should enable `targets.genericLinux.gpu.nvidia`

  ```nix
  # example for _gpu.nix
  {...}: {
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
- **[denful/den](https://github.com/denful/den)**: Best resource to learn den pattern
- **[ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)**: Server stuffs
- **[Vortriz/dotfiles](https://github.com/Vortriz/dotfiles)**: Custom zed theme using stylix colors
- **[AlexNabokikh/nix-config](https://github.com/AlexNabokikh/nix-config)**: Simple dendritic nix
- **[MatthiasBenaets/nix-config](https://github.com/MatthiasBenaets/nix-config)**: Dev shell layout and Aerospace WM
