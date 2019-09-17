FROM jetbrains/teamcity-agent
LABEL maintainer="kosar@freedom.valor.ua"
LABEL vendor="1node"
LABEL lastUpdate="16-09-2019"
LABEL description="Teamcity agent with mono and nuget installer."
RUN apt update && apt upgrade -y
RUN apt install -y gnupg ca-certificates python-pip && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list && \
    apt update && \
    apt install -y mono-devel && \
    curl -o /usr/local/bin/nuget.exe https://dist.nuget.org/win-x86-commandline/latest/nuget.exe && \
    alias nuget="mono /usr/local/bin/nuget.exe" && \
    pip install awsebcli --upgrade
