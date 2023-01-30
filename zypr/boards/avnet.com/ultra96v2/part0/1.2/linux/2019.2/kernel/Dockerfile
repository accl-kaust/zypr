FROM ubuntu:bionic

ARG XILINX_VER=rel-v2019.2

ENV USER_NAME zycap

RUN apt-get update && apt-get install -y \
gawk \
wget \
git-core \
diffstat \
unzip \
curl \
texinfo \
gcc-multilib \
build-essential \
libncurses-dev \
chrpath \
socat \
libsdl1.2-dev \
xterm \
screen \
openssl \
repo \
locales \
nano \
cpio

# Correctly setup locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

# Add user
ARG host_uid=1000
ARG host_gid=1000
RUN groupadd -g $host_gid $USER_NAME && \
    useradd -g $host_gid -m -s /bin/bash -u $host_uid $USER_NAME

WORKDIR /usr/app 

RUN chown ${USER_NAME} /usr/app
RUN chown ${USER_NAME} /usr/bin


USER $USER_NAME

RUN mkdir /home/${USER_NAME}/build && chown ${USER_NAME} /home/${USER_NAME}/build


RUN cd /usr/bin

# install repo
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > repo 
RUN chmod a+x repo 
RUN python3 repo --help

ENV PATH /usr/bin:$PATH

RUN cd /usr/app

RUN python3 repo init -u git://github.com/Xilinx/yocto-manifests.git -b "${XILINX_VER}"
RUN python3 repo sync && \
python3 repo start $XILINX_VER --all

# Fix 2019.2 bug (see https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18841862/Install+and+Build+with+Xilinx+Yocto)
RUN if [ "$XILINX_VER" = "rel-v2019.2" ]; then \
    sed -i "s#git://git.eclipse.org/gitroot/tcf/org.eclipse.tcf.agent.git;branch=master;protocol=https#git://git.eclipse.org/gitroot/tcf/org.eclipse.tcf.agent.git;branch=master;protocol=git#" \
    sources/meta-petalinux/recipes-devtools/tcf-agent/tcf-agent_%.bbappend; \
    fi 

CMD source setupsdk ~/build && MACHINE=ultra96-zynqmp bitbake petalinux-image-minimal