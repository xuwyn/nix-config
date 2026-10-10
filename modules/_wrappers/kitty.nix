{types, ...} @ adios: {
  inputs.zsh.from = {parent}: parent.zsh;
  options = {
    fontFamily = {
      type = types.string;
      default = "Maple Mono NF";
    };
    fontSize = {
      type = types.string;
      default = "8";
    };
    noctaliaThemeEnabled = {
      type = types.bool;
      default = false;
    };
    extraConfig = {
      type = types.string;
      default = "";
    };
    configFile.default = adios.promise ({
      options,
      inputs,
    }: let
      inherit (inputs.nixpkgs) pkgs;
      inherit (inputs.nixpkgs.lib) getExe;
    in
      pkgs.writeText "kitty.conf" ''
        include ${pkgs.kitty-themes}/share/kitty-themes/themes/Catppuccin-Mocha.conf

        font_family ${options.fontFamily}
        font_size ${options.fontSize}
        wheel_scroll_min_lines 1
        window_padding_width 4
        confirm_os_window_close 0
        scrollback_lines 10000
        enable_audio_bell no
        mouse_hide_wait 60
        cursor_trail 1
        tab_fade 1
        active_tab_font_style bold
        inactive_tab_font_style bold
        tab_bar_edge top
        tab_bar_margin_width 0
        tab_bar_style powerline
        enabled_layouts splits
        detect_urls yes
        allow_remote_control yes
        remember_window_size no
        initial_window_width 1024
        initial_window_height 720
        macos_titlebar_color background
        background_opacity 0.85
        background_blur 20
        shell ${getExe (inputs.zsh {})}

        symbol_map U+2190-U+21FF DejaVu Sans
        url_prefixes file ftp ftps gemini git gopher http https irc ircs kitty sftp ssh

        # Clipboard
        map ctrl+shift+v        paste_from_clipboard
        map ctrl+shift+c        copy_to_clipboard

        # Scrolling
        map ctrl+shift+up        scroll_line_up
        map ctrl+shift+down      scroll_line_down
        map ctrl+shift+k         scroll_line_up
        map ctrl+shift+j         scroll_line_down
        map ctrl+shift+page_up   scroll_page_up
        map ctrl+shift+page_down scroll_page_down
        map ctrl+shift+home      scroll_home
        map ctrl+shift+end       scroll_end
        map ctrl+shift+h         show_scrollback

        # Window management
        map alt+n               new_window_with_cwd
        map alt+w               close_window
        map ctrl+shift+enter    launch --location=hsplit
        map ctrl+shift+s        launch --location=vsplit
        map ctrl+shift+]        next_window
        map ctrl+shift+[        previous_window
        map ctrl+shift+f        move_window_forward
        map ctrl+shift+b        move_window_backward
        map ctrl+shift+`        move_window_to_top
        map ctrl+shift+1        first_window
        map ctrl+shift+2        second_window
        map ctrl+shift+3        third_window
        map ctrl+shift+4        fourth_window
        map ctrl+shift+5        fifth_window
        map ctrl+shift+6        sixth_window
        map ctrl+shift+7        seventh_window
        map ctrl+shift+8        eighth_window
        map ctrl+shift+9        ninth_window
        map ctrl+shift+0        tenth_window

        # Tab management
        map ctrl+shift+right    next_tab
        map ctrl+shift+left     previous_tab
        map ctrl+shift+t        new_tab
        map ctrl+shift+q        close_tab
        map ctrl+shift+l        next_layout
        map ctrl+shift+.        move_tab_forward
        map ctrl+shift+,        move_tab_backward

        map ctrl+shift+backspace restore_font_size

        ${options.extraConfig}

        ${ # enable dynamic theme last
          if options.noctaliaThemeEnabled
          then "include ~/.config/kitty/themes/noctalia.conf"
          else ""
        }
      '');
  };
}
