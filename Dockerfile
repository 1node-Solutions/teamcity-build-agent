FROM jetbrains/teamcity-agent
LABEL maintainer="kosar@freedom.valor.ua"
LABEL vendor="1node"
LABEL lastUpdate="04-02-2020"
LABEL description="Teamcity agent with .NET Core 3.1 sdk, mono and nuget installer."
USER root
RUN apt update && apt upgrade -y
RUN apt install -y gnupg apt-transport-https ca-certificates python3-pip wget && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list && \
    apt update && \
    apt install -y mono-devel && \
    curl -o /usr/local/bin/nuget.exe https://dist.nuget.org/win-x86-commandline/latest/nuget.exe && \
    alias nuget="mono /usr/local/bin/nuget.exe"
RUN cd /tmp && wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb && \
    apt update && \
    apt install -y dotnet-sdk-3.1 aspnetcore-runtime-3.1 dotnet-runtime-3.1
RUN pip3 install awsebcli --upgrade
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash && \
    apt install -y nodejs && npm i -g npm
