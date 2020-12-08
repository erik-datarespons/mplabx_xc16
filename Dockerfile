 FROM ubuntu:bionic

# AWS APT mirrors
RUN sed -i 's+http://security.ubuntu.com/+http://archive.ubuntu.com/+g' /etc/apt/sources.list \
 && sed -i 's+http://archive.ubuntu.com/+http://us-east-1.ec2.archive.ubuntu.com/+g' /etc/apt/sources.list \
 && apt update \
 && rm -rf /var/lib/apt/lists/*

# Install git and ssh
RUN apt update \
 && apt install -y git ssh-client \
 && rm -rf /var/lib/apt/lists/*

# Install dependencies
RUN apt update \
 && apt install -y --no-install-recommends curl make \
 && rm -rf /var/lib/apt/lists/*

# Install python modules
RUN apt update \
 && apt install -y python3 python3-pip python3-setuptools \
 && rm -rf /var/lib/apt/lists/* \
 && pip3 install --upgrade pip
RUN pip3 install glob2

# Download and install XC16 compiler
RUN curl -fSL -A "Mozilla/4.0" -o /tmp/xc16.run "http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.61-full-install-linux64-installer.run" \
 && chmod a+x /tmp/xc16.run \
 && /tmp/xc16.run --mode unattended --unattendedmodeui none \
    --netservername localhost --LicenseType FreeMode \
 && rm /tmp/xc16.run 
ENV PATH /opt/microchip/xc16/`ls /opt/microchip/xc16/ | awk '{print $1}'`/bin:$PATH

# Download and install MPLAB X IDE
# Use url: http://www.microchip.com/mplabx-ide-linux-installer to get the latest version
RUN curl -fSL -A "Mozilla/4.0" -o /tmp/mplabx-installer.tar "http://ww1.microchip.com/downloads/en/DeviceDoc/MPLABX-v5.45-linux-installer.tar" \
 && tar xf /tmp/mplabx-installer.tar && rm /tmp/mplabx-installer.tar \
 && USER=root ./*-installer.sh --nox11 \
    -- --unattendedmodeui none --mode unattended \
 && rm ./*-installer.sh 

# Add MPLABX build scripts
ADD mplabxBuildProject.py /usr/bin
RUN ln -s /usr/bin/mplabxBuildProject.py /usr/bin/mplabx-build-project
