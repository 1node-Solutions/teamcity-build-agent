FROM jetbrains/teamcity-agent
LABEL maintainer="bogdan.kosarevskyi@gmail.com"
LABEL vendor="1node"
LABEL lastUpdate="16-11-2020"
LABEL description="Teamcity agent with .NET Core 3.1 sdk, mono and nuget installer."
USER root
ENV PATH="$PATH:/root/.dotnet/tools"
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
RUN dotnet tool install --global Amazon.Lambda.Tools
RUN pip3 install awsebcli --upgrade
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash && \
    apt install -y nodejs && npm i -g npm
RUN curl -L "https://github.com/github-release/github-release/releases/download/$(curl --silent "https://api.github.com/repos/github-release/github-release/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')/linux-amd64-github-release.bz2" -o /tmp/linux-amd64-github-release.bz2 && \
    bzip2 -dc /tmp/linux-amd64-github-release.bz2 > /usr/local/bin/github-release  && \
    rm /tmp/linux-amd64-github-release.bz2 && \
    chmod +x /usr/local/bin/github-release
RUN cd /tmp && wget https://golang.org/dl/go1.15.3.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.15.3.linux-amd64.tar.gz && \
    export PATH=$PATH:/usr/local/go/bin && \
    rm go1.15.3.linux-amd64.tar.gz && ln -s /usr/local/go/bin/go /usr/local/bin/
    
