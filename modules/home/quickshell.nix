{
  modules.homeManager.quickshell = {
    inputs,
    pkgs,
    system,
    ...
  }: let
    qtPkgs = import inputs.nixpkgs-stable {inherit system;};
  in {
    home.packages = with qtPkgs; [
      inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default

      qt6.qt5compat
      qt6.qtbase
      qt6.qtquick3d
      qt6.qtwayland
      qt6.qtdeclarative
      qt6.qtsvg
      qt6.qtmultimedia
      qt6.qtimageformats

      qt5.qtgraphicaleffects
    ];

    # necessary environment variables
    home.sessionVariables = {
      QML_IMPORT_PATH = "${qtPkgs.qt6.qt5compat}/lib/qt-6/qml:${qtPkgs.qt6.qtbase}/lib/qt-6/qml";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };

    # make available to systemd units (optional)
    systemd.user.sessionVariables = {
      QML_IMPORT_PATH = "${qtPkgs.qt6.qt5compat}/lib/qt-6/qml:${qtPkgs.qt6.qtbase}/lib/qt-6/qml";
      QT_QPA_PLATFORM = "wayland;xcb";
    };
  };
}
