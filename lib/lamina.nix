# The original belongs to iynaix, thank you for making Lamina!
# Source     : https://github.com/iynaix/lamina
# Disclaimer : This version of Lamina is vibe-coded to fit my usage
{
  inputs,
  self,
  ...
}: let
  nixpkgs = inputs.nixpkgs;
  lib = nixpkgs.lib;
  hjemShim = import ./hjem-shim.nix {inherit lib inputs;};

  # ---------------------------------------------------------------- discovery
  recursivelyImport = root:
    root
    |> lib.fileset.fileFilter (file: file.hasExt "nix")
    |> lib.fileset.toList
    |> lib.filter (
      file:
        toString file
        |> lib.removePrefix "${toString root}/"
        |> lib.splitString "/"
        |> lib.all (part: !lib.hasPrefix "_" part)
    );

  allowedKeys = ["module" "targets" "target" "tags" "tag" "platforms" "platform" "hjemCompat"];

  loadModules = dir:
    recursivelyImport dir
    |> map (
      path: let
        imported = import path;
        isLamina = lib.isAttrs imported && lib.any (k: imported ? ${k}) allowedKeys; # fail loudly for typo with `modules`
        unknown =
          lib.attrNames imported
          |> lib.filter (k: !lib.elem k allowedKeys);

        lamina =
          if isLamina
          then
            assert lib.assertMsg (imported ? module && unknown == [])
            "${toString path}: needs a `module` key, and no unknown keys (got: ${toString unknown}); allowed: ${toString allowedKeys}"; imported
          else {module = imported;};
      in
        lamina
        // {
          # wrap `module` so eval errors name this file instead of <unknown-file>.
          module = lib.setDefaultModuleLocation path lamina.module;
        }
    );

  # ---------------------------------------------------------------- filtering
  matchesTarget = m: target: let
    # Read a filter as a list, accepting either spelling:
    #   tags = [ "a" "b" ]   or   tag = "a"
    # Returns null when the module sets neither. If both are set, the plural wins.
    pick = plural: singular:
      if m ? ${plural}
      then m.${plural}
      else if m ? ${singular}
      then [m.${singular}]
      else null;

    targets = pick "targets" "target";
    tags = pick "tags" "tag";
    platforms = pick "platforms" "platform";

    # a target is a host name, or "user@host" on hjem-only hosts
    # (a bare host name matches every user on that host)
    targetOk = targets == null || lib.any (t: lib.elem t target.names) targets;
    tagsOk = tags == null || lib.all (tag: lib.elem tag target.tags) tags;
    platformOk = platforms == null || lib.any (p: lib.elem p target.platforms) platforms;
    hjemOk = !target.isHjem || (m.hjemCompat or false);
  in
    targetOk && tagsOk && platformOk && hjemOk;

  # ------------------------------------------------------------------ builders
  mkHost = target: args: let
    system = args.system or "x86_64-linux";
    isHjem = args.isHjem or false;

    parseHjem =
      if isHjem
      then
        (let
          m = builtins.match "([^@]+)@([^@]+)" target;
        in
          if m == null
          then throw ''lamina: hjem target "${target}" must look like "user@host"''
          else {
            user = lib.elemAt m 0;
            host = lib.elemAt m 1;
          })
      else null; # never reachable

    host =
      if isHjem
      then parseHjem.host
      else target;

    tags = args.tags or [];

    targetInfo = {
      inherit system isHjem tags;
      names = lib.unique [host target];
      # "aarch64-linux" -> [ "aarch64" "linux" "aarch64-linux" ]
      platforms = lib.splitString "-" system ++ [system];
    };

    filteredModules =
      args.modules or []
      |> lib.concatMap loadModules
      |> lib.filter (m: matchesTarget m targetInfo);

    specialArgs =
      (args.specialArgs or {})
      // {
        inherit system tags host;
      }
      // lib.optionalAttrs isHjem {
        inherit (parseHjem) user;
        users = [parseHjem.user];
      };

    # extraModules are never filtered (overlays, allowUnfree...)
    modules = map (m: m.module) filteredModules ++ (args.extraModules or []);
  in
    if isHjem
    then
      hjemShim {
        inherit system specialArgs modules;
        pkgs = args.mkPkgs system;
        user = parseHjem.user;
        home =
          args.home
          or (
            if lib.hasSuffix "-darwin" system
            then "/Users/${parseHjem.user}"
            else "/home/${parseHjem.user}"
          );
      }
    else
      (
        (args.builder or (import "${nixpkgs}/nixos/lib/eval-config.nix")) {
          inherit system specialArgs modules;
        }
      )
      # used by ci to read system per config without eval
      // {lamina = {inherit system;};};

  # Build an attrset of hosts that share `defaults`. Per-host values win,
  # except modules / extraModules (concatenated) and specialArgs (merged).
  mkHosts = defaults: hosts:
    lib.mapAttrs (
      name: cfg:
        mkHost name (
          defaults
          // cfg
          // {
            modules = (defaults.modules or []) ++ (cfg.modules or []);
            extraModules = (defaults.extraModules or []) ++ (cfg.extraModules or []);
            specialArgs = (defaults.specialArgs or {}) // (cfg.specialArgs or {});
          }
        )
    )
    hosts;

  # ------------------------------------------------------------------- presets
  # applyOverlays - whether the flake-level `overlays` list is applied
  # isHjem        - built with ./hjem-shim.nix instead of a system builder
  presets = {
    nixos = {
      builder = nixpkgs.lib.nixosSystem;
      system = "x86_64-linux";
      applyOverlays = true;
    };
    rpi = {
      builder = inputs.nixos-raspberrypi.lib.nixosSystem;
      system = "aarch64-linux";
      applyOverlays = false;
    };
    darwin = {
      builder = inputs.nix-darwin.lib.darwinSystem;
      system = "aarch64-darwin";
      applyOverlays = true;
    };
    hjem = {
      isHjem = true;
      system = "x86_64-linux";
      applyOverlays = true;
    };
  };

  # The whole flake-level block
  #   modules     - directories to scan
  #   specialArgs - extra specialArgs for every host (inputs and self are added)
  #   overlays    - applied to every preset that has `applyOverlays = true`
  #   nixos / rpi / darwin / hjem - attrsets of hosts:
  #     { name = { tags, system?, specialArgs?, modules? }; }
  mkLaminaOutputs = {
    modules ? [],
    specialArgs ? {},
    overlays ? [],
    nixos ? {},
    rpi ? {},
    darwin ? {},
    hjem ? {},
  }: let
    mkPreset = name: hosts: let
      preset = presets.${name};
      isHjem = preset.isHjem or false;
    in
      mkHosts (
        removeAttrs preset ["applyOverlays"]
        // {
          inherit modules;
          specialArgs = {inherit inputs self;} // specialArgs;
          # nixpkgs.* options don't exist outside a NixOS-style eval
          extraModules = lib.optionals (!isHjem) (
            [{nixpkgs.config.allowUnfree = true;}]
            ++ lib.optional (preset.applyOverlays && overlays != []) {nixpkgs.overlays = overlays;}
          );
        }
        // lib.optionalAttrs isHjem {
          # hjem has no nixpkgs module, so pkgs is built here per host system
          mkPkgs = system:
            import nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = lib.optionals preset.applyOverlays overlays;
            };
        }
      )
      hosts;
  in {
    nixosConfigurations = mkPreset "nixos" nixos // mkPreset "rpi" rpi;
    darwinConfigurations = mkPreset "darwin" darwin;
    hjemConfigurations = mkPreset "hjem" hjem;
  };
in {
  inherit recursivelyImport mkHost mkHosts mkLaminaOutputs;
}
