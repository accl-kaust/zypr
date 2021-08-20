FROM   ubuntu:18.04

ENV    DEBIAN_FRONTEND=noninteractive
ENV    LC_ALL=en_US.UTF-8
ENV    LANG=en_US.UTF-8
ENV    LANGUAGE=en_US.UTF-8
ENV    TZ=Europe/London

ARG    installer_url="172.17.117.153:8000"
ARG    install_name="Xilinx_Unified_2019.2_1106_2127"
ARG    version=2019.2
ARG    user=zycap
ARG    username="a.r.bucknall@warwick.ac.uk"
ARG    password="WarwickTECH_2020"

RUN    adduser --disabled-password --gecos '' $user
RUN    mkdir -p /tools/Xilinx /home/$user/project
RUN    chown -R $user:$user /tools/Xilinx /home/$user/project

RUN \
    sed -i -e "s%http://[^ ]\+%http://ftp.jaist.ac.jp/pub/Linux/ubuntu/%g" /etc/apt/sources.list && \
    apt update && \
    apt upgrade -y && \
    apt -y --no-install-recommends install \
    ca-certificates curl sudo xorg dbus dbus-x11 ubuntu-gnome-default-settings gtk2-engines gpg \
    ttf-ubuntu-font-family fonts-ubuntu-font-family-console fonts-droid-fallback lxappearance locales && \
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales && echo "LANG=en_US.UTF-8" >> /etc/default/locale

# vivado
RUN \
    dpkg --add-architecture i386 && \
    apt update && \
    apt -y --no-install-recommends install \
    build-essential git gcc-multilib libc6-dev:i386 ocl-icd-opencl-dev libjpeg62-dev expect && \
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /home/$user/project
COPY   noninteractive-install.sh ./install/
COPY   config.txt ./install/
COPY   ${install_name}_Lin64.bin ./install/

RUN cd ./install && ./${install_name}_Lin64.bin --keep --noexec \
    --target Xil_installer

RUN cd ./install && chmod a+x noninteractive-install.sh && ./noninteractive-install.sh ${username} ${password}
