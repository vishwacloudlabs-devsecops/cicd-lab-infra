#!/bin/bash
# Registers the runner with GitHub (first start only) and then runs it.
#
# Required environment variables:
#   REPO_URL      e.g. https://github.com/<you>/visitor-counter-flask
#   RUNNER_TOKEN  registration token from: repo -> Settings -> Actions -> Runners -> New self-hosted runner
# Optional:
#   RUNNER_NAME   (default: container hostname)
#   RUNNER_LABELS (default: deploy)
#   RUNNER_WORK   (default: /opt/gha-runner/_work - same path on host and container)
set -e
cd /home/runner/actions-runner

RUNNER_NAME=${RUNNER_NAME:-$(hostname)}
RUNNER_LABELS=${RUNNER_LABELS:-deploy}
RUNNER_WORK=${RUNNER_WORK:-/opt/gha-runner/_work}

# Registration files are kept in ./config (a Docker volume) so that a
# restarted container does not need a new registration token.
if [ -f config/.runner ]; then
  echo ">> Runner already registered - restoring configuration"
  cp -a config/.runner config/.credentials config/.credentials_rsaparams .
else
  if [ -z "$REPO_URL" ] || [ -z "$RUNNER_TOKEN" ]; then
    echo "ERROR: REPO_URL and RUNNER_TOKEN must be set for the first start." >&2
    exit 1
  fi
  echo ">> Registering runner '$RUNNER_NAME' with labels '$RUNNER_LABELS'"
  ./config.sh --unattended --replace \
    --url "$REPO_URL" --token "$RUNNER_TOKEN" \
    --name "$RUNNER_NAME" --labels "$RUNNER_LABELS" \
    --work "$RUNNER_WORK"
  cp -a .runner .credentials .credentials_rsaparams config/
fi

exec ./run.sh
