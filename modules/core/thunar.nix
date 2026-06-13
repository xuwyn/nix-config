{
  pkgs,
  host,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) terminal;
  openTerminal =
    if terminal == "foot"
    then "foot -D %f"
    else if terminal == "kitty"
    then "kitty -d %f"
    else if terminal == "alacritty"
    then "alacritty --working-directory %f"
    else if terminal == "wezterm"
    then "wezterm start --cwd %f"
    else if terminal == "ghostty"
    then "ghostty --working-directory=%f"
    else throw "Unknown terminal type set in thunar.nix!";
in {
  programs.thunar = {
    enable = true;
    plugins = [
      pkgs.thunar-archive-plugin
      pkgs.thunar-volman
    ];
  };
  environment.systemPackages = with pkgs; [
    ffmpegthumbnailer # Need For Video / Image Preview
  ];

  # Open chosen terminal
  xdg.configFile."Thunar/uca.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <actions>
    <action>
        <icon>utilities-terminal</icon>
        <name>Open Terminal Here</name>
        <submenu></submenu>
        <unique-id>1710575157271461-1</unique-id>
        <command>${openTerminal}</command>
        <description>Open the current directory in foot</description>
        <range></range>
        <patterns>*</patterns>
        <startup-notify/>
        <directories/>
    </action>
    </actions>
  '';
}
