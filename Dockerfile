FROM docker:28-dind

RUN apk add --update --no-cache bash sshpass

COPY src/ /src

ENTRYPOINT ["bash", "/src/main.sh"]
