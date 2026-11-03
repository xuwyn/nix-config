logo: let
  colors = {
    icon = "36";
    text = "34";
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
      type = "os";
    }
    {
      key = "{#${colors.icon}}  {#${colors.text}}Kernel  ";
      type = "kernel";
    }
    {
      key = "{#${colors.icon}}  {#${colors.text}}CPU     ";
      type = "cpu";
    }
    {
      key = "{#${colors.icon}}󰢮  {#${colors.text}}GPU     ";
      type = "gpu";
    }
    {
      key = "{#${colors.icon}}  {#${colors.text}}Desktop ";
      type = "wm";
    }
    {
      key = "{#${colors.icon}}  {#${colors.text}}Shell   ";
      type = "shell";
    }
    {
      key = "{#${colors.icon}}  {#${colors.text}}Terminal";
      type = "terminal";
    }
    {
      key = "{#${colors.icon}}  {#${colors.text}}Memory  ";
      type = "memory";
      format = "{1} / {2}";
    }
    {
      key = "{#${colors.icon}}󱥎  {#${colors.text}}Storage ";
      type = "disk";
      format = "{1} / {2}";
    }
    {
      key = "{#${colors.icon}}󰅐  {#${colors.text}}Uptime  ";
      type = "uptime";
    }
    "break"
    {
      type = "colors";
      symbol = "circle";
    }
  ];
}
