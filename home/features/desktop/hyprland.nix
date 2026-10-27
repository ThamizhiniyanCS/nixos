{ lib, ... }:
let
  h = import ./hypr-lib.nix { inherit lib; };
  terminal = "kitty";
  fileManager = "nautilus";
  menu = "hyprlauncher";
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;

    settings = {
      monitor = [
        (h.monitor "Virtual-1" {
          mode = "1920x1080@60";
          position = "0x1";
          scale = 1;
        })
      ];

      env = h.envs {
        XCURSOR_SIZE = 24;
        HYPRCURSOR_SIZE = 24;
      };

      on = h.onStart [
        "kitty"
        "waybar"
      ];

      config = {
        general = {
          gaps_in = 5;
          gaps_out = 20;
          border_size = 2;
          col = {
            active_border = h.gradient [ "rgba(33ccffee)" "rgba(00ff99ee)" ] 45;
            inactive_border = "rgba(595959aa)";
          };
          resize_on_border = false;
          allow_tearing = false;
          layout = "dwindle";
        };
        decoration = {
          rounding = 10;
          rounding_power = 2;
          active_opacity = 1.0;
          inactive_opacity = 1.0;
          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = h.hexColor "0xee1a1a1a";
          };
          blur = {
            enabled = true;
            size = 3;
            passes = 1;
            vibrancy = 0.1696;
          };
        };
        animations.enabled = true;
        dwindle.preserve_split = true;
        master.new_status = "master";
        scrolling.fullscreen_on_one_column = true;
        misc = {
          force_default_wallpaper = -1;
          disable_hyprland_logo = false;
        };
        input = {
          kb_layout = "us";
          follow_mouse = 1;
          sensitivity = 0;
          touchpad.natural_scroll = false;
        };
      };

      curve = h.defaultCurves;
      animation = h.defaultAnimations;

      gesture = [ (h.gesture 3 "horizontal" "workspace") ];
      device = [ (h.device "epic-mouse-v1" { sensitivity = -0.5; }) ];

      bind = [
        (h.exec (h.mod "T") terminal)
        (h.bind (h.mod "W") h.d.close)
        (h.exec (h.mod "M") "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
        (h.exec (h.mod "E") fileManager)
        (h.bind (h.mod "V") h.d.float)
        (h.exec (h.mod "R") menu)
        (h.bind (h.mod "P") h.d.pseudo)
        (h.bind (h.mod "J") (h.d.layout "togglesplit"))

        # your own binds
        # (h.exec (h.mod "F") "librewolf")
        # (h.exec "CONTROL + ALT + T" "wezterm")
      ]
      ++ h.focusArrows h.mainMod
      ++ h.workspaceBinds { }
      ++ h.specialWorkspace "magic" "S"
      ++ h.workspaceScroll
      ++ h.mouseBinds
      ++ h.volumeKeys { }
      ++ h.brightnessKeys { }
      ++ h.playerKeys;

      window_rule = [
        (h.windowRule "suppress-maximize-events" { class = ".*"; } { suppress_event = "maximize"; })
        (h.windowRule "fix-xwayland-drags" {
          class = "^$";
          title = "^$";
          xwayland = true;
          float = true;
          fullscreen = false;
          pin = false;
        } { no_focus = true; })
        (h.windowRule "move-hyprland-run" { class = "hyprland-run"; } {
          move = "20 monitor_h-120";
          float = true;
        })
      ];
    };
  };
}
