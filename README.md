[![GitHub Tag Major](https://img.shields.io/github/v/tag/cssnr/stack-deploy-action?sort=semver&filter=!v*.*&logo=git&logoColor=white&labelColor=585858&label=%20)](https://github.com/cssnr/stack-deploy-action/tags)
[![GitHub Tag Minor](https://img.shields.io/github/v/tag/cssnr/stack-deploy-action?sort=semver&filter=!v*.*.*&logo=git&logoColor=white&labelColor=585858&label=%20)](https://github.com/cssnr/stack-deploy-action/tags)
[![GitHub Release Version](https://img.shields.io/github/v/release/cssnr/stack-deploy-action?logo=git&logoColor=white&labelColor=585858&label=%20)](https://github.com/cssnr/stack-deploy-action/releases/latest)
[![Workflow Release](https://img.shields.io/github/actions/workflow/status/cssnr/stack-deploy-action/release.yaml?logo=github&label=release)](https://github.com/cssnr/stack-deploy-action/actions/workflows/release.yaml)
[![Workflow Test](https://img.shields.io/github/actions/workflow/status/cssnr/stack-deploy-action/test.yaml?logo=github&label=test)](https://github.com/cssnr/stack-deploy-action/actions/workflows/test.yaml)
[![Workflow Lint](https://img.shields.io/github/actions/workflow/status/cssnr/stack-deploy-action/lint.yaml?logo=github&label=lint)](https://github.com/cssnr/stack-deploy-action/actions/workflows/lint.yaml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/cssnr/stack-deploy-action?logo=github&label=updated)](https://github.com/cssnr/stack-deploy-action/graphs/commit-activity)
[![Codeberg Last Commit](https://img.shields.io/gitea/last-commit/cssnr/stack-deploy-action/master?gitea_url=https%3A%2F%2Fcodeberg.org%2F&logo=codeberg&logoColor=white&label=updated)](https://codeberg.org/cssnr/stack-deploy-action)
[![GitHub Top Language](https://img.shields.io/github/languages/top/cssnr/stack-deploy-action?logo=htmx)](https://github.com/cssnr/stack-deploy-action)
[![GitHub Discussions](https://img.shields.io/github/discussions/cssnr/stack-deploy-action)](https://github.com/cssnr/stack-deploy-action/discussions)
[![GitHub Forks](https://img.shields.io/github/forks/cssnr/stack-deploy-action?style=flat&logo=github)](https://github.com/cssnr/stack-deploy-action/forks)
[![GitHub Repo Stars](https://img.shields.io/github/stars/cssnr/stack-deploy-action?style=flat&logo=github)](https://github.com/cssnr/stack-deploy-action/stargazers)
[![GitHub Org Stars](https://img.shields.io/github/stars/cssnr?style=flat&logo=github&label=org%20stars)](https://cssnr.github.io/)
[![Discord](https://img.shields.io/discord/899171661457293343?logo=discord&logoColor=white&label=discord&color=7289da)](https://discord.gg/wXy6m2X8wY)

# Docker Stack Deploy Action

- [Inputs](#Inputs)
- [Examples](#Examples)
- [Tags](#Tags)
- [Support](#Support)
- [Contributing](#Contributing)

> [!TIP]  
> **Now works with vanilla Docker hosts using Compose. No Swarm Required!**

This action deploys a docker stack from a compose file to a remote docker host using SSH Password or Key File Authentication.
You can also optionally authenticate against a private registry using a username and password.

This action uses a remote docker context to deploy the stack from the working directory allowing you to easily prepare the workspace for deployment.

**Portainer Users:** You can deploy directly to Portainer with: [cssnr/portainer-stack-deploy-action](https://github.com/cssnr/portainer-stack-deploy-action)

> [!NOTE]  
> Please submit a [Feature Request](https://github.com/cssnr/stack-deploy-action/discussions/categories/feature-requests)
> for new features or [Open an Issue](https://github.com/cssnr/stack-deploy-action/issues) if you find any bugs.

For more details see [action.yaml](action.yaml) and [src/main.sh](src/main.sh).

## Inputs

| Input         |   Required   | Default               | Description                               |
| :------------ | :----------: | :-------------------- | :---------------------------------------- |
| name          |   **Yes**    | -                     | Docker Stack/Project Name \*              |
| file          |      -       | `docker-compose.yaml` | Docker Stack/Compose File                 |
| compose       |      -       | `false`               | Uses Compose instead of Swarm \*          |
| compose_args  |      -       | -                     | Additional Arguments for Compose \*       |
| host          |   **Yes**    | -                     | Remote Docker Hostname or IP \*           |
| port          |      -       | `22`                  | Remote Docker Port                        |
| user          |   **Yes**    | -                     | Remote Docker Username                    |
| pass          | or `ssh_key` | -                     | Remote Docker Password \*                 |
| ssh_key       |  or `pass`   | -                     | Remote SSH Key File \*                    |
| env_file      |      -       | -                     | Docker Environment File \*                |
| detach        |      -       | `true`                | Detach Flag, `false` to disable \*        |
| prune         |      -       | `false`               | Prune Flag, `true` to enable              |
| resolve_image |      -       | `always`              | Resolve [`always`, `changed`, `never`] \* |
| registry_auth |      -       | -                     | Enable Registry Authentication \*         |
| registry_host |      -       | -                     | Registry Authentication Host \*           |
| registry_user |      -       | -                     | Registry Authentication Username \*       |
| registry_pass |      -       | -                     | Registry Authentication Password \*       |
| summary       |      -       | `true`                | Add Job Summary \*                        |

_Swarm hosts, see the stack deploy [documentation](https://docs.docker.com/reference/cli/docker/stack/deploy/) for more details._  
_Compose hosts, see the compose up [documentation](https://docs.docker.com/reference/cli/docker/compose/up/) for more details._

**name** - For Swarm this is the stack name and for Compose the project name.

**compose** - Set this to `true` to use `compose up` instead of `stack deploy` for non-swarm Docker hosts.

**compose_args** - Arguments to pass to the `compose up` command. Only used for `compose: true` deployments.
Detach `-d` is always passed. With no args the default is `--remove-orphans --force-recreate`.
Use an empty string to override. For more details, see the compose up
[docs](https://docs.docker.com/reference/cli/docker/compose/up/).

**host** - The hostname or IP address of the remote docker server to deploy too.
If your hostname is behind a proxy like Cloudflare you will need to use the IP address.

**pass/ssh_key** - You must provide either a `pass` or `ssh_key`.

**env_file** - Variables in this file are exported before running stack deploy.
To use a docker `env_file` specify it in your compose file and make it available in a previous step.
If you need compose file templating this can also be done in a previous step.

**detach** - Set this to `false` to not exit immediately and wait for the services to converge.
This will generate extra output in the logs and is useful for debugging deployments.

**resolve_image** - When the default `always` is used, this argument is omitted.

**registry_auth** - Set to `true` to deploy with `--with-registry-auth`.

**registry_host** - To run `docker login` on another registry. Example: `ghcr.io`

**registry_user/registry_pass** - Required to run `docker login` before stack deploy.

**summary** - Write a Summary for the job. To disable this set to `false`.

To view a workflow run, click on a recent [Test](https://github.com/cssnr/stack-deploy-action/actions/workflows/test.yaml) job _(requires login)_.

<details><summary>👀 View Example Job Summary</summary>

---

🎉 Stack `test_stack-deploy` Successfully Deployed.

```text
docker stack deploy --detach=false --resolve-image=changed -c docker-compose.yaml test_stack-deploy
```

<details><summary>Results</summary>

```text
Updating service test_stack-deploy_alpine (id: tdk8v42m0rvp9hz4rbfrtszb6)
1/1:
overall progress: 0 out of 1 tasks
overall progress: 1 out of 1 tasks
verify: Waiting 5 seconds to verify that tasks are stable...
verify: Waiting 4 seconds to verify that tasks are stable...
verify: Waiting 3 seconds to verify that tasks are stable...
verify: Waiting 2 seconds to verify that tasks are stable...
verify: Waiting 1 seconds to verify that tasks are stable...
verify: Service tdk8v42m0rvp9hz4rbfrtszb6 converged
```

</details>

---

</details>

```yaml
- name: 'Stack Deploy'
  uses: cssnr/stack-deploy-action@v1
  with:
    name: 'stack-name'
    file: 'docker-compose-swarm.yaml'
    host: ${{ secrets.DOCKER_HOST }}
    port: ${{ secrets.DOCKER_PORT }}
    user: ${{ secrets.DOCKER_USER }}
    pass: ${{ secrets.DOCKER_PASS }} # not needed with ssh_key
    ssh_key: ${{ secrets.DOCKER_SSH_KEY }} # not needed with pass
```

## Examples

💡 _Click on an example heading to expand or collapse the example._

<details open><summary>With password, docker login and --with-registry-auth</summary>

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

</details>
<details><summary>With SSH key, --prune, --detach=false and --resolve-image=changed</summary>

```yaml
- name: 'Stack Deploy'
  uses: cssnr/stack-deploy-action@v1
  with:
    name: 'stack-name'
    file: 'docker-compose-swarm.yaml'
    host: ${{ secrets.DOCKER_HOST }}
    port: ${{ secrets.DOCKER_PORT }}
    user: ${{ secrets.DOCKER_USER }}
    ssh_key: ${{ secrets.DOCKER_SSH_KEY }}
    detach: false
    prune: true
    resolve_image: 'changed'
```

</details>
<details><summary>With All Inputs</summary>

```yaml
- name: 'Stack Deploy'
  uses: cssnr/stack-deploy-action@v1
  with:
    name: 'stack-name'
    file: 'docker-compose-swarm.yaml'
    host: ${{ secrets.DOCKER_HOST }}
    port: ${{ secrets.DOCKER_PORT }}
    user: ${{ secrets.DOCKER_USER }}
    pass: ${{ secrets.DOCKER_PASS }} # not needed with ssh_key
    ssh_key: ${{ secrets.DOCKER_SSH_KEY }} # not needed with pass
    env_file: 'stack.env'
    detach: true
    prune: false
    resolve_image: 'always'
    registry_auth: true # not needed with registry_pass/registry_user
    registry_host: 'ghcr.io'
    registry_user: ${{ vars.GHCR_USER }}
    registry_pass: ${{ secrets.GHCR_PASS }}
    summary: true
```

</details>
<details><summary>Standalone Compose with Defaults</summary>

```yaml
- name: 'Stack Deploy'
  uses: cssnr/stack-deploy-action@v1
  with:
    file: 'docker-compose.yaml'
    host: ${{ secrets.DOCKER_HOST }}
    port: ${{ secrets.DOCKER_PORT }}
    user: ${{ secrets.DOCKER_USER }}
    ssh_key: ${{ secrets.DOCKER_SSH_KEY }}
    compose: true
```

</details>
<details><summary>Standalone Compose with Custom Arguments</summary>

```yaml
- name: 'Stack Deploy'
  uses: cssnr/stack-deploy-action@v1
  with:
    file: 'docker-compose.yaml'
    host: ${{ secrets.DOCKER_HOST }}
    port: ${{ secrets.DOCKER_PORT }}
    user: ${{ secrets.DOCKER_USER }}
    ssh_key: ${{ secrets.DOCKER_SSH_KEY }}
    compose: true
    compose_args: --remove-orphans --force-recreate
```

Note: these are the default arguments. To remove them pass an empty string.

</details>
<details><summary>Simple Workflow Example</summary>

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

</details>
<details><summary>Full Workflow Example</summary>

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

concurrency:
  group: ${{ github.workflow }}
  cancel-in-progress: true

jobs:
  build:
  name: 'Build'
  runs-on: ubuntu-latest
  timeout-minutes: 15
  permissions:
    packages: write

  steps:
    - name: 'Checkout'
      uses: actions/checkout@v4

    - name: 'Setup Buildx'
      uses: docker/setup-buildx-action@v2
      with:
        platforms: 'linux/amd64,linux/arm64'

    - name: 'Docker Login'
      uses: docker/login-action@v3
      with:
        registry: $${{ env.REGISTRY }}
        username: ${{ secrets.GHCR_USER }}
        password: ${{ secrets.GHCR_PASS }}

    - name: 'Generate Tags'
      id: tags
      uses: cssnr/docker-tags-action@v1
      with:
        images: $${{ env.REGISTRY }}/${{ github.repository }}
        tags: ${{ inputs.tags }}

    - name: 'Build and Push'
      uses: docker/build-push-action@v6
      with:
        context: .
        platforms: 'linux/amd64,linux/arm64'
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
          ssh_key: ${{ secrets.DOCKER_SSH_KEY }}

  cleanup:
    name: 'Cleanup'
    runs-on: ubuntu-latest
    timeout-minutes: 5
    needs: deploy
    permissions:
      contents: read
      packages: write

    steps:
      - name: 'Purge Cache'
        uses: cssnr/cloudflare-purge-cache-action@v2
        with:
          token: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          zones: cssnr.com
```

</details>

For more examples, you can check out other projects using this action:  
https://github.com/cssnr/stack-deploy-action/network/dependents

## Tags

The following rolling [tags](https://github.com/cssnr/stack-deploy-action/tags) are maintained.

| Tag                                                                                                                                                                                                                           | Example  | Target   | Bugs | Feat. | Description                                               |
| :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------- | :------- | :--: | :---: | :-------------------------------------------------------- |
| [![GitHub Tag Major](https://img.shields.io/github/v/tag/cssnr/stack-deploy-action?sort=semver&filter=!v*.*&style=for-the-badge&label=%20&color=limegreen)](https://github.com/cssnr/stack-deploy-action/releases/latest)     | `vN`     | `vN.x.x` |  ✅  |  ✅   | Includes new features but is always backwards compatible. |
| [![GitHub Tag Minor](https://img.shields.io/github/v/tag/cssnr/stack-deploy-action?sort=semver&filter=!v*.*.*&style=for-the-badge&label=%20&color=yellowgreen)](https://github.com/cssnr/stack-deploy-action/releases/latest) | `vN.N`   | `vN.N.x` |  ✅  |  ❌   | Only receives bug fixes. This is the most stable tag.     |
| [![GitHub Release](https://img.shields.io/github/v/release/cssnr/stack-deploy-action?style=for-the-badge&label=%20&color=orange)](https://github.com/cssnr/stack-deploy-action/releases/latest)                               | `vN.N.N` | `vN.N.N` |  ❌  |  ❌   | Not a rolling tag. **Not** recommended.                   |

You can view the release notes for each version on the [releases](https://github.com/cssnr/stack-deploy-action/releases) page.

# Support

For general help or to request a feature see:

- Q&A Discussion: https://github.com/cssnr/stack-deploy-action/discussions/categories/q-a
- Request a Feature: https://github.com/cssnr/stack-deploy-action/discussions/categories/feature-requests

If you are experiencing an issue/bug or getting unexpected results you can:

- Report an Issue: https://github.com/cssnr/stack-deploy-action/issues
- Chat with us on Discord: https://discord.gg/wXy6m2X8wY
- Provide General Feedback: [https://cssnr.github.io/feedback/](https://cssnr.github.io/feedback/?app=Stack%20Deploy)

For more information, see the CSSNR [SUPPORT.md](https://github.com/cssnr/.github/blob/master/.github/SUPPORT.md#support).

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
