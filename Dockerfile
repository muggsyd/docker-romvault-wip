# Pull base image.
FROM jlesage/baseimage-gui:debian-11-v4

# environment settings
ENV PYTHONIOENCODING=utf-8
ENV APPNAME="ROMVault-WIP" UMASK_SET="022"
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ARG ROMVAULT_VERSION
ARG UID

RUN apt-get update -y 
RUN add-pkg --virtual apt-transport-https dirmngr gnupg ca-certificates libgtk2.0-0 fontconfig locales fonts-liberation gtk2-engines-pixbuf

# refresh system font cache
RUN fc-cache -f -v

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN echo "deb https://download.mono-project.com/repo/debian stable-buster main" | tee /etc/apt/sources.list.d/mono-official-stable.list

RUN sed -i'.bak' 's/$/ contrib/' /etc/apt/sources.list

RUN apt-get update -y && \
    apt-get install -y mono-xsp4 

RUN useradd -m -u $UID -g users -s /bin/bash romvault

RUN mkdir /opt/romvault
COPY files/graphics.zip /opt/romvault
COPY files/ROMVault*.exe /opt/romvault/ROMVault3.exe
RUN chown romvault /opt/romvault -R && chgrp users /opt/romvault -R && \
    chmod -R +x /opt/romvault

RUN sed-patch 's/<decor>no<\/decor>/<decor>yes<\/decor>/' /opt/base/etc/openbox/rc.xml.template
RUN sed-patch 's/<maximized>true<\/maximized>/<maximized>false<\/maximized>/' /opt/base/etc/openbox/rc.xml.template

# Copy the start script.
COPY startapp.sh /startapp.sh
