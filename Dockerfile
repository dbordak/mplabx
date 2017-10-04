FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive

# Microchip tools require i386 compatability libs
RUN dpkg --add-architecture i386 \
    && apt-get update -yq \
    && apt-get install -yq --no-install-recommends curl libc6:i386 \
    libx11-6:i386 libxext6:i386 libstdc++6:i386 libexpat1:i386 \
    libxext6 libxrender1 libxtst6 libgtk2.0-0 \
    ca-certificates git-core procps
# Download and install XC32 compiler

RUN curl -fSL -A "Mozilla/4.0" -o /tmp/xc32.run "http://ww1.microchip.com/downloads/en/DeviceDoc/xc32-v1.40-full-install-linux-installer.run" \
    && chmod a+x /tmp/xc32.run \
    && /tmp/xc32.run --mode unattended --prefix /opt/microchip/xc32/ \
        --netservername localhost \
    && rm /tmp/xc32.run
ENV PATH /opt/microchip/xc32/bin:$PATH

# Download and install MPLAB X IDE
RUN curl -fSL -A "Mozilla/4.0" -o /tmp/mplabx-installer.tar "http://www.microchip.com/mplabx-ide-linux-installer" \
    && tar xf /tmp/mplabx-installer.tar && rm /tmp/mplabx-installer.tar \
    && USER=root ./*-installer.sh --nox11 \
        -- --mode unattended --installdir /opt/microchip/mplabx/ --ipe 0 \
    && rm ./*-installer.sh
ENV PATH /opt/microchip/mplabx/mplab_ide/bin:$PATH

# Download and install Legacy Peripheral libs
RUN curl -fSL -A "Mozilla/4.0" -o /tmp/plib.tar 'http://www.microchip.com/mymicrochip/filehandler.aspx?ddocname=en574264' \
    && tar xf /tmp/plib.tar && rm /tmp/plib.tar \
    && chmod a+x 'PIC32 Legacy Peripheral Libraries.run' \
    && ./PIC32\ Legacy\ Peripheral\ Libraries.run --mode unattended --prefix /opt/microchip/xc32/ \
	&& rm ./PIC32\ Legacy\ Peripheral\ Libraries.run 

VOLUME ["/tmp/.X11-unix"]
