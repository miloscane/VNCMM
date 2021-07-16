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
    dpkg -i virtualgl_*.deb && rm virtualgl_2.6.5_amd64.deb && \
    dpkg -i turbovnc_*.deb && rm turbovnc_2.2.6_amd64.deb
## ------------------------ configure novnc -------------------------
RUN sed -i 's^<!-- end scripts -->^<script src="https://mobatec.cloud/resources/vnc/main.js?v=1.1"></script><!-- end scripts -->^' /usr/share/novnc/vnc.html && \
    wget https://mobatec.cloud/resources/vnc/favicon/favicon-16.png && mv favicon-16.png /usr/share/novnc/app/images/icons/novnc-16x16.png && \
    wget https://mobatec.cloud/resources/vnc/favicon/favicon-24.png && mv favicon-24.png /usr/share/novnc/app/images/icons/novnc-24x24.png && \
    wget https://mobatec.cloud/resources/vnc/favicon/favicon-32.png && mv favicon-32.png /usr/share/novnc/app/images/icons/novnc-32x32.png && \
    wget https://mobatec.cloud/resources/vnc/favicon/favicon-48.png && mv favicon-48.png /usr/share/novnc/app/images/icons/novnc-48x48.png && \
    wget https://mobatec.cloud/resources/vnc/favicon/favicon-60.png && mv favicon-60.png /usr/share/novnc/app/images/icons/novnc-60x60.png && \
    wget https://mobatec.cloud/resources/vnc/favicon/favicon-64.png && mv favicon-64.png /usr/share/novnc/app/images/icons/novnc-64x64.png && \
    wget https://mobatec.cloud/resources/vnc/favicon/favicon-72.png && mv favicon-72.png /usr/share/novnc/app/images/icons/novnc-72x72.png && \
    wget https://mobatec.cloud/resources/vnc/favicon/favicon-76.png && mv favicon-76.png /usr/share/novnc/app/images/icons/novnc-76x76.png && \
    wget https://mobatec.cloud/resources/vnc/favicon/favicon-96.png && mv favicon-96.png /usr/share/novnc/app/images/icons/novnc-96x96.png && \
    wget https://mobatec.cloud/resources/vnc/favicon/favicon-120.png && mv favicon-120.png /usr/share/novnc/app/images/icons/novnc-120x120.png && \
    wget https://mobatec.cloud/resources/vnc/favicon/favicon-144.png && mv favicon-144.png /usr/share/novnc/app/images/icons/novnc-144x144.png && \
    wget https://mobatec.cloud/resources/vnc/favicon/favicon-152.png && mv favicon-152.png /usr/share/novnc/app/images/icons/novnc-152x152.png && \
    wget https://mobatec.cloud/resources/vnc/favicon/favicon-192.png && mv favicon-192.png /usr/share/novnc/app/images/icons/novnc-192x192.png
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
## ------------------------ configure fluxbox -----------------------
RUN mkdir ~/.fluxbox && cd ~/.fluxbox && \
    wget https://mobatec.cloud/resources/vnc/Wallpaper.jpg && \
    echo "session.screen0.workspaces: 1"> ~/.fluxbox/init && \
    echo "session.screen0.toolbar.tools: clock, prevwindow, nextwindow, iconbar, systemtray">> ~/.fluxbox/init && \
    echo "# scroll on the desktop to change workspaces"> ~/.fluxbox/keys && \
    echo "[startup] {fbsetbg ~/.fluxbox/Wallpaper.jpg && wine ~/mm/Mobatec\ Modeller.exe}"> ~/.fluxbox/apps && \
    echo "[begin] (.-=:MENU:=-.)"> ~/.fluxbox/menu && \
    echo "[exec] (Mobatec Modeller) {wine ~/mm/Mobatec\ Modeller.exe}">> ~/.fluxbox/menu && \
    echo "[end]">> ~/.fluxbox/menu && \
    openssl req -x509 -nodes -newkey rsa:2048 -keyout ~/novnc.pem -out ~/novnc.pem -days 3650 -subj "/C=US/ST=NY/L=NY/O=NY/OU=NY/CN=NY emailAddress=email@example.com"
## ----------------------- configure BlackBox -----------------------
RUN mkdir ~/mm && cd ~/mm && \
    wget https://mobatec.cloud/resources/vnc/Mobatec-Modeller.zip && \
    unzip Mobatec-Modeller.zip
CMD export PORT=$PORT; /opt/TurboVNC/bin/vncserver && websockify -D --web=/usr/share/novnc/ --cert=~/novnc.pem $PORT :5901 && while true; do fluxbox; done