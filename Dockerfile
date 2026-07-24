# syntax=docker/dockerfile:1
FROM nvidia/cuda:12.6.3-cudnn-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
LABEL image.name="cudnn-runtime-ubuntu24.04-vnc"

# Install desktop, VNC server, and base tools
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    dbus-x11 \
    wget \
    curl \
    nano \
    vim \
    python3 \
    python3-pip \
    python3-venv \
    git \
    locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure VNC workspace defaults
RUN mkdir -p /root/.vnc && \
    echo "localhost=no" > /root/.vnc/config && \
    echo "-AlwaysShared" >> /root/.vnc/config
# Create XFCE startup script
COPY <<-'EOF' /root/.vnc/xstartup
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec dbus-launch --exit-with-session startxfce4
EOF
RUN chmod +x /root/.vnc/xstartup

# Create runtime startup script
COPY <<-'EOF' /start-vnc.sh
#!/bin/bash

# Clean up stale locks from prior runs
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1
vncserver -kill :1 >/dev/null 2>&1 || true


# Start TigerVNC server on display :1
vncserver :1 -AlwaysShared -localhost no -geometry 1920x1080

# Tail VNC logs to keep container alive and route logs to docker logs
tail -f /root/.vnc/*.log
EOF
RUN chmod +x /start-vnc.sh

# Set hardcoded root user password
RUN echo "root:123456" | chpasswd

# Create pre-configured VNC password file using -f (filter mode)
RUN echo "123456" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd




EXPOSE 5901

CMD ["/start-vnc.sh"]
