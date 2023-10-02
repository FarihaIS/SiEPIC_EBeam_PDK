FROM quay.io/centos/centos:stream8

# Update the system and install necessary tools
RUN dnf -y update && \
    dnf -y install wget bzip2 unzip git mesa-dri-drivers

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

# Install the newest version of KLayout
RUN wget https://www.klayout.org/downloads/CentOS_8/klayout-0.28.12-0.x86_64.rpm -O ~/klayout.rpm && \
    yum -y localinstall ~/klayout.rpm && \
    rm ~/klayout.rpm

# Clone SiEPIC-Tools and SiEPIC_EBeam_PDK 
RUN mkdir -p /root/.klayout/salt && \
    cd /root/.klayout/salt && \
    git clone https://github.com/SiEPIC/SiEPIC-Tools.git && \
    git clone https://github.com/SiEPIC/SiEPIC_EBeam_PDK.git

# Set the working directory
WORKDIR /home

# Set PATH
ENV PATH /opt/conda/bin:$PATH
ENV QT_QPA_PLUGIN=minimal

# Copy files to working directory
COPY klayout/EBeam/pymacros/pcells_EBeam /home/pcells_EBeam
COPY klayout/EBeam/pymacros/EBeam_Lib_PCellTests.py /home
