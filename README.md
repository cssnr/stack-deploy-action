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
name: "Test Docker Stack Push"

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

      - name: "Docker Stack Push"
        uses: hosted-domains/stack-push-action@master
        with:
          host: ${{ secrets.RSYNC_HOST }}
          user: ${{ secrets.RSYNC_USER }}
          pass: ${{ secrets.RSYNC_PASS }}
          port: ${{ secrets.RSYNC_PORT }}
          name: "awesome-stack"
          file: "docker-compose-swarm.yaml"
```
