FROM ubuntu:20.04

LABEL AboutImage "p2proapp"

LABEL Maintainer "p2proapp"

ARG DEBIAN_FRONTEND=noninteractive

#VNC Server Password
ENV	VNC_PASS="samplepass" \
#VNC Server Title(w/o spaces)
	VNC_TITLE="Vubuntu_Desktop" \
#VNC Resolution(720p is preferable)
	VNC_RESOLUTION="1600x900" \
#VNC Shared Mode (0=off, 1=on)
	VNC_SHARED=0 \
#Local Display Server Port
	DISPLAY=:0 \
#NoVNC Port
	NOVNC_PORT=$PORT \
#Ngrok Token (Strictly use private token if using the service)
	NGROK_AUTH_TOKEN="1Zi3HFhCxa3fRktJZHgZt8gxyNK_62zc3D5Ye2T6ff9Pokn3v" \
#Locale
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8 \
	LC_ALL=C.UTF-8 \
	TZ="Asia/Kolkata"

COPY . /app/.vubuntu

SHELL ["/bin/bash", "-c"]

RUN rm -f /etc/apt/sources.list && \
#All Official Focal Repos
	bash -c 'echo -e "deb http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse\ndeb-src http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse\ndeb http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse\ndeb-src http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse\ndeb http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse\ndeb-src http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse\ndeb http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse\ndeb-src http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse\ndeb http://archive.canonical.com/ubuntu focal partner\ndeb-src http://archive.canonical.com/ubuntu focal partner" >/etc/apt/sources.list' && \
	apt-get update && \
	apt-get install -y \
#Packages Installation
	tzdata \
	software-properties-common \
	apt-transport-https \
	wget \
	htop \
	git \
	curl \
	zip \
	sudo \
	net-tools \
	iputils-ping \
	build-essential \
	python3 \
	python3-pip \
	python-is-python3 \
	firefox \
	autocutsel \
	xclip \
	gnome-system-monitor \
	gedit \
	mousepad \
	pcmanfm \
	lxterminal \
	supervisor \
	x11vnc \
	xvfb \
	gnupg \
	dirmngr \
	gdebi \
	gdebi-core \
	nginx \
	openvpn \
	pluma && \
#Fluxbox
	apt-get install -y /app/.vubuntu/assets/packages/fluxbox.deb && \
#noVNC
	apt-get install -y /app/.vubuntu/assets/packages/novnc.deb && \
	cp /usr/share/novnc/vnc.html /usr/share/novnc/index.html && \
        openssl req -new -newkey rsa:4096 -days 36500 -nodes -x509 -subj "/C=IN/ST=Maharastra/L=Private/O=Dis/CN=www.google.com" -keyout /etc/ssl/novnc.key  -out /etc/ssl/novnc.cert && \
#Websockify
	npm i websockify && \
#TimeZone
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
#PeaZip
	wget https://github.com/peazip/PeaZip/releases/download/8.1.0/peazip_8.1.0.LINUX.x86_64.GTK2.deb -P /tmp && \
	apt-get install -y /tmp/peazip_8.1.0.LINUX.x86_64.GTK2.deb && \
#Ngrok
	wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -P /tmp && \
	unzip /tmp/ngrok-stable-linux-amd64.zip -d /usr/bin && \
	ngrok authtoken $NGROK_AUTH_TOKEN && \
#Wipe Temp Files
	rm -rf /var/lib/apt/lists/* && \ 
	apt-get clean && \
	rm -rf /tmp/*

# Set up the user
RUN export UNAME=$UNAME UID=1000 GID=1000 && \
    mkdir -p "/home/${UNAME}" && \
    echo "${UNAME}:x:${UID}:${GID}:${UNAME} User,,,:/home/${UNAME}:/bin/bash" >> /etc/passwd && \
    echo "${UNAME}:x:${UID}:" >> /etc/group && \
    mkdir -p /etc/sudoers.d && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} && \
    chown ${UID}:${GID} -R /home/${UNAME} && \
    gpasswd -a ${UNAME} audio
    
ENTRYPOINT ["supervisord", "-l", "/app/.vubuntu/supervisord.log", "-c"]

CMD ["/app/.vubuntu/assets/configs/supervisordconf"]
