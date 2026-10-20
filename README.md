# CI/CD Lab Infrastructure

Containers that run the course platform on each student's Ubuntu 24.04 VM.

## Jenkins (`jenkins/`) — Labs 02, 08, 16

```bash
cd jenkins
./setup.sh                                   # once: folders, docker GID, SSH key, .env
docker compose up -d --build jenkins         # controller on :8080 (Lab 02)
docker compose up -d --build agent-1         # SSH agent (Lab 08)
docker compose --profile inbound up -d agent-inbound   # inbound agent (Lab 08)
```

| Service | Image | Notes |
|---------|-------|-------|
| `jenkins` | `controller/Dockerfile` (Jenkins LTS, JDK 21, Docker CLI, `plugins.txt`) | Data in `/var/jenkins_home` on the VM |
| `agent-1` | `agent/Dockerfile` (ssh-agent + Python, Docker CLI, AWS CLI) | Workspace `/opt/jenkins-agent` (same path on host) |
| `agent-inbound` | `jenkins/inbound-agent:latest-jdk21` | Profile `inbound`; secret in `.env` |

## GitHub Actions runner (`github-runner/`) — Lab 19

```bash
cd github-runner
sudo mkdir -p /opt/gha-runner/_work && sudo chown -R 1000:1000 /opt/gha-runner
cp .env.example .env     # REPO_URL, RUNNER_TOKEN, labels, DOCKER_GID
docker compose up -d --build
docker compose logs -f   # "Listening for Jobs"
```

## Security notes

- Containers use the host Docker socket (Docker-outside-of-Docker). This grants root-level
  access to the VM — acceptable for a personal lab VM, not for shared servers.
- `keys/` and `.env` contain secrets and are git-ignored. Never commit them.
- Use the self-hosted runner only for `push` to main / manual workflows, never for pull requests.

## Enterprise reference examples

The existing Compose lab remains the required beginner environment.

- `examples/validate-jenkinsfile.sh` — Day 05 Declarative linter. Requires Bash,
  curl, a reachable controller, `JENKINS_URL`, `JENKINS_USER`, and
  `JENKINS_API_TOKEN`. Pass a Jenkinsfile path. An invalid model returns nonzero
  even if the endpoint returns HTTP 200. Never commit the token.
- `examples/kubernetes/` — Day 08 pod YAML and Jenkinsfile. Requires a configured
  Kubernetes cloud/plugin, namespace-scoped controller permissions, and agent
  connectivity. For this standalone repository, change the Jenkinsfile's
  `yamlFile` to `examples/kubernetes/agent-pod.yaml`. No cluster is installed by
  the example. Review images, resource settings and admission policy first.
- `examples/rootless-build.sh` — Day 11 optional build command. Requires buildctl,
  a separately configured rootless BuildKit daemon (`BUILDKIT_HOST`), registry
  login material and `IMAGE_REF`. Run from the application root. Rootless
  operation depends on host kernel/user namespace and runtime support; it does
  not mean BuildKit has no daemon.

References: [Jenkins linter](https://www.jenkins.io/doc/book/pipeline/development/),
[Kubernetes plugin](https://plugins.jenkins.io/kubernetes/),
[rootless BuildKit](https://github.com/moby/buildkit/blob/master/docs/rootless.md).
