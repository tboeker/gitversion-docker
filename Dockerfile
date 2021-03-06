FROM mono:4.8.0.495

# Install software for GitVersion
RUN echo "deb http://download.mono-project.com/repo/debian wheezy/snapshots 4.8.0.495/main" | tee /etc/apt/sources.list.d/mono-xamarin.list \
  && echo "deb http://ftp.debian.org/debian sid main" | tee -a /etc/apt/sources.list \
  && apt-get clean && apt-get update \
  && apt-get install -y --no-install-recommends unzip git libc6 libc6-dev libc6-dbg jq\
  && rm -rf /var/lib/apt/lists/* /tmp/* 


# Install GitVersion
RUN curl -Ls https://github.com/GitTools/GitVersion/releases/download/v4.0.0-beta.13/GitVersion.CommandLine.4.0.0-beta0013.nupkg -o tmp.zip \ 
  && unzip -d /usr/lib/GitVersion tmp.zip \
  && rm tmp.zip

COPY GitVersion.yml /usr/lib/GitVersion.yml

RUN echo '#!/bin/bash\nexec mono /usr/lib/GitVersion/tools/GitVersion.exe "$@" ' > /usr/bin/git-version
#COPY ./scripts/git-version.sh /usr/bin/git-version
RUN chmod +x /usr/bin/git-version

RUN echo '#!/bin/bash\nexec mono /usr/lib/GitVersion/tools/GitVersion.exe "$@" > /src/GitVersion.json' > /usr/bin/git-version-json
#COPY ./scripts/json.sh /usr/bin/json
RUN chmod +x /usr/bin/git-version-json

RUN echo '#!/bin/bash\nexec mono /usr/lib/GitVersion/tools/GitVersion.exe' > /usr/bin/git-version-show
#COPY ./scripts/show.sh /usr/bin/show
RUN chmod +x /usr/bin/git-version-show


COPY ./scripts/vsts.sh /usr/bin/git-version-vsts
RUN chmod +x /usr/bin/git-version-vsts

COPY ./scripts/msbuild.sh /usr/bin/git-version-msbuild
RUN chmod +x /usr/bin/git-version-msbuild

WORKDIR "/src"

CMD ["git-version-vsts"]
