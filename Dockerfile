FROM ubuntu:latest
# for latest release, see https://github.com/actions/runner/releases

USER root

# install curl and jq
RUN apt-get update && apt-get install -y curl \
    jq \
    ca-certificates \
    gnupg \
    # docker.io \
    git \
    wget \
    software-properties-common \
    sudo \
    init \
    systemd \
    lsb-release && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


RUN mkdir actions-runner && cd actions-runner && \
    curl -o actions-runner-linux-x64-2.325.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.325.0/actions-runner-linux-x64-2.325.0.tar.gz && \
    tar xzf ./actions-runner-linux-x64-2.325.0.tar.gz 

# Docker Install
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update
RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

RUN useradd -m -s /bin/bash runner && \
    echo "runner:runner" | chpasswd

RUN usermod -aG docker runner
RUN usermod -aG sudo runner

RUN docker -v
# RUN service docker start

WORKDIR /home/runner


COPY github-actions-runner/entrypoint.sh ./entrypoint.sh
# COPY github-actions-runner/* ./
# COPY github-actions-runner/bin ./bin
# COPY github-actions-runner/externals ./externals
RUN chmod +x ./entrypoint.sh

USER runner

ENTRYPOINT ["./entrypoint.sh"]
