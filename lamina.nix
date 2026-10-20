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
        lamina
        // {
          # hjem hosts have no module system, so they use the module as written
          raw = lamina.module;
          # wrap `module` so eval errors name this file instead of <unknown-file>.
          module = lib.setDefaultModuleLocation path lamina.module;
        }
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

    hostOk =
      if host.hjemOnly
      then hosts != null && lib.elem host.name hosts
      else hosts == null || lib.elem host.name hosts;

    # hjem only look at `hosts`, tags and platforms don't apply, might regret this ¯\_(ツ)_/¯
    tagsOk = host.hjemOnly || tags == null || lib.all (tag: lib.elem tag host.tags) tags;
    platformOk = host.hjemOnly || platforms == null || lib.any (p: lib.elem p host.platforms) platforms;
  in
    hostOk && tagsOk && platformOk;

  # Merge plain-data fragments (used for hjem hosts, which have no module system):
  #   attrsets  -> merged recursively
  #   lists     -> concatenated
  #   scalars   -> equal values collapse, differing values throw
  mergeValues = path: a: b:
    if lib.isAttrs a && !lib.isDerivation a && lib.isAttrs b && !lib.isDerivation b
    then recursiveMergeAttrs path a b
    else if lib.isList a && lib.isList b
    then a ++ b
    else if a == b
    then a
    else throw "lamina: conflicting values in hjem config at `${path |> lib.concatStringsSep "."}`";

  # merge two attrsets: keys on one side pass through, shared keys go to mergeValues
  recursiveMergeAttrs = path: lhs: rhs:
    lhs
    // rhs
    // (
      lib.intersectAttrs lhs rhs
      |> lib.mapAttrs (name: value: mergeValues (path ++ [name]) lhs.${name} value)
    );

  recursiveMergeAttrsList = lib.foldl' (recursiveMergeAttrs []) {};

  # ------------------------------------------------------------------ builders
  mkHost = key: args: let
    system = args.system or "x86_64-linux";
    hjemOnly = args.hjemOnly or false;

    # hjem configs are keyed "user@host"
    parsed =
      if !hjemOnly
      then null
      else let
        m = builtins.match "([^@]+)@([^@]+)" key;
      in
        if m == null
        then throw ''lamina: hjem key "${key}" must look like "user@host"''
        else {
          user = lib.elemAt m 0;
          host = lib.elemAt m 1;
        };

    # `name` is what `hosts = [...]` filters match against
    name =
      if hjemOnly
      then parsed.host
      else key;

    hostInfo =
      args
      // {
        inherit name system hjemOnly;
        tags = args.tags or [];
        platforms = platformsOf system;
      };

    filteredModules =
      args.modules or []
      |> lib.concatMap loadModules
      |> lib.filter (m: matchesHost m hostInfo);

    specialArgs =
      (args.specialArgs or {})
      // {
        inherit system;
        host = name;
      }
      // (
        if hjemOnly
        then {inherit (parsed) user;}
        else {inherit (hostInfo) tags;}
      );
  in
    if hjemOnly
    then let
      # Each file is a plain function (or attrset), lamina only calls them and merges the results
      callArgs = removeAttrs specialArgs ["users"] // {pkgs = args.mkPkgs system;};
      call = m:
        if lib.isFunction m
        then m (lib.intersectAttrs (lib.functionArgs m) callArgs)
        else m;
    in
      recursiveMergeAttrsList (map (m: call m.raw) filteredModules)
    else
      (
        (args.builder or (import "${nixpkgs}/nixos/lib/eval-config.nix")) {
          inherit system specialArgs;
          # extraModules are never filtered (overlays, allowUnfree...)
          modules = map (m: m.module) filteredModules ++ (args.extraModules or []);
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
      hjemOnly = true;
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
      hjemOnly = preset.hjemOnly or false;
    in
      mkHosts (
        removeAttrs preset ["applyOverlays"]
        // {
          inherit modules;
          specialArgs = {inherit inputs self;} // specialArgs;
          # nixpkgs.* options don't exist outside a NixOS-style eval
          extraModules = lib.optionals (!hjemOnly) (
            [{nixpkgs.config.allowUnfree = true;}]
            ++ lib.optional (preset.applyOverlays && overlays != []) {nixpkgs.overlays = overlays;}
          );
        }
        // lib.optionalAttrs hjemOnly {
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
    hjemConfigurations = let
      built = mkPreset "hjem" hjem;
      userOf = key: lib.head (lib.splitString "@" key);
    in
      lib.mapAttrs' (key: cfg: lib.nameValuePair (userOf key) cfg) built;
  };
in {
  inherit recursivelyImport recursiveMergeAttrs recursiveMergeAttrsList mkHost mkHosts mkLaminaOutputs;
}
