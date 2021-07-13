# https://mmvnc2.herokuapp.com/vnc.html

FROM ubuntu
LABEL Vendor="Mobatec"
MAINTAINER Mobatec
ENV PASSWORD=M0batec1
ENV DEBIAN_FRONTEND=noninteractive 
ENV DEBCONF_NONINTERACTIVE_SEEN=true
ENV DISPLAY=:1
RUN dpkg --add-architecture i386 && \
    apt-get update
RUN echo "tzdata tzdata/Areas select America" > ~/tx.txt && \
    echo "tzdata tzdata/Zones/America select New York" >> ~/tx.txt && \
    debconf-set-selections ~/tx.txt && \
    apt-get install -y gnupg apt-transport-https wget software-properties-common fluxbox novnc websockify libxv1 libglu1-mesa xauth x11-utils xorg tightvncserver
RUN wget https://deac-fra.dl.sourceforge.net/project/virtualgl/2.6.5/virtualgl_2.6.5_amd64.deb && \
    wget https://nav.dl.sourceforge.net/project/turbovnc/2.2.6/turbovnc_2.2.6_amd64.deb && \
    dpkg -i virtualgl_*.deb && \
    dpkg -i turbovnc_*.deb && \
    sed -i 's^<!-- end scripts -->^<script src="https://mobatec.nl/TEMP/docker.js"></script>^' /usr/share/novnc/vnc.html
## ------------------- wine and helpful additions -------------------
RUN apt-get install -y wine fonts-wine winetricks ttf-mscorefonts-installer winbind
## ---------------- run the image as a non-root user ----------------
RUN useradd -ms /bin/bash mobatec
USER mobatec
WORKDIR /home/mobatec
## --------------------- configure VNC password ---------------------
RUN mkdir ~/.vnc && \
    echo $PASSWORD | vncpasswd -f > ~/.vnc/passwd && \
    chmod 0600 ~/.vnc/passwd
RUN mkdir ~/.fluxbox && \
    echo "[startup] {wine ~/mm/Mobatec\ Modeller.exe}"> ~/.fluxbox/apps && \
    echo "[begin] (.-=:MENU:=-.)"> ~/.fluxbox/menu && \
    echo "[exec] (Mobatec Modeller) {wine ~/mm/Mobatec\ Modeller.exe}">> ~/.fluxbox/menu && \
    echo "[end]">> ~/.fluxbox/menu && \
    openssl req -x509 -nodes -newkey rsa:2048 -keyout ~/novnc.pem -out ~/novnc.pem -days 3650 -subj "/C=US/ST=NY/L=NY/O=NY/OU=NY/CN=NY emailAddress=email@example.com"
RUN mkdir ~/mm && \
    cd ~/mm && \
    wget https://mobatec.nl/TEMP/Mobatec-Modeller2.zip && \
    unzip Mobatec-Modeller2.zip
CMD export PORT=$PORT; /opt/TurboVNC/bin/vncserver && websockify -D --web=/usr/share/novnc/ --cert=~/novnc.pem $PORT :5901 && while true; do fluxbox; done
