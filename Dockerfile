FROM quay.io/centos/centos:stream8

# Clean the cache and ensure the package metadata is up to date
RUN dnf clean all & dnf makecache

# Update the system and install necessary tools
RUN dnf -y update && \
    dnf -y install wget bzip2 unzip git mesa-dri-drivers

# Install Qt libraries and related packages
RUN dnf -y install libxcb libX11-xcb xcb-util-image xcb-util-wm

# Install newest version of Anaconda
RUN wget https://repo.anaconda.com/archive/Anaconda3-2023.03-1-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# Install newest version of PyCharm
RUN wget https://download.jetbrains.com/python/pycharm-community-2023.1.2.tar.gz -O ~/pycharm.tar.gz && \
    tar -xzvf ~/pycharm.tar.gz -C /opt && \
    rm ~/pycharm.tar.gz
# https://download.jetbrains.com/python/pycharm-community-2023.1.2.tar.gz?_ga=2.1762933.594168665.1687204458-547764338.1686247515&_gl=1*1hpk8kf*_ga*NTQ3NzY0MzM4LjE2ODYyNDc1MTU.*_ga_9J976DJZ68*MTY4NzIwNDQ1OC44LjEuMTY4NzIwNDU0My41OS4wLjA.

# Install the newest version of KLayout
RUN wget https://www.klayout.org/downloads/CentOS_8/klayout-0.28.9-0.x86_64.rpm -O ~/klayout.rpm && \
    yum -y localinstall ~/klayout.rpm && \
    rm ~/klayout.rpm
#https://www.klayout.org/downloads/CentOS_8/klayout-0.28.9-0.x86_64.rpm

# Clone SiEPIC-Tools and SiEPIC_EBeam_PDK 
RUN mkdir -p /root/.klayout/salt && \
    cd /root/.klayout/salt && \
    git clone https://github.com/SiEPIC/SiEPIC-Tools.git && \
    git clone https://github.com/SiEPIC/SiEPIC_EBeam_PDK.git

# Set the working directory
WORKDIR /home

# Set PATH
ENV PATH /opt/conda/bin:$PATH
ENV DISPLAY=:0

# Copy files to working directory
COPY klayout/EBeam/pymacros/pcells_EBeam /home/pcells_EBeam
COPY klayout/EBeam/pymacros/EBeam_Lib_PCellTests.py /home
