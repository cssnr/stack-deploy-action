#!/usr/bin/env bash
set -ex

env

mkdir -p /root/.ssh
chmod 0700 /root/.ssh

ssh-keyscan -p "${INPUT_PORT}" -H "${INPUT_HOST}" >> /root/.ssh/known_hosts
if [ -z "${INPUT_SSH_KEY}" ];then
    ssh-keygen -q -f /root/.ssh/id_rsa -N "" -C "docker-stack-deploy-action"
    eval "$(ssh-agent -s)"
    ssh-add /root/.ssh/id_rsa

    sshpass -p "${INPUT_PASS}" \
        ssh-copy-id -p "${INPUT_PORT}" -i /root/.ssh/id_rsa \
            "${INPUT_USER}@${INPUT_HOST}"
else
    echo "${INPUT_SSH_KEY}" > /root/.ssh/id_rsa
    chmod 0600 /root/.ssh/id_rsa
    eval "$(ssh-agent -s)"
    ssh-add /root/.ssh/id_rsa
fi

ssh -p "${INPUT_PORT}" "${INPUT_USER}@${INPUT_HOST}" "docker info"

docker context create remote --docker "host=ssh://${INPUT_USER}@${INPUT_HOST}:${INPUT_PORT}"
docker context ls
docker context use remote

ls -lah

if [ -n "${INPUT_ENV_FILE}" ];then
    # shellcheck disable=SC1090
    echo INPUT_ENV_FILE: "${INPUT_ENV_FILE}"
    stat "${INPUT_ENV_FILE}"
    source "${INPUT_ENV_FILE}"
    # export ENV_FILE="${INPUT_ENV_FILE}"
fi

docker stack deploy -c "${INPUT_FILE}" "${INPUT_NAME}"

if [ -z "${INPUT_SSH_KEY}" ];then
    ssh -p "${INPUT_PORT}" "${INPUT_USER}@${INPUT_HOST}" \
        "sed -i '/docker-stack-deploy-action/d' ~/.ssh/authorized_keys"
fi
