[![Tags](https://img.shields.io/github/actions/workflow/status/cssnr/stack-deploy-action/tags.yaml?logo=github&logoColor=white&label=tags)](https://github.com/cssnr/stack-deploy-action/actions/workflows/tags.yaml)
[![Test](https://img.shields.io/github/actions/workflow/status/cssnr/stack-deploy-action/test.yaml?logo=github&logoColor=white&label=test)](https://github.com/cssnr/stack-deploy-action/actions/workflows/test.yaml)
[![GitHub Release Version](https://img.shields.io/github/v/release/cssnr/stack-deploy-action?logo=github)](https://github.com/cssnr/stack-deploy-action/releases/latest)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/cssnr/parse-issue-form-action?logo=github&logoColor=white&label=updated)](https://github.com/cssnr/parse-issue-form-action/graphs/commit-activity)
[![GitHub Top Language](https://img.shields.io/github/languages/top/cssnr/stack-deploy-action?logo=htmx&logoColor=white)](https://github.com/cssnr/stack-deploy-action)
[![GitHub Org Stars](https://img.shields.io/github/stars/cssnr?style=flat&logo=github&logoColor=white)](https://cssnr.github.io/)
[![Discord](https://img.shields.io/discord/899171661457293343?logo=discord&logoColor=white&label=discord&color=7289da)](https://discord.gg/wXy6m2X8wY)

# Docker Stack Deploy Action

Coming Soon...

For more details see [action.yaml](action.yaml) and [src/main.sh](src/main.sh)

* [Inputs](#Inputs)
* [Examples](#Examples)
* [Support](#Support)
* [Contributing](#Contributing)

## Inputs

| input    | required | default               | description              |
|----------|----------|-----------------------|--------------------------|
| host     | **Yes**  | -                     | Remote Docker hostname   |
| user     | **Yes**  | -                     | Remote Docker username   |
| pass     | No       | -                     | Remote Docker password * |
| port     | No       | `22`                  | Remote Docker port       |
| ssh_key  | No       | -                     | Remote SSH Key file *    |
| name     | No       | `docker-compose.yaml` | Docker Stack name        |
| file     | **Yes**  | -                     | Docker Compose file      |
| env_file | No       | -                     | Docker Environment file  |

**pass/ssh_key** - You must provide either a `pass` or `ssh_key`

```yaml
      - name: "Docker Stack Deploy"
        uses: cssnr/stack-deploy-action@master
        with:
          host: ${{ secrets.DOCKER_HOST }}
          user: ${{ secrets.DOCKER_USER }}
          pass: ${{ secrets.DOCKER_PASS }}
          port: ${{ secrets.DOCKER_PORT }}
          name: "stack-name"
          file: "docker-compose-swarm.yaml"
```

## Examples

Simple Example

```yaml
name: "Test Docker Stack Deploy"

on:
  push:

jobs:
  deploy:
    name: "Deploy"
    runs-on: ubuntu-latest
    timeout-minutes: 5

    steps:
      - name: "Checkout"
        uses: actions/checkout@v3

      - name: "Docker Stack Deploy"
        uses: cssnr/stack-deploy-action@master
        with:
          host: ${{ secrets.DOCKER_HOST }}
          user: ${{ secrets.DOCKER_USER }}
          pass: ${{ secrets.DOCKER_PASS }}
          port: ${{ secrets.DOCKER_PORT }}
          name: "stack-name"
          file: "docker-compose-swarm.yaml"
```

Full Example

```yaml
name: "Test Docker Stack Deploy"

on:
  workflow_dispatch:
    inputs:
      tags:
        description: 'Tags: comma,separated'
        required: true
        default: 'latest'

env:
  REGISTRY: "ghcr.io"
  USER: "user-org"
  REPO: "repo-name"

jobs:
  deploy:
    name: "Deploy"
    runs-on: ubuntu-latest
    timeout-minutes: 5

    steps:
      - name: "Tags"
        id: tags
        run: |
          echo "Input Tags: ${{ inputs.tags }}"
          TAGS=""
          IFS=',' read -ra INPUT <<< "${{ inputs.tags }}"
          for tag in "${INPUT[@]}";do
            echo "${REGISTRY}/${USER}/${REPO}:${tag}"
            TAGS+="${REGISTRY}/${USER}/${REPO}:${tag},"
          done
          TAGS="$(echo ${TAGS} | sed 's/,*$//g')"
          echo "tags=${TAGS}" >> $GITHUB_OUTPUT
          echo "Parsed Tags: ${TAGS}"

      - name: "Checkout"
        uses: actions/checkout@v3

      - name: "Setup Buildx"
        uses: docker/setup-buildx-action@v2
        with:
          platforms: linux/amd64,linux/arm64

      - name: "Docker Login"
        uses: docker/login-action@v2
        with:
          registry: $${{ env.REGISTRY }}
          username: ${{ secrets.GHCR_USER }}
          password: ${{ secrets.GHCR_PASS }}

      - name: "Build and Push"
        uses: docker/build-push-action@v4
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ steps.tags.outputs.tags }}

      - name: "Docker Stack Deploy"
        uses: cssnr/stack-deploy-action@master
        with:
          host: ${{ secrets.DOCKER_HOST }}
          user: ${{ secrets.DOCKER_USER }}
          pass: ${{ secrets.DOCKER_PASS }}
          port: ${{ secrets.DOCKER_PORT }}
          name: "stack-name"
          file: "docker-compose-swarm.yaml"
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
- [Portainer Stack Deploy](https://github.com/cssnr/portainer-stack-deploy-action)
- [Mozilla Addon Update Action](https://github.com/cssnr/mozilla-addon-update-action)

For a full list of current projects to support visit: [https://cssnr.github.io/](https://cssnr.github.io/)
