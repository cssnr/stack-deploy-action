[![Release](https://img.shields.io/github/actions/workflow/status/cssnr/stack-deploy-action/release.yaml?logo=github&logoColor=white&label=release)](https://github.com/cssnr/stack-deploy-action/actions/workflows/release.yaml)
[![Test](https://img.shields.io/github/actions/workflow/status/cssnr/stack-deploy-action/test.yaml?logo=github&logoColor=white&label=test)](https://github.com/cssnr/stack-deploy-action/actions/workflows/test.yaml)
[![Lint](https://img.shields.io/github/actions/workflow/status/cssnr/stack-deploy-action/lint.yaml?logo=github&logoColor=white&label=lint)](https://github.com/cssnr/stack-deploy-action/actions/workflows/lint.yaml)
[![GitHub Release Version](https://img.shields.io/github/v/release/cssnr/stack-deploy-action?logo=github)](https://github.com/cssnr/stack-deploy-action/releases/latest)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/cssnr/stack-deploy-action?logo=github&logoColor=white&label=updated)](https://github.com/cssnr/stack-deploy-action/graphs/commit-activity)
[![Codeberg Last Commit](https://img.shields.io/gitea/last-commit/cssnr/stack-deploy-action/master?gitea_url=https%3A%2F%2Fcodeberg.org%2F&logo=codeberg&logoColor=white&label=updated)](https://codeberg.org/cssnr/stack-deploy-action)
[![GitHub Top Language](https://img.shields.io/github/languages/top/cssnr/stack-deploy-action?logo=htmx&logoColor=white)](https://github.com/cssnr/stack-deploy-action)
[![GitHub Forks](https://img.shields.io/github/forks/cssnr/stack-deploy-action?style=flat&logo=github)](https://github.com/cssnr/stack-deploy-action/forks)
[![GitHub Repo Stars](https://img.shields.io/github/stars/cssnr/stack-deploy-action?style=flat&logo=github&logoColor=white)](https://github.com/cssnr/stack-deploy-action/stargazers)
[![GitHub Org Stars](https://img.shields.io/github/stars/cssnr?style=flat&logo=github&logoColor=white&label=org%20stars)](https://cssnr.github.io/)
[![Discord](https://img.shields.io/discord/899171661457293343?logo=discord&logoColor=white&label=discord&color=7289da)](https://discord.gg/wXy6m2X8wY)

# Docker Stack Deploy Action

- [Inputs](#Inputs)
- [Examples](#Examples)
- [Support](#Support)
- [Contributing](#Contributing)

This action deploys a docker stack from a compose file to a remote docker host using SSH Password or Key File Authentication.
You can also optionally authenticate against a private registry using a username and password.

For more details see [action.yaml](action.yaml) and [src/main.sh](src/main.sh).

**Portainer Users:** You can deploy directly to Portainer with: [cssnr/portainer-stack-deploy-action](https://github.com/cssnr/portainer-stack-deploy-action)

> [!NOTE]  
> Please submit a [Feature Request](https://github.com/cssnr/stack-deploy-action/discussions/categories/feature-requests)
> for new features or [Open an Issue](https://github.com/cssnr/stack-deploy-action/issues) if you find any bugs.

## Inputs

| input         |   required   | default               | description                       |
| ------------- | :----------: | --------------------- | --------------------------------- |
| host          |   **Yes**    | -                     | Remote Docker hostname            |
| port          |      -       | `22`                  | Remote Docker port                |
| user          |   **Yes**    | -                     | Remote Docker username            |
| pass          | or `ssh_key` | -                     | Remote Docker password \*         |
| ssh_key       |  or `pass`   | -                     | Remote SSH Key file \*            |
| name          |   **Yes**    | -                     | Docker Stack name                 |
| file          |      -       | `docker-compose.yaml` | Docker Compose file               |
| env_file      |      -       | -                     | Docker Environment file           |
| registry_auth |      -       | -                     | Enable Registry Authentication \* |
| registry_host |      -       | -                     | Registry Authentication Host \*   |
| registry_user |      -       | -                     | Registry Authentication User \*   |
| registry_pass |      -       | -                     | Registry Authentication Pass \*   |
| summary       |      -       | `true`                | Add Job Summary \*                |

**pass/ssh_key** - You must provide either a `pass` or `ssh_key`.

**registry_auth** - Set to `true` to deploy with `--with-registry-auth`.

**registry_host** - To run `docker login` on another registry. Example: `ghcr.io`

**registry_user/registry_pass** - Required to run `docker login` before stack deploy.

**summary** - Write a Summary for the job. To disable this set to `false`.

<details><summary>👀 View Example Job Summary</summary>

---

🎉 Stack `test-stack` Successfully Deployed.

<details><summary>Results</summary>

```text
Updating service test-stack_alpine (id: ewi9ck5hcdmmvaj8ms0te4t8r)
```

</details>

---

</details>

To see a workflow run you can view a recent
[test.yaml run](https://github.com/cssnr/stack-deploy-action/actions/workflows/test.yaml)
_(requires login)_.

```yaml
- name: 'Stack Deploy'
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
- name: 'Stack Deploy'
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
name: 'Stack Deploy Action'

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

      - name: 'Stack Deploy'
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
name: 'Stack Deploy Action'

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
  build:
  name: 'Build'
  runs-on: ubuntu-latest
  timeout-minutes: 5
  permissions:
    packages: write

  steps:
    - name: 'Checkout'
      uses: actions/checkout@v4

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

    - name: 'Generate Tags'
      id: tags
      uses: smashedr/docker-tags-action@v1
      with:
        images: '$${{ env.REGISTRY }}/${{ github.repository }}'
        tags: ${{ inputs.tags }}

    - name: 'Build and Push'
      uses: docker/build-push-action@v6
      with:
        context: .
        platforms: linux/amd64,linux/arm64
        push: true
        tags: ${{ steps.tags.outputs.tags }}
        labels: ${{ steps.tags.outputs.labels }}

  deploy:
    name: 'Deploy'
    runs-on: ubuntu-latest
    timeout-minutes: 5
    needs: [build]

    steps:
      - name: 'Checkout'
        uses: actions/checkout@v4

      - name: 'Stack Deploy'
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
- Provide General Feedback: [https://cssnr.github.io/feedback/](https://cssnr.github.io/feedback/?app=Stack%20Deploy)

# Contributing

Currently, the best way to contribute to this project is to star this project on GitHub.

If you would like to submit a PR, please review the [CONTRIBUTING.md](CONTRIBUTING.md).

Additionally, you can support other GitHub Actions I have published:

- [Stack Deploy Action](https://github.com/cssnr/stack-deploy-action?tab=readme-ov-file#readme)
- [Portainer Stack Deploy](https://github.com/cssnr/portainer-stack-deploy-action?tab=readme-ov-file#readme)
- [VirusTotal Action](https://github.com/cssnr/virustotal-action?tab=readme-ov-file#readme)
- [Mirror Repository Action](https://github.com/cssnr/mirror-repository-action?tab=readme-ov-file#readme)
- [Update Version Tags Action](https://github.com/cssnr/update-version-tags-action?tab=readme-ov-file#readme)
- [Update JSON Value Action](https://github.com/cssnr/update-json-value-action?tab=readme-ov-file#readme)
- [Parse Issue Form Action](https://github.com/cssnr/parse-issue-form-action?tab=readme-ov-file#readme)
- [Cloudflare Purge Cache Action](https://github.com/cssnr/cloudflare-purge-cache-action?tab=readme-ov-file#readme)
- [Mozilla Addon Update Action](https://github.com/cssnr/mozilla-addon-update-action?tab=readme-ov-file#readme)
- [Docker Tags Action](https://github.com/cssnr/docker-tags-action?tab=readme-ov-file#readme)

For a full list of current projects to support visit: [https://cssnr.github.io/](https://cssnr.github.io/)
