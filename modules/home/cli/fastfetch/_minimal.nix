{logo, ...}: let
  colors = {
    icon = "36";
    text = "34";
    output = "white";
  };
in {
  inherit logo;
  display.separator = "  󰨐  ";
  modules = [
    "break"
    {
      type = "title";
      format = "{#${colors.icon}}{user-name}{#35}@{#${colors.text}}{host-name}";
    }
    "break"
    {
      key = "{#${colors.icon}}{icon}  {#${colors.text}}Distro  ";
      outputColor = colors.output;
      type = "os";
    }
    {
      key = "{#${colors.icon}}  {#${colors.text}}Kernel  ";
      outputColor = colors.output;
      type = "kernel";
    }
    {
      key = "{#${colors.icon}}  {#${colors.text}}CPU     ";
      outputColor = colors.output;
      type = "cpu";
    }
    {
      key = "{#${colors.icon}}󰢮  {#${colors.text}}GPU     ";
      outputColor = colors.output;
      type = "gpu";
    }
    {
      key = "{#${colors.icon}}  {#${colors.text}}Desktop ";
      outputColor = colors.output;
      type = "wm";
    }
    {
      key = "{#${colors.icon}}  {#${colors.text}}Shell   ";
      outputColor = colors.output;
      type = "shell";
    }
    {
      key = "{#${colors.icon}}  {#${colors.text}}Terminal";
      outputColor = colors.output;
      type = "terminal";
    }
    {
      key = "{#${colors.icon}}  {#${colors.text}}Memory  ";
      outputColor = colors.output;
      type = "memory";
      format = "{1} / {2}";
    }
    {
      key = "{#${colors.icon}}󱥎  {#${colors.text}}Storage ";
      outputColor = colors.output;
      type = "disk";
      format = "{1} / {2}";
    }
    {
      key = "{#${colors.icon}}󰅐  {#${colors.text}}Uptime  ";
      outputColor = colors.output;
      type = "uptime";
    }
    "break"
    {
      type = "colors";
      symbol = "circle";
    }
  ];
}
