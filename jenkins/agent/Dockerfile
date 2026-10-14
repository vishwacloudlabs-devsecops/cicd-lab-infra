# Jenkins build agent (SSH) for the course.
# Tools: git, Python 3, Docker CLI + Compose + Buildx, AWS CLI v2, curl, jq.
FROM jenkins/ssh-agent:latest-jdk21

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg git jq unzip python3 python3-venv python3-pip \
 && install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
 && chmod a+r /etc/apt/keyrings/docker.asc \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin docker-buildx-plugin \
 && rm -rf /var/lib/apt/lists/*

# AWS CLI v2 (used by the Amazon ECR labs)
RUN ARCH=$(uname -m) \
 && curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o /tmp/awscliv2.zip \
 && unzip -q /tmp/awscliv2.zip -d /tmp \
 && /tmp/aws/install \
 && rm -rf /tmp/aws /tmp/awscliv2.zip

# Give the jenkins user access to the host Docker socket at start-up
COPY docker-group.sh /usr/local/bin/docker-group.sh
RUN chmod +x /usr/local/bin/docker-group.sh
ENTRYPOINT ["/usr/local/bin/docker-group.sh"]
