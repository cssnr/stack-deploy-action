FROM docker:23-dind

RUN apk add --update --no-cache bash openssh sshpass

COPY --chmod=0755 docker-entrypoint.sh /
COPY --chmod=0755 scripts/ /scripts

ENTRYPOINT ["/docker-entrypoint.sh"]
