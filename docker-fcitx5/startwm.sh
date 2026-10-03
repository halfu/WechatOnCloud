#!/usr/bin/env bash

# Enable Nvidia GPU support if detected
if which nvidia-smi; then
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

if [ -z "unix:path=/run/user/1000/bus" ]; then
    dbus_file=$(ls -t /config/.dbus/session-bus/*-1 2>/dev/null | head -n 1)
    [ -n "$dbus_file" ] && . "$dbus_file"
fi

/usr/bin/openbox-session
