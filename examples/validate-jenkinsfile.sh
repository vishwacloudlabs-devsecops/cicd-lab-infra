#!/usr/bin/env bash
# Validate Declarative syntax; plugin/runtime behaviour still needs a real build.
set -euo pipefail
set +x
: "${JENKINS_URL:?Set the trusted Jenkins URL (HTTPS outside the local lab)}"
: "${JENKINS_USER:?Set your Jenkins username}"
: "${JENKINS_API_TOKEN:?Set a Jenkins API token, not your password}"
pipeline_file=${1:-Jenkinsfile}
[[ -f "$pipeline_file" ]] || { echo "Missing Jenkinsfile: $pipeline_file" >&2; exit 2; }
# API-token authentication is exempt from CSRF crumbs on supported Jenkins.
# Do not follow redirects: credentials must only reach the intended controller.
response=$(curl --silent --show-error --fail --connect-timeout 10 --max-time 60 \
  --user "$JENKINS_USER:$JENKINS_API_TOKEN" \
  --form "jenkinsfile=<$pipeline_file" \
  "${JENKINS_URL%/}/pipeline-model-converter/validate")
printf '%s\n' "$response"
# The endpoint may return HTTP 200 even when validation failed.
[[ "$response" == *"Jenkinsfile successfully validated."* ]]
