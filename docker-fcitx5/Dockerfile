ARG UPSTREAM_TAG=1.5.1
FROM ghcr.io/gloridust/wechat-on-cloud:${UPSTREAM_TAG}

# Install fcitx5, Chinese addons, IM frontends, tint2 taskbar, xcompmgr compositor, and Metasequoia IME (MSIME / chinese-ime-lm)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      fcitx5 \
      fcitx5-chinese-addons \
      fcitx5-frontend-gtk2 \
      fcitx5-frontend-gtk3 \
      fcitx5-frontend-gtk4 \
      fcitx5-frontend-qt5 \
      tint2 \
      xcompmgr \
      curl \
      ca-certificates \
      python3 && \
    curl -fsSL -o /tmp/msime.deb https://dl.msime.app/releases/msime/linux-v0.12.1/msime-linux_0.12.1_amd64.deb && \
    apt-get install -y --no-install-recommends /tmp/msime.deb && \
    rm -f /tmp/msime.deb && \
    python3 /usr/bin/msime-linux-setup --download --resources /usr/share/msime-client/resources --no-register && \
    curl -fsSL -o /usr/share/msime-client/sentence-model-desktop.safetensors https://dl.msime.app/gh/https://github.com/metasequoiaime/chinese-ime-lm/releases/download/model-v1/sentence-model-desktop.safetensors && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Global environment variables for IME
ENV GTK_IM_MODULE=fcitx \
    QT_IM_MODULE=fcitx \
    XMODIFIERS=@im=fcitx \
    SDL_IM_MODULE=fcitx \
    GLFW_IM_MODULE=ibus

# Copy configuration and startup scripts
COPY profile /etc/xdg/fcitx5/profile
COPY classicui.conf /etc/xdg/fcitx5/conf/classicui.conf
COPY autostart /etc/xdg/openbox/autostart
COPY fcitx5.sh /etc/profile.d/fcitx5.sh
COPY startwm.sh /defaults/startwm.sh
COPY patch-qq.py /tmp/patch-qq.py

RUN python3 /tmp/patch-qq.py && rm -f /tmp/patch-qq.py && \
    mkdir -p /etc/xdg/fcitx5/conf && \
    sed -i 's/^wm_menu = .*/wm_menu = 0/g' /etc/xdg/tint2/tint2rc 2>/dev/null || true && \
    sed -i 's/^panel_layer = .*/panel_layer = bottom/g' /etc/xdg/tint2/tint2rc 2>/dev/null || true

RUN chmod +x /etc/xdg/openbox/autostart /defaults/startwm.sh
