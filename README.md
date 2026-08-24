<h2 align="center">Half-baked Dendritic Nix Config</h2>

<p align="center">
  <a href="./docs/INSTALLATION.md"><strong>Installation</strong></a> ❄️
  <a href="./docs/DEPLOYMENT.md"><strong>Deployment</strong></a> ❄️
  <a href="./docs/TROUBLESHOOT.md"><strong>Troubleshoot</strong></a>
</p>

My personal config for nixos, nix-darwin and home-manager (standalone) running on `x86_64-linux`, `aarch64-linux` and `aarch64-darwin`.
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
Because mixing different classes (i.e., `nixos`, `darwin`, and `homeManager`)
into the same aspect doesn't feel right to me.
From what I learned, there are two main ways to set up dendritic pattern:

- **`<class>.<aspect>`** which is the standard [flake-parts](https://flake.parts)
- **`<aspect>.<class>`** which can be achieved with [den](https://github.com/denful/den)
  or just [flake-aspects](https://github.com/denful/flake-aspects)

I went with **`<class>.<aspect>`** since it's easier to separate aspects by class this way.
As a disclaimer, **none** of tools listed above are actually implemented in my current config
since they are a bit overkill for what I need.

## Layout

```hs
./
├── .tack/                 # flake inputs
├── flake.nix              # flake outputs
├── nvfetcher.toml         # nvfetcher inputs
├── _sources/              # nvfetcher outputs
├── deploy.nix             # remote deployment via deploy-rs
├── scripts/               # custom shell scripts
├── assets/                # screenshots, wallpapers, etc.
└── modules/
    ├── lib/
    │   ├── options.nix    # options declaration for dendritic structure
    │   └── builders.nix   # nixos, darwin, home configuration wrappers
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

| Host       | Platform         | OS            | Modules                | DE                                                                 |
| ---------- | ---------------- | ------------- | ---------------------- | ------------------------------------------------------------------ |
| `apricot`  | `aarch64-darwin` | MacOS         | `darwin`+`homeManager` | [OmniWM](https://github.com/BarutSRB/OmniWM)                       |
| `capybara` | `x86_64-linux`   | CachyOS       | `homeManager`          | Hyprland + [DMS](https://github.com/AvengeMedia/DankMaterialShell) |
| `lettuce`  | `x86_64-linux`   | WSL           | `nixos`+`homeManager`  |
| `mango`    | `x86_64-linux`   | NixOS         | `nixos`+`homeManager`  | Niri + [Noctalia](https://github.com/noctalia-dev/noctalia)        |
| `potato`   | `x86_64-linux`   | Debian Trixie | `homeManager`          | i3 + Polybar                                                       |
| `puffin`   | `aarch64-linux`  | NixOS         | `nixos`+`homeManager`  |                                                                    |

## Acknowledgement

Huge thanks to everyone whose configurations I have ~~stolen~~ referenced and incorporated into my setup,
especially the folks in Noctalia Discord's **#nixos** channel. I also want to extend my sincere
thanks to the nixpkgs maintainers, as well as the authors and contributors of all open-source projects!

### References

- **[Zaney/zaneyos](https://gitlab.com/Zaney/zaneyos):** Best starting point for beginners (especially for non-coders like me 🥲)
- **[linusammon/nixos-config](https://github.com/linusammon/nixos-config):** Tips to migrate away from `flake-parts` and `import-tree`
- **[iynaix/dotfiles](https://github.com/iynaix/dotfiles):** where I learned about cool stuffs like `tack`, `nvfetcher`, `nix repl`
- **[iStellanova/Stellyrland](https://github.com/iStellanova/Stellyrland):** Tips to set up `preservation` and `homebrew`
- **[rysieko.pl/nixossmth](https://tangled.org/rysieko.pl/nixossmth):** Tips to set up `preservation`
- **[eljangus/nixos](https://github.com/eljangus/nixos):** Pretty cursor and fastfetch themes
- **[samiser/nix-configs](https://github.com/samiser/nix-configs):** Self-host cache with Attic
- **[LucasOe/nixos-config](https://github.com/LucasOe/nixos-config):** Home Manager globbing mimeApps
- **[Doc-Steve/dendritic-design-with-flake-parts](https://github.com/Doc-Steve/dendritic-design-with-flake-parts):** Guide to setup dendritic pattern
- **[Vortriz/dotfiles](https://github.com/Vortriz/dotfiles):** Custom zed theme using stylix colors
- **[AlexNabokikh/nix-config](https://github.com/AlexNabokikh/nix-config):** Simple dendritic structure
- **[MatthiasBenaets/nix-config](https://github.com/MatthiasBenaets/nix-config):** Dev shell layout and Aerospace WM
- **[Baitinq/nixos-config](https://github.com/Baitinq/nixos-config):** Remote deployment with `deploy-rs`
