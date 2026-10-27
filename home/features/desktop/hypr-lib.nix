{ lib }:
let
  inherit (lib)
    concatMapStringsSep
    concatStringsSep
    mapAttrsToList
    optional
    ;
  lua = lib.generators.mkLuaInline;
  # Nix value -> Lua literal (strings are JSON-escaped, mkLuaInline passes through)
  toL = lib.generators.toLua { multiline = false; };
in
rec {
  inherit lua toL;

  # ── Generic Lua call builders ─────────────────────────────
  # call "hl.dsp.focus" [ { direction = "left"; } ]
  call = fn: args: lua "${fn}(${concatMapStringsSep ", " toL args})";
  dsp = path: args: call "hl.dsp.${path}" args;

  # ── Dispatchers (the "action" half of a bind) ─────────────
  d = {
    exec = cmd: dsp "exec_cmd" [ cmd ];
    close = dsp "window.close" [ ];
    float = dsp "window.float" [ { action = "toggle"; } ];
    pseudo = dsp "window.pseudo" [ ];
    drag = dsp "window.drag" [ ];
    resize = dsp "window.resize" [ ];
    exit = dsp "exit" [ ];
    layout = msg: dsp "layout" [ msg ];
    focusDir = dir: dsp "focus" [ { direction = dir; } ];
    focusWs = ws: dsp "focus" [ { workspace = ws; } ];
    moveToWs = ws: dsp "window.move" [ { workspace = ws; } ];
    toggleSpecial = name: dsp "workspace.toggle_special" [ name ];
    moveToSpecial = name: dsp "window.move" [ { workspace = "special:${name}"; } ];
    raw = s: lua s; # escape hatch for anything else
  };

  # ── Keys / modifiers ──────────────────────────────────────
  mainMod = "ALT";
  keys = mods: key: concatStringsSep " + " (mods ++ [ key ]);
  mod = keys [ mainMod ];
  modShift = keys [
    mainMod
    "SHIFT"
  ];
  modAlt = keys [
    mainMod
    "ALT"
  ];
  modCtrl = keys [
    mainMod
    "CONTROL"
  ];

  # ── Binds ─────────────────────────────────────────────────
  bindWith = opts: key: action: {
    _args = [
      key
      action
    ]
    ++ optional (opts != { }) opts;
  };
  bind = bindWith { };
  bindl = bindWith { locked = true; };
  bindle = bindWith {
    locked = true;
    repeating = true;
  };
  bindm = bindWith { mouse = true; };

  exec = key: cmd: bind key (d.exec cmd);
  execl = key: cmd: bindl key (d.exec cmd);
  execle = key: cmd: bindle key (d.exec cmd);

  # ── Bind generators ───────────────────────────────────────
  # mod + [1-9,0] focus, mod + SHIFT + [1-9,0] move window
  workspaceBinds =
    {
      count ? 10,
      main ? mainMod,
    }:
    lib.concatMap (
      i:
      let
        key = toString (lib.mod i 10);
      in
      [
        (bind (keys [ main ] key) (d.focusWs i))
        (bind (keys [ main "SHIFT" ] key) (d.moveToWs i))
      ]
    ) (lib.range 1 count);

  focusArrows =
    main:
    map (dir: bind (keys [ main ] dir) (d.focusDir dir)) [
      "left"
      "right"
      "up"
      "down"
    ];

  specialWorkspace = name: key: [
    (bind (mod key) (d.toggleSpecial name))
    (bind (modShift key) (d.moveToSpecial name))
  ];

  workspaceScroll = [
    (bind (mod "mouse_down") (d.focusWs "e+1"))
    (bind (mod "mouse_up") (d.focusWs "e-1"))
  ];

  mouseBinds = [
    (bindm (mod "mouse:272") d.drag)
    (bindm (mod "mouse:273") d.resize)
  ];

  volumeKeys =
    {
      step ? "5%",
      limit ? 1,
    }:
    [
      (execle "XF86AudioRaiseVolume" "wpctl set-volume -l ${toString limit} @DEFAULT_AUDIO_SINK@ ${step}+")
      (execle "XF86AudioLowerVolume" "wpctl set-volume @DEFAULT_AUDIO_SINK@ ${step}-")
      (execle "XF86AudioMute" "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
      (execle "XF86AudioMicMute" "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
    ];

  brightnessKeys =
    {
      step ? "5%",
    }:
    [
      (execle "XF86MonBrightnessUp" "brightnessctl -e4 -n2 set ${step}+")
      (execle "XF86MonBrightnessDown" "brightnessctl -e4 -n2 set ${step}-")
    ];

  playerKeys = [
    (execl "XF86AudioNext" "playerctl next")
    (execl "XF86AudioPause" "playerctl play-pause")
    (execl "XF86AudioPlay" "playerctl play-pause")
    (execl "XF86AudioPrev" "playerctl previous")
  ];

  # ── Environment ───────────────────────────────────────────
  env = name: value: {
    _args = [
      name
      (toString value)
    ];
  };
  envs = attrs: mapAttrsToList env attrs;

  # ── Look and feel ─────────────────────────────────────────
  gradient = colors: angle: { inherit colors angle; };
  hexColor = s: lua s; # e.g. hexColor "0xee1a1a1a"

  bezier = name: points: {
    _args = [
      name
      {
        type = "bezier";
        inherit points;
      }
    ];
  };
  spring =
    name:
    {
      mass ? 1,
      stiffness,
      dampening,
    }:
    {
      _args = [
        name
        {
          type = "spring";
          inherit mass stiffness dampening;
        }
      ];
    };

  animation =
    leaf: attrs:
    {
      inherit leaf;
      enabled = true;
    }
    // attrs;

  defaultCurves = [
    (bezier "easeOutQuint" [
      [
        0.23
        1
      ]
      [
        0.32
        1
      ]
    ])
    (bezier "easeInOutCubic" [
      [
        0.65
        0.05
      ]
      [
        0.36
        1
      ]
    ])
    (bezier "linear" [
      [
        0
        0
      ]
      [
        1
        1
      ]
    ])
    (bezier "almostLinear" [
      [
        0.5
        0.5
      ]
      [
        0.75
        1
      ]
    ])
    (bezier "quick" [
      [
        0.15
        0
      ]
      [
        0.1
        1
      ]
    ])
    (spring "easy" {
      stiffness = 238.1191;
      dampening = 24.21279333;
    })
  ];

  defaultAnimations = [
    (animation "global" {
      speed = 10;
      bezier = "default";
    })
    (animation "border" {
      speed = 5.39;
      bezier = "easeOutQuint";
    })
    (animation "windows" {
      speed = 4.79;
      spring = "easy";
    })
    (animation "windowsIn" {
      speed = 4.1;
      spring = "easy";
      style = "popin 87%";
    })
    (animation "windowsOut" {
      speed = 1.49;
      bezier = "linear";
      style = "popin 87%";
    })
    (animation "fadeIn" {
      speed = 1.73;
      bezier = "almostLinear";
    })
    (animation "fadeOut" {
      speed = 1.46;
      bezier = "almostLinear";
    })
    (animation "fade" {
      speed = 3.03;
      bezier = "quick";
    })
    (animation "layers" {
      speed = 3.81;
      bezier = "easeOutQuint";
    })
    (animation "layersIn" {
      speed = 4;
      bezier = "easeOutQuint";
      style = "fade";
    })
    (animation "layersOut" {
      speed = 1.5;
      bezier = "linear";
      style = "fade";
    })
    (animation "fadeLayersIn" {
      speed = 1.79;
      bezier = "almostLinear";
    })
    (animation "fadeLayersOut" {
      speed = 1.39;
      bezier = "almostLinear";
    })
    (animation "workspaces" {
      speed = 1.94;
      bezier = "almostLinear";
      style = "fade";
    })
    (animation "workspacesIn" {
      speed = 1.21;
      bezier = "almostLinear";
      style = "fade";
    })
    (animation "workspacesOut" {
      speed = 1.94;
      bezier = "almostLinear";
      style = "fade";
    })
    (animation "zoomFactor" {
      speed = 7;
      bezier = "quick";
    })
  ];

  # ── Monitors, devices, gestures ───────────────────────────
  monitor =
    output: attrs:
    {
      inherit output;
      mode = "preferred";
      position = "auto";
      scale = "auto";
    }
    // attrs;
  device = name: attrs: { inherit name; } // attrs;
  gesture = fingers: direction: action: { inherit fingers direction action; };

  # ── Rules ─────────────────────────────────────────────────
  windowRule =
    name: match: attrs:
    { inherit name match; } // attrs;
  layerRule =
    name: match: attrs:
    { inherit name match; } // attrs;
  workspaceRule = workspace: attrs: { inherit workspace; } // attrs;

  # "No gaps when only" preset
  smartGaps = {
    workspace_rule = [
      (workspaceRule "w[tv1]" {
        gaps_out = 0;
        gaps_in = 0;
      })
      (workspaceRule "f[1]" {
        gaps_out = 0;
        gaps_in = 0;
      })
    ];
    window_rule = [
      (windowRule "no-gaps-wtv1"
        {
          float = false;
          workspace = "w[tv1]";
        }
        {
          border_size = 0;
          rounding = 0;
        }
      )
      (windowRule "no-gaps-f1"
        {
          float = false;
          workspace = "f[1]";
        }
        {
          border_size = 0;
          rounding = 0;
        }
      )
    ];
  };

  # ── Permissions ───────────────────────────────────────────
  permission = regex: type: mode: {
    _args = [
      regex
      type
      mode
    ];
  };

  # ── Events / autostart ────────────────────────────────────
  on = event: body: {
    _args = [
      event
      (lua "function()\n${body}\nend")
    ];
  };
  onStart = cmds: on "hyprland.start" (concatMapStringsSep "\n" (c: "  hl.exec_cmd(${toL c})") cmds);
}
