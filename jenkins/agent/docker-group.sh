#!/bin/bash
# SSH sessions take their groups from /etc/group, so the jenkins user must be
# a member of a group whose GID matches the host's docker group (DOCKER_GID).
set -e
if [ -n "$DOCKER_GID" ]; then
  if ! getent group "$DOCKER_GID" >/dev/null; then
    groupadd -g "$DOCKER_GID" docker-host
  fi
  usermod -aG "$(getent group "$DOCKER_GID" | cut -d: -f1)" jenkins
fi
# Hand over to the image's original entrypoint (starts sshd)
exec setup-sshd "$@"
