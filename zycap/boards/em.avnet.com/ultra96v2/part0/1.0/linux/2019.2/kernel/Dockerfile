FROM ubuntu:bionic

ARG XILINX_VER=rel-v2019.2

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
chrpath \
socat \
libsdl1.2-dev \
xterm \
repo

WORKDIR /usr/app

RUN mkdir ${HOME}/bin && cd ${HOME}/bin

# install repo
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > repo 
RUN chmod a+x repo 
RUN python3 repo --help

ENV PATH ${HOME}/bin:$PATH

RUN cd ${HOME}

RUN python3 repo init -u git://github.com/Xilinx/yocto-manifests.git -b "${XILINX_VER}"
RUN python3 repo sync && \
python3 repo start $XILINX_VER --all

# Fix 2019.2 bug (see https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18841862/Install+and+Build+with+Xilinx+Yocto)
RUN if [ "$XILINX_VER" = "rel-v2019.2" ]; then \
    sed -i "s#git://git.eclipse.org/gitroot/tcf/org.eclipse.tcf.agent.git;branch=master;protocol=https#git://git.eclipse.org/gitroot/tcf/org.eclipse.tcf.agent.git;branch=master;protocol=git#" \
    sources/meta-petalinux/recipes-devtools/tcf-agent/tcf-agent_%.bbappend; \
    fi 