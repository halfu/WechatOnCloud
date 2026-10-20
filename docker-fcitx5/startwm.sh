#!/usr/bin/env bash

# Enable Nvidia GPU support if detected
if which nvidia-smi >/dev/null 2>&1; then
  export LIBGL_KOPPER_DRI2=1
  export MESA_LOADER_DRIVER_OVERRIDE=zink
  export GALLIUM_DRIVER=zink
fi

# Chinese Input Method
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx
export GLFW_IM_MODULE=ibus

# Initialize MSIME state and models if not yet initialized
if [ ! -f "$HOME/.config/msime-client/runtime-options.json" ]; then
    rm -rf "$HOME/.config/msime-client"
    if command -v msime-linux-prepare >/dev/null 2>&1; then
        msime-linux-prepare --no-cloud-candidates --installed "$HOME/.config/msime-client" >/dev/null 2>&1 || true
        if [ -f "$HOME/.config/msime-client/runtime-options.json" ]; then
            sed -i 's/"neural_desktop": false/"neural_desktop": true/g' "$HOME"/.config/msime-client/*.json 2>/dev/null || true
            sed -i 's/"neural_keyboard": false/"neural_keyboard": true/g' "$HOME"/.config/msime-client/*.json 2>/dev/null || true
            if [ -f "/usr/share/msime-client/sentence-model-desktop.safetensors" ]; then
                python3 -c '
import json, os
p = os.path.expanduser("~/.config/msime-client/runtime-options.json")
if os.path.exists(p):
    with open(p, "r") as f: d = json.load(f)
    d["settled_model"] = "/usr/share/msime-client/sentence-model-desktop.safetensors"
    with open(p, "w") as f: json.dump(d, f, indent=2)
' 2>/dev/null || true
            fi
        fi
    fi
fi

# Ensure fcitx5 profile defaults to msime
if [ -f "$HOME/.config/fcitx5/profile" ]; then
    if ! grep -q "msime" "$HOME/.config/fcitx5/profile"; then
        sed -i 's/DefaultIM=pinyin/DefaultIM=msime/g' "$HOME/.config/fcitx5/profile"
        sed -i 's/Name=pinyin/Name=msime/g' "$HOME/.config/fcitx5/profile"
    fi
fi

# Ensure classicui.conf exists and defaults to Theme=default (avoids black shadow halo on X11)
mkdir -p "$HOME/.config/fcitx5/conf"
if [ ! -f "$HOME/.config/fcitx5/conf/classicui.conf" ]; then
    cp /etc/xdg/fcitx5/conf/classicui.conf "$HOME/.config/fcitx5/conf/classicui.conf" 2>/dev/null || true
else
    sed -i 's/^Theme=.*/Theme=default/g' "$HOME/.config/fcitx5/conf/classicui.conf" 2>/dev/null || true
fi

# Ensure safe tint2 settings (disable modal wm_menu grabs and prevent top-layer overlap)
if [ -f "$HOME/.config/tint2/tint2rc" ]; then
    sed -i 's/^wm_menu = .*/wm_menu = 0/g' "$HOME/.config/tint2/tint2rc" 2>/dev/null || true
    sed -i 's/^panel_layer = .*/panel_layer = bottom/g' "$HOME/.config/tint2/tint2rc" 2>/dev/null || true
fi

# Start X11 compositing manager for true 32-bit ARGB alpha transparency
if command -v xcompmgr >/dev/null 2>&1; then
    pgrep -u abc xcompmgr >/dev/null 2>&1 || xcompmgr &
fi

if [ -z "unix:path=/run/user/1000/bus" ]; then
    dbus_file=$(ls -t /config/.dbus/session-bus/*-1 2>/dev/null | head -n 1)
    [ -n "$dbus_file" ] && . "$dbus_file"
fi

/usr/bin/openbox-session
