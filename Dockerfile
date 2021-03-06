FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
  sudo \
  curl \
  openssh-client \
  ca-certificates \
  sshpass

# Create github user and pull runner binary
RUN useradd github \
        && echo "github ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
        && usermod -aG sudo github \
        && mkdir /app \
        && cd /app \
        && curl -O -L https://github.com/actions/runner/releases/download/v2.263.0/actions-runner-linux-x64-2.263.0.tar.gz \
        && tar xzf ./actions-runner-linux-x64-*.tar.gz \
        && bash /app/bin/installdependencies.sh \
        && chown -R github:github /app

RUN mkdir -p /home/github/.ssh \
        && chown github:github /home/github/.ssh

# Prepare entrypoint
COPY entrypoint.sh /app/entrypoint.sh
RUN chown github:github /app/entrypoint.sh \
        && chmod +x /app/entrypoint.sh
USER github
ENTRYPOINT ["/app/entrypoint.sh"]
