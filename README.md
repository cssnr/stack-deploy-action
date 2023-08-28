# Docker Stack Deploy Action

Coming Soon...

## Push Artifacts

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

### Example

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
        uses: hosted-domains/stack-deploy-action@master
        with:
          host: ${{ secrets.DOCKER_HOST }}
          user: ${{ secrets.DOCKER_USER }}
          pass: ${{ secrets.DOCKER_PASS }}
          port: ${{ secrets.DOCKER_PORT }}
          name: "awesome-stack"
          file: "docker-compose-swarm.yaml"
```
