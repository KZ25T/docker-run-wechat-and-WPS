FROM ubuntu:latest

ARG weixinurl=http://archive.ubuntukylin.com/software/pool/partner/weixin_2.1.1_amd64.deb
ARG weixindeb=weixin_2.1.1_amd64.deb
ARG wpsurl=https://archive.ubuntukylin.com/software/pool/partner/wps-office_11.1.0.11719_amd64.deb
ARG wpsdeb=wps-office_11.1.0.11719_amd64.deb
ARG username=normal
ARG uid=1000
ARG GITHUB_MIRROR=hub.nuaa.cf
ARG ttfurl=https://${GITHUB_MIRROR}/dv-anomaly/ttf-wps-fonts/archive/refs/heads/master.zip
ARG msyhurl=https://${GITHUB_MIRROR}/chenyium/Microsoft-Yahei-Mono/archive/refs/heads/master.zip

# change apt source
RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list
RUN sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN apt update
RUN apt install -y ca-certificates
RUN sed -i 's/http:/https:/g' /etc/apt/sources.list
RUN apt update

# add normal user
RUN adduser --disabled-password --uid ${uid} --gecos "" ${username}
## set to sudoer
RUN apt install -y sudo
RUN adduser normal root
RUN adduser normal sudo
RUN chmod 640 /etc/sudoers
RUN echo "normal ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chmod 440 /etc/sudoers
## start ibus-daemon normally
RUN echo "ibus-daemon -d -x" >> /home/${username}/.bashrc

# install libs and software
## install input method and wps fonts
RUN apt install -y wget unzip ibus ibus-pinyin
RUN mkdir -p /usr/share/fonts/wps-office
RUN wget "${ttfurl}" && unzip master.zip && cd ttf-wps-fonts-master && echo "y" | ./install.sh
RUN cd .. && rm -r master.zip ttf-wps-fonts-master
RUN wget "${msyhurl}" && unzip master.zip && cd Microsoft-Yahei-Mono-master && mv MSYHMONO.ttf /usr/share/fonts/wps-office/msyhmono.ttf
RUN cd .. && rm -r master.zip Microsoft-Yahei-Mono-master
## install wps
RUN apt install -y qt5-style-plugins libglu1-mesa bsdmainutils xdg-utils libxslt1.1
RUN wget "${wpsurl}" && dpkg -i ${wpsdeb} && rm ${wpsdeb}
## install weixin
RUN apt install -y libasound2 libnss3 libxss1 desktop-file-utils libgtk-3-0 libnotify4 libxtst6 libatspi2.0-0 libuuid1 libsecret-1-0
RUN wget "${weixinurl}" && dpkg -i ${weixindeb} && rm ${weixindeb}
RUN chown root:root /opt/weixin/chrome-sandbox && chmod 4755 /opt/weixin/chrome-sandbox
RUN echo 'alias wx="/usr/bin/weixin --no-sandbox &"' >> /home/${username}/.bashrc

# set ibus env
ENV IBUS_ENABLE_SYNC_MODE=1
ENV GTK_IM_MODULE=ibus
ENV QT_IM_MODULE=ibus
ENV XMODIFIERS=@im=ibus
