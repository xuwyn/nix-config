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

  loadModules = dir:
    recursivelyImport dir
    |> map (
      path: let
        imported = import path;
        isLamina = lib.isAttrs imported && imported ? module;
        unknown =
          lib.attrNames imported
          |> lib.filter (k: !lib.elem k ["module" "hosts" "host" "tags" "tag" "platforms" "platform"]);

        lamina =
          if isLamina
          then
            assert lib.assertMsg (unknown == [])
            "${toString path}: unknown key(s) ${toString unknown}; allowed: module, hosts, tags, platforms"; imported
          else {module = imported;};
      in
        # wrap `module` so eval errors name this file instead of <unknown-file>.
        lamina // {module = lib.setDefaultModuleLocation path lamina.module;}
    );

  # ---------------------------------------------------------------- filtering
  # "aarch64-linux" -> [ "aarch64" "linux" "aarch64-linux" ]
  platformsOf = system: lib.splitString "-" system ++ [system];

  matchesHost = m: host: let
    # Read a filter as a list, accepting either spelling:
    #   tags = [ "a" "b" ]   or   tag = "a"
    # Returns null when the module sets neither. If both are set, the plural wins.
    pick = plural: singular:
      if m ? ${plural}
      then m.${plural}
      else if m ? ${singular}
      then [m.${singular}]
      else null;

    hosts = pick "hosts" "host";
    tags = pick "tags" "tag";
    platforms = pick "platforms" "platform";

    hostOk = hosts == null || lib.elem host.name hosts;
    tagsOk = tags == null || lib.all (tag: lib.elem tag host.tags) tags;
    platformOk = platforms == null || lib.any (p: lib.elem p host.platforms) platforms;
  in
    hostOk && tagsOk && platformOk;

  # ------------------------------------------------------------------ builders
  mkHost = name: args: let
    system = args.system or "x86_64-linux";

    hostInfo =
      args
      // {
        inherit name system;
        tags = args.tags or [];
        platforms = platformsOf system;
      };

    filteredModules =
      args.modules or []
      |> lib.concatMap loadModules
      |> lib.filter (m: matchesHost m hostInfo);

    builder = args.builder or (import "${nixpkgs}/nixos/lib/eval-config.nix");
  in
    (builder {
      inherit system;
      specialArgs =
        (hostInfo.specialArgs or {})
        // {
          inherit system;
          inherit (hostInfo) tags;
          host = name;
        };
      modules =
        map (m: m.module) filteredModules
        # extraModules are never filtered (overlays, allowUnfree...)
        ++ (args.extraModules or []);
    })
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
  presets = {
    nixos = {
      builder = nixpkgs.lib.nixosSystem;
      system = "x86_64-linux";
      overlays = true;
    };
    rpi = {
      builder = inputs.nixos-raspberrypi.lib.nixosSystem;
      system = "aarch64-linux";
      overlays = false;
    };
    darwin = {
      builder = inputs.nix-darwin.lib.darwinSystem;
      system = "aarch64-darwin";
      overlays = true;
    };
  };

  # The whole flake-level block
  #   modules     - directories to scan
  #   specialArgs - extra specialArgs for every host (inputs and self are added)
  #   overlays    - applied to every preset that has `overlays = true`
  #   nixos / rpi / darwin - attrsets of hosts: { name = { tags, system?, specialArgs?, modules? }; }
  mkLaminaOutputs = {
    modules ? [],
    specialArgs ? {},
    overlays ? [],
    nixos ? {},
    rpi ? {},
    darwin ? {},
  }: let
    mkPreset = preset: hosts:
      mkHosts {
        inherit (presets.${preset}) builder system;
        inherit modules;
        specialArgs = {inherit inputs self;} // specialArgs;
        extraModules =
          [{nixpkgs.config.allowUnfree = true;}]
          ++ lib.optional (presets.${preset}.overlays && overlays != []) {nixpkgs.overlays = overlays;};
      }
      hosts;
  in {
    nixosConfigurations = mkPreset "nixos" nixos // mkPreset "rpi" rpi;
    darwinConfigurations = mkPreset "darwin" darwin;
  };
in {
  inherit recursivelyImport mkHost mkHosts mkLaminaOutputs;
}
