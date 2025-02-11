[![Tags](https://img.shields.io/github/actions/workflow/status/cssnr/stack-deploy-action/tags.yaml?logo=github&logoColor=white&label=tags)](https://github.com/cssnr/stack-deploy-action/actions/workflows/tags.yaml)
[![Test](https://img.shields.io/github/actions/workflow/status/cssnr/stack-deploy-action/test.yaml?logo=github&logoColor=white&label=test)](https://github.com/cssnr/stack-deploy-action/actions/workflows/test.yaml)
[![GitHub Release Version](https://img.shields.io/github/v/release/cssnr/stack-deploy-action?logo=github)](https://github.com/cssnr/stack-deploy-action/releases/latest)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/cssnr/parse-issue-form-action?logo=github&logoColor=white&label=updated)](https://github.com/cssnr/parse-issue-form-action/graphs/commit-activity)
[![Codeberg Last Commit](https://img.shields.io/gitea/last-commit/cssnr/parse-issue-form-action/master?gitea_url=https%3A%2F%2Fcodeberg.org%2F&logo=codeberg&logoColor=white&label=updated)](https://codeberg.org/cssnr/parse-issue-form-action)
[![GitHub Top Language](https://img.shields.io/github/languages/top/cssnr/stack-deploy-action?logo=htmx&logoColor=white)](https://github.com/cssnr/stack-deploy-action)
[![GitHub Org Stars](https://img.shields.io/github/stars/cssnr?style=flat&logo=github&logoColor=white)](https://cssnr.github.io/)
[![Discord](https://img.shields.io/discord/899171661457293343?logo=discord&logoColor=white&label=discord&color=7289da)](https://discord.gg/wXy6m2X8wY)

# Docker Stack Deploy Action

This action deploys a docker stack from a compose file to a remote docker host using SSH Password or Key File Authentication.
You can also optionally authenticate against a private registry using a username and password.

For more details see [action.yaml](action.yaml) and [src/main.sh](src/main.sh).

_Portainer Users_: You can deploy directly to Portainer with: [cssnr/portainer-stack-deploy-action](https://github.com/cssnr/portainer-stack-deploy-action)

- [Inputs](#Inputs)
- [Examples](#Examples)
- [Support](#Support)
- [Contributing](#Contributing)

## Inputs

| input         | required         | default               | description                       |
| ------------- | ---------------- | --------------------- | --------------------------------- |
| host          | **Yes**          | -                     | Remote Docker hostname            |
| port          | No               | `22`                  | Remote Docker port                |
| user          | **Yes**          | -                     | Remote Docker username            |
| pass          | Not w/ `ssh_key` | -                     | Remote Docker password \*         |
| ssh_key       | Not w/ `pass`    | -                     | Remote SSH Key file \*            |
| file          | No               | `docker-compose.yaml` | Docker Compose file               |
| name          | **Yes**          | -                     | Docker Stack name                 |
| env_file      | No               | -                     | Docker Environment file           |
| registry_auth | No               | -                     | Enable Registry Authentication \* |
| registry_host | No               | -                     | Registry Authentication Host \*   |
| registry_user | No               | -                     | Registry Authentication User \*   |
| registry_pass | No               | -                     | Registry Authentication Pass \*   |

**pass/ssh_key** - You must provide either a `pass` or `ssh_key`

**registry_auth** - Set to `true` to deploy with `--with-registry-auth`

**registry_host** - To run `docker login` on another registry, example: `ghcr.io`

**registry_user/registry_pass** - Required to run `docker login` before stack deploy

```yaml
- name: 'Docker Stack Deploy'
  uses: cssnr/stack-deploy-action@v1
  with:
    name: 'stack-name'
    file: 'docker-compose-swarm.yaml'
    host: ${{ secrets.DOCKER_HOST }}
    port: ${{ secrets.DOCKER_PORT }}
    user: ${{ secrets.DOCKER_USER }}
    pass: ${{ secrets.DOCKER_PASS }}
```

Use `docker login` and enable `--with-registry-auth`

```yaml
- name: 'Docker Stack Deploy'
  uses: cssnr/stack-deploy-action@v1
  with:
    name: 'stack-name'
    file: 'docker-compose-swarm.yaml'
    host: ${{ secrets.DOCKER_HOST }}
    port: ${{ secrets.DOCKER_PORT }}
    user: ${{ secrets.DOCKER_USER }}
    pass: ${{ secrets.DOCKER_PASS }}
    registry_host: 'ghcr.io'
    registry_user: ${{ vars.GHCR_USER }}
    registry_pass: ${{ secrets.GHCR_PASS }}
```

## Examples

Simple Example

```yaml
name: 'Test Docker Stack Deploy'

on:
  push:

jobs:
  deploy:
    name: 'Deploy'
    runs-on: ubuntu-latest
    timeout-minutes: 5

    steps:
      - name: 'Checkout'
        uses: actions/checkout@v4

      - name: 'Docker Stack Deploy'
        uses: cssnr/stack-deploy-action@v1
        with:
          name: 'stack-name'
          file: 'docker-compose-swarm.yaml'
          host: ${{ secrets.DOCKER_HOST }}
          port: ${{ secrets.DOCKER_PORT }}
          user: ${{ secrets.DOCKER_USER }}
          pass: ${{ secrets.DOCKER_PASS }}
```

Full Example

```yaml
name: 'Test Docker Stack Deploy'

on:
  workflow_dispatch:
    inputs:
      tags:
        description: 'Tags: comma,separated'
        required: true
        default: 'latest'

env:
  REGISTRY: 'ghcr.io'

jobs:
  deploy:
    name: 'Deploy'
    runs-on: ubuntu-latest
    timeout-minutes: 5

    steps:
      - name: 'Checkout'
        uses: actions/checkout@v4

      - name: 'Generate Tags'
        id: tags
        uses: smashedr/docker-tags-action@master
        with:
          images: '$${{ env.REGISTRY }}/${{ github.repository }}'
          extra: ${{ inputs.tags }}

      - name: 'Setup Buildx'
        uses: docker/setup-buildx-action@v2
        with:
          platforms: linux/amd64,linux/arm64

      - name: 'Docker Login'
        uses: docker/login-action@v3
        with:
          registry: $${{ env.REGISTRY }}
          username: ${{ secrets.GHCR_USER }}
          password: ${{ secrets.GHCR_PASS }}

      - name: 'Build and Push'
        uses: docker/build-push-action@v6
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ steps.tags.outputs.tags }}

      - name: 'Docker Stack Deploy'
        uses: cssnr/stack-deploy-action@v1
        with:
          name: 'stack-name'
          file: 'docker-compose-swarm.yaml'
          host: ${{ secrets.DOCKER_HOST }}
          port: ${{ secrets.DOCKER_PORT }}
          user: ${{ secrets.DOCKER_USER }}
          ssh_key: '${{ secrets.DOCKER_SSH_KEY }}'
```

# Support

For general help or to request a feature see:

- Q&A Discussion: https://github.com/cssnr/stack-deploy-action/discussions/categories/q-a
- Request a Feature: https://github.com/cssnr/stack-deploy-action/discussions/categories/feature-requests

If you are experiencing an issue/bug or getting unexpected results you can:

- Report an Issue: https://github.com/cssnr/stack-deploy-action/issues
- Chat with us on Discord: https://discord.gg/wXy6m2X8wY
- Provide General
  Feedback: [https://cssnr.github.io/feedback/](https://cssnr.github.io/feedback/?app=Stack%20Deploy)

# Contributing

Currently, the best way to contribute to this project is to star this project on GitHub.

Additionally, you can support other GitHub Actions I have published:

- [VirusTotal Action](https://github.com/cssnr/virustotal-action)
- [Update Version Tags Action](https://github.com/cssnr/update-version-tags-action)
- [Update JSON Value Action](https://github.com/cssnr/update-json-value-action)
- [Parse Issue Form Action](https://github.com/cssnr/parse-issue-form-action)
- [Mirror Repository Action](https://github.com/cssnr/mirror-repository-action)
- [Stack Deploy Action](https://github.com/cssnr/stack-deploy-action)
- [Portainer Stack Deploy](https://github.com/cssnr/portainer-stack-deploy-action)
- [Mozilla Addon Update Action](https://github.com/cssnr/mozilla-addon-update-action)

For a full list of current projects to support visit: [https://cssnr.github.io/](https://cssnr.github.io/)
