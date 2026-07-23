FROM nvidia/cuda:12.6.3-cudnn-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive

LABEL image.name="cudnn-runtime-ubuntu24.04-vnc"

# Install desktop and VNC
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y  \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    dbus-x11 \
    xterm \
    sudo \
    wget \
    curl \
    nano \
    vim \
    python3 \
    python3-pip \
    git \
    locales \
    libgl1 \
    libglib2.0-0 \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create user
# RUN useradd -ms /bin/bash ubuntu && \
#     echo "ubuntu:ubuntu" | chpasswd && \
#     usermod -aG sudo ubuntu && \
#     echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# USER ubuntu
# WORKDIR /home/ubuntu

# Configure VNC
RUN mkdir -p ~/.vnc && \
    echo "ubuntu" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

RUN printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec dbus-launch --exit-with-session startxfce4\n' > ~/.vnc/xstartup && \
    chmod +x ~/.vnc/xstartup

EXPOSE 5901
CMD ["bash"]
# CMD ["vncserver", ":1", "-geometry", "1920x1080", "-depth", "24", "-fg"]
