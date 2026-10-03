ARG UPSTREAM_TAG=1.5.1
FROM ghcr.io/gloridust/wechat-on-cloud:${UPSTREAM_TAG}

# Install fcitx5, Chinese addons, IM frontends, and tint2 taskbar
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      fcitx5 \
      fcitx5-chinese-addons \
      fcitx5-frontend-gtk2 \
      fcitx5-frontend-gtk3 \
      fcitx5-frontend-gtk4 \
      fcitx5-frontend-qt5 \
      tint2 && \
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
COPY autostart /etc/xdg/openbox/autostart
COPY fcitx5.sh /etc/profile.d/fcitx5.sh
COPY startwm.sh /defaults/startwm.sh

RUN chmod +x /etc/xdg/openbox/autostart /defaults/startwm.sh
