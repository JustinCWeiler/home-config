{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "spotify"
    ];

  nixpkgs.overlays = [
    inputs.nixpkgs-wayland.overlay
  ];

  home = rec {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    username = "justinw";
    homeDirectory = "/home/justinw";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "25.05"; # Please read the comment before changing.

    # The packages option allows you to install Nix packages into your
    # environment.
    packages = with pkgs; [
      # # Adds the 'hello' command to your environment. It prints a friendly
      # # "Hello, world!" when run.
      # pkgs.hello

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      #(pkgs.writeShellScriptBin "my-hello" ''
      #  echo "Hello, ${config.home.username}!"
      #'')
      htop
      qbittorrent
      protonvpn-gui
      vlc
      #spotify
      wev
      xorg.xset
      calc
      units
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      #".gradle/gradle.properties".text = ''
      #  org.gradle.console=verbose
      #  org.gradle.daemon.idletimeout=3600000
      #'';

      ".nix".source = config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/.config/home-manager/";
      ".wallpaper".source = pkgs.fetchurl {
        url = "https://archive.org/download/theoriginalfilesofsomewindowswallpapers/bliss%20600dpi.tif";
        hash = "sha256-jyW25K4XB/lOR4UMEKfB19QqsuU3X1OPBAi1MmJes/g=";
      };
    };

    pointerCursor = {
      enable = true;
      sway.enable = true;
      name = "Hackneyed";
      size = 24;
      package = pkgs.hackneyed;
    };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #
    # ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    # ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    # /etc/profiles/per-user/justinw/etc/profile.d/hm-session-vars.sh
    #
  };

  programs =
    let
      aliases = {
        ls = "ls --color=tty";
        psa = "ps -ef";
        gits = "git status";
        gitl = "git log --oneline";
        gitd = "git diff";
        feh = "feh -.";
        reboot = "systemctl reboot";
        poweroff = "systemctl poweroff";
      };
    in
    {
      home-manager.enable = true;
      firefox.enable = true;
      spotify-player.enable = true;
      feh.enable = true;

      foot = {
        enable = true;
      };

      git = {
        enable = true;

        settings = {
          user = {
            email = "justincweiler@gmail.com";
            name = "Justin W";
          };
          init = {
            defaultBranch = "main";
          };
        };

        ignores = [
          "/result"
        ];
      };

      zsh = {
        enable = true;
        #zprof.enable = true;

        shellAliases = aliases;

        localVariables = {
          LESS = "-i -M -R -S -w -X -z-4";
        };

        sessionVariables = {
          GIT_EDITOR = "vim";
        };

        prezto = {
          enable = true;

          editor.keymap = "vi";

          prompt.pwdLength = "long";
        };

        autosuggestion.enable = true;

        # TODO fixme
        historySubstringSearch.enable = true;

        initContent = ''
          unalias rm
        '';
      };

      bash = {
        enable = true;

        shellAliases = aliases;
      };

      nvf = {
        enable = true;

        settings.vim = {
          viAlias = false;
          vimAlias = true;

          lineNumberMode = "relNumber";

          autocmds = [
            {
              enable = true;
              event = [ "BufReadPost" ];
              command = ''if line("'\"") <= line("$") | execute "normal! g`\"" | else | execute "normal! G" | endif'';
            }
          ];

          keymaps = [
            # use ; as :
            {
              key = ";";
              action = ":";
              mode = [
                "n"
                "v"
              ];
            }
            # scroll left and right
            {
              key = "<C-h>";
              action = "20zh";
              mode = [ "n" ];
            }
            {
              key = "<C-l>";
              action = "20zl";
              mode = [ "n" ];
            }
          ];

          options = {
            mouse = "";

            wrap = false;

            expandtab = false;
          };

          lsp = {
            enable = true;
            formatOnSave = true;
          };

          languages = {
            enableFormat = true;
            enableExtraDiagnostics = true;

            nix = {
              enable = true;

              format.type = [ "nixfmt" ];
            };

            haskell = {
              enable = true;
            };
          };
        };
      };

      lutris = {
        enable = true;

        steamPackage = inputs.nix-config.outputs.nixosConfigurations.yedevsky.config.programs.steam.package;
      };
    };

  wayland.windowManager.sway = {
    enable = true;

    extraOptions = [
      "--unsupported-gpu"
    ];

    checkConfig = false;

    config = rec {
      modifier = "Mod4";
      up = "k";
      down = "j";
      left = "h";
      right = "l";

      terminal = "foot";
      defaultWorkspace = "workspace number 1";

      keybindings = lib.mkOptionDefault {
        "${modifier}+shift+f" = "exec firefox";
        "${modifier}+shift+p" = "exec firefox --private-window";

        "${modifier}+shift+alt+${up}" = "move workspace to up";
        "${modifier}+shift+alt+${down}" = "move workspace to down";
        "${modifier}+shift+alt+${left}" = "move workspace to left";
        "${modifier}+shift+alt+${right}" = "move workspace to right";

        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";

        "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
      };

      #bindswitches = let laptop = "eDP-1"; in {
      #  "lid:on" = {
      #    reload = true;
      #    locked = true;
      #    action = "output ${laptop} disable";
      #  };
      #  "lid:off" = {
      #    reload = true;
      #    locked = true;
      #    action = "output ${laptop} enable";
      #  };
      #};

      seat."*" = {
        hide_cursor = "3000";
      };

      startup = [
        { command = "protonvpn-app"; }
        { command = "steam"; }
      ];

      assigns = {
        "8" = [
          { class = "steam"; }
          { title = "Steam"; }
        ];
        "10" = [
          { app_id = "protonvpn-app"; }
          { app_id = "org.qbittorrent.qBittorrent"; }
        ];
      };

      input = {
        "type:touchpad" = {
          natural_scroll = "enabled";
          tap = "enabled";
          tap_button_map = "lrm";
          click_method = "clickfinger";
          clickfinger_button_map = "lrm";
          accel_profile = "adaptive";
          pointer_accel = "0";
          dwt = "false";
        };
      };

      output =
        let
          background = "~/.wallpaper fill";
        in
        {
          ## xps 15 laptop monitor (root screen)
          #"eDP-1" = {
          #  mode = "3840x2160@59.997Hz";
          #  scale = "2";
          #  scale_filter = "nearest";
          #  pos = "0 0";
          #};

          # framework 16 laptop monitor (root screen)
          "eDP-1" = {
            mode = "2560x1600@165.000Hz";
            scale = "1.5";
            scale_filter = "smart";
            pos = "0 0";
            inherit background;
          };

          # old tv
          #"DP-3" = {
          #  mode = "1920x1080@60.000Hz";
          #  scale = "1.5";
          #  scale_filter = "smart";
          #  pos = "213 -720";
          #  inherit background;
          #};

          # tv 2
          "DP-3" = {
            mode = "3840x2160@60.000Hz";
            scale = "3";
            scale_filter = "smart";
            pos = "213 -720";
            hdr = "on";
            inherit background;
          };
        };
    };
  };

  services = {
    spotifyd.enable = true;
    network-manager-applet.enable = true;
  };

  # flakes
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
