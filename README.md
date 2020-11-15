# teamcity-agent

Official teamcity agent with preinstalled nuget and aws eb cli.

Pull the TeamCity image from the Docker Hub Repository:

```1node/teamcity-build-agent```

and use the following command to start a container with TeamCity agent running inside

Linux container:
```bash
docker run -it -e SERVER_URL="<url>"  \
    -v <path>:/data/teamcity_agent/conf  \      
    1node/teamcity-agent
```
where is the full URL for TeamCity server, accessible by the agent. Note that "localhost" will not generally not work as it will refer to the "localhost" inside the container. is the host machine directory to serve as the TeamCity agent config directory. We recommend providing this binding in order to persist the agent configuration, e.g. authorization on the server. Note that you should map a different folder for every new agent you create.

You can also provide your agent's name using -e AGENT_NAME="". If this variable is omitted, the name for the agent will be generated automatically by the server.

When you run the agent for the first time, you should authorize it via the TeamCity server UI: go to the Unauthorized Agents page in your browser. See more details. All information about agent authorization is stored in the agent's configuration folder. If you stop the container with the agent and then start a new one with the same config folder, the agent's name and authorization state will be preserved.

A TeamCity agent does not need manual upgrade: it will upgrade itself automatically on connecting to an upgraded server.

Preserving Checkout Directories Between Builds
When build agent container is restarted, it re-checkouts sources for the builds.

To avoid this, you should pass a couple of additional options to preserve build agent state between restarts:

Preserve checked out sources (-v /opt/buildagent/work:/opt/buildagent/work)
Keep internal build agent caches (-v /opt/buildagent/system:/opt/buildagent/system)
You can use other than /opt/buildagent/ source path prefix on the host machine unless you're going to use Docker Wrapper via docker.sock (see below).

## docker-compose example
```
version: "3"
services:
  tcserver:
    image: jetbrains/teamcity-server
    restart: always
    ports:
      - 8111:8111
    hostname: teamcity.example.com
    container_name: teamcity
    depends_on:
      - tcdb
    environment:
      TEAMCITY_SERVER_MEM_OPTS: "-Xmx4g -XX:MaxPermSize=270m -XX:ReservedCodeCacheSize=350m"
    volumes:
      - ./server/data:/data/teamcity_server/datadir
      - ./server/log:/opt/teamcity/logs

  tcdb:
    image: postgres:11.5
    hostname: db.teamcity.example.com
    container_name: teamcity-db
    restart: always
    environment:
      POSTGRES_PASSWORD: "password"
      POSTGRES_USER: "teamcity"
      POSTGRES_DB: "teamcity"
    volumes:
      - ./pg_data:/var/lib/postgresql/data
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "5"

  tc-ag-1:
    image: 1node/teamcity-agent
    container_name: teamcity-agent-1
    restart: always
    environment:
      - SERVER_URL=https://teamcity.example.com
      - AGENT_NAME=tc-ag-1
    volumes:
      - ./agents/tc-ag-1:/opt/buildagent
      - /var/run/docker.sock:/var/run/docker.sock
```
## Running Builds Which Require Docker
In a Linux container, if you need a Docker daemon available inside your builds, you have two options:

1) Docker from the host (in this case you will benefit from the caches shared between the host and all your containers but there is a security concern: your build may actually harm your host Docker, so use it at your own risk)
```bash
docker run -it -e SERVER_URL="<url>"  \
    -v <path>:/data/teamcity_agent/conf \
    -v /var/run/docker.sock:/var/run/docker.sock  \
    -v /opt/buildagent/work:/opt/buildagent/work \
    -v /opt/buildagent/temp:/opt/buildagent/temp \
    -v /opt/buildagent/tools:/opt/buildagent/tools \
    -v /opt/buildagent/plugins:/opt/buildagent/plugins \
    -v /opt/buildagent/system:/opt/buildagent/system \
    1node/teamcity-agent
```
Volume options starting with -v /opt/buildagent/ are required if you want to use Docker Wrapper on this build agent. Without them, the corresponding builds with the enabled docker wrapper (for Command Line, Maven, Ant, Gradle, and since TeamCity 2018.1, .NET CLI (dotnet) and PowerShell runners) will not work. Unfortunately, using several docker-based build agents from the same host is not possible.

If you omit these options, you can run several build agents (but you need to specify different <path> for them), but Docker Wrapper won't work on such agents.

The problem is, that multiple agent containers would use the same (/opt/buildagent/\*) directories as they are mounted from the host machine to the agent container and that the docker wrapper mounts the directories from the host to the nested docker wrapper container. And, you cannot use multiple agent containers with different paths on the host as the docker wrapper would still try to map the paths as they are in the agent container, but from the host machine to the nested docker wrapper container. To make several agents work with docker wrapper and docker.sock option, one have to build different teamcity-agent docker images with different paths of teamcity-agent installation inside those images (like /opt/buildagentN), and start those images with corresponding parameters like -v /opt/buildagent1/work:/opt/buildagent1/work etc.

2) New Docker daemon running within your container (note that in this case the container should be run with —privileged flag)
```bash
docker run -it -e SERVER_URL="<url>"  \
    -v <path>:/data/teamcity_agent/conf \
    -v docker_volumes:/var/lib/docker \
    --privileged -e DOCKER_IN_DOCKER=start \    
    1node/teamcity-agent
```
The option -v docker_volumes:/var/lib/docker is related to the case when the aufs filesystem is used and when a build agent is started from a Windows machine (related issue). If you want to start several build agents, you need to specify different volumes for them, like -v agent1_volumes:/var/lib/docker, -v agent2_volumes:/var/lib/docker.
