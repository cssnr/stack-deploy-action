# Docker Stack Deploy Action

Coming Soon...

## Stack Deploy

For more details see: [action.yaml](action.yaml)

### Inputs

| input | description               |
|-------|---------------------------|
| host: | Remote Docker host        |
| user: | Remote Docker username    |  
| pass: | Remote Docker password    |
| port: | Remote Docker port number | 
| name: | Remote Docker Stack Name  |
| file: | Local Docker Compose File | 

### Short Example

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
          name: "awesome-stack"
          file: "docker-compose-swarm.yaml"
```

### Full Example

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
