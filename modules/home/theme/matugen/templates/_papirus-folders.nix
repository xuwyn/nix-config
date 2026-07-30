{
  config,
  lib,
  pkgs,
  ...
}: let
  hexDigits = {
    "0" = 0;
    "1" = 1;
    "2" = 2;
    "3" = 3;
    "4" = 4;
    "5" = 5;
    "6" = 6;
    "7" = 7;
    "8" = 8;
    "9" = 9;
    "a" = 10;
    "b" = 11;
    "c" = 12;
    "d" = 13;
    "e" = 14;
    "f" = 15;
  };
  hexByteToInt = s:
    hexDigits.${lib.toLower (builtins.substring 0 1 s)}
    * 16
    + hexDigits.${lib.toLower (builtins.substring 1 1 s)};

  hexToRgb = hex: {
    r = hexByteToInt (builtins.substring 0 2 hex);
    g = hexByteToInt (builtins.substring 2 2 hex);
    b = hexByteToInt (builtins.substring 4 2 hex);
  };

  # cause matugen is pastel
  normalizeColor = {
    r,
    g,
    b,
  }: let
    maxChannel = lib.max r (lib.max g b);
    scale = c:
      if maxChannel == 0
      then 0
      else (c * 255) / maxChannel;
  in {
    r = scale r;
    g = scale g;
    b = scale b;
  };

  # Papirus's built-in preset folder colors (from papirus-folders -l)
  papirusPresets = {
    black = "4f4f4f";
    blue = "5294e2";
    bluegrey = "607d8b";
    brown = "ae8e6c";
    carmine = "a30002";
    cyan = "00bcd4";
    darkcyan = "45abb7";
    deeporange = "eb6637";
    green = "87b158";
    grey = "8e8e8e";
    indigo = "5c6bc0";
    magenta = "ca71df";
    nordic = "81a1c1";
    orange = "ee923a";
    palebrown = "d1bfae";
    paleorange = "eeca8f";
    pink = "f06292";
    red = "e25252";
    teal = "16a085";
    violet = "7e57c2";
    white = "e4e4e4";
    yaru = "676767";
  };

  colorDistance = hexA: hexB: let
    a = normalizeColor (hexToRgb hexA);
    b = normalizeColor (hexToRgb hexB);
  in
    (a.r - b.r) * (a.r - b.r) + (a.g - b.g) * (a.g - b.g) + (a.b - b.b) * (a.b - b.b);

  closestPapirusColor = hex: let
    scored =
      lib.mapAttrsToList (name: presetHex: {
        inherit name;
        dist = colorDistance hex presetHex;
      })
      papirusPresets;
  in
    (lib.head (lib.sort (a: b: a.dist < b.dist) scored)).name;

  matugenPrimaryHex = config.programs.matugen.theme.colors.source_color.default.color;
  papirusColorName = closestPapirusColor matugenPrimaryHex;

  papirusFoldersMatugen = pkgs.papirus-icon-theme.overrideAttrs (old: {
    postInstall =
      (old.postInstall or "")
      + ''
        ${pkgs.papirus-folders}/bin/papirus-folders -C ${papirusColorName} -o --theme $out/share/icons/Papirus-Dark
      '';
  });
in {
  config.homeManager.theme.matugen.papirusPackage = papirusFoldersMatugen;
}
