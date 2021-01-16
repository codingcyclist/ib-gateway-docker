# Builder
FROM ubuntu:18.04 AS builder

RUN apt-get update
RUN apt-get install -y unzip dos2unix wget

WORKDIR /root

RUN wget -q --progress=bar:force:noscroll --show-progress https://download2.interactivebrokers.com/installers/ibgateway/latest-standalone/ibgateway-latest-standalone-linux-x64.sh -O install-ibgateway.sh
#RUN wget -q --progress=bar:force:noscroll --show-progress https://download2.interactivebrokers.com/installers/tws/stable-standalone/tws-stable-standalone-linux-x64.sh -O install-ibgateway.sh
RUN chmod a+x install-ibgateway.sh

RUN wget -q --progress=bar:force:noscroll --show-progress https://github.com/IbcAlpha/IBC/releases/download/3.8.4-beta.2/IBCLinux-3.8.4-beta.2.zip -O ibc.zip
#RUN wget -q --progress=bar:force:noscroll --show-progress https://github.com/IbcAlpha/IBC/releases/download/3.8.1/IBCLinux-3.8.1.zip -O ibc.zip
RUN unzip ibc.zip -d /opt/ibc
RUN chmod a+x /opt/ibc/*.sh /opt/ibc/*/*.sh

COPY run.sh run.sh
RUN dos2unix run.sh

# Application
FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y --fix-missing x11vnc xvfb socat openjfx #vim

WORKDIR /root

COPY --from=builder /root/install-ibgateway.sh install-ibgateway.sh
RUN yes "" | ./install-ibgateway.sh

ARG VNC_PASSWORD "1234" #Default password is 1234; will be overwritten by what is set in the build arguments
RUN mkdir .vnc && \
    x11vnc -storepasswd $VNC_PASSWORD .vnc/passwd

COPY --from=builder /opt/ibc /opt/ibc
COPY --from=builder /root/run.sh run.sh

COPY ibc_config.ini ibc/config.ini

ENV DISPLAY :0

CMD ./run.sh
