{
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
    pkgs,
    config,
    lib,
    inputs,
    self,
    system,
    ...
  }: let
    wm = self.wrapperModules.${system};
    noctalia = wm.noctalia {inherit (config.custom) desktop;};
    umbriel = wm.umbriel {inherit (config.custom) desktop;};
  in {
    imports = [inputs.umbriel.nixosModules.default];

    programs.umbriel = {
      enable = lib.mkDefault true;
      package = umbriel;
    };

    environment.systemPackages = with pkgs; [
      umbriel
      eog
      mpv
      rhythmbox
      playerctl
      noctalia
      evtest # bongocat
      grim # ocr
      slurp # ocr
      tesseract # ocr
    ];
  };
}
