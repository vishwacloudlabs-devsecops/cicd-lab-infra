#!/bin/bash
# One-time preparation of the Ubuntu VM for the Jenkins lab environment.
# Run from this folder:  ./setup.sh
set -e

echo ">> Creating host folders (owned by UID 1000 = jenkins inside the containers)"
sudo mkdir -p /var/jenkins_home /opt/jenkins-agent
sudo chown -R 1000:1000 /var/jenkins_home /opt/jenkins-agent

echo ">> Detecting the host docker group ID"
DOCKER_GID=$(getent group docker | cut -d: -f3)
echo "   docker GID = $DOCKER_GID"

echo ">> Creating an SSH key pair for the controller -> agent connection"
mkdir -p keys
if [ ! -f keys/jenkins_agent ]; then
  ssh-keygen -t ed25519 -N "" -C "jenkins-agent" -f keys/jenkins_agent >/dev/null
fi

if [ ! -f .env ]; then
  cat > .env <<EOF
DOCKER_GID=$DOCKER_GID
JENKINS_AGENT_SSH_PUBKEY=$(cat keys/jenkins_agent.pub)
# Paste the secret shown by Jenkins for the inbound agent (Day 8 lab):
JENKINS_INBOUND_SECRET=
EOF
  echo ">> .env created"
else
  echo ">> .env already exists - left unchanged"
fi

echo
echo "Done. Next:  docker compose up -d --build"
echo "Private key for the Jenkins SSH credential:  keys/jenkins_agent"
