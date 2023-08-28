#!/usr/bin/env bash
set -ex

env

echo "INPUT_HOST: ${INPUT_HOST}"
echo "INPUT_USER: ${INPUT_USER}"
echo "INPUT_PASS: ${INPUT_PASS}"
echo "INPUT_PORT: ${INPUT_PORT}"
echo "INPUT_NAME: ${INPUT_NAME}"
echo "INPUT_FILE: ${INPUT_FILE}"

mkdir -p ~/.ssh
chmod 0700 ~/.ssh

ssh-keyscan -p "${INPUT_PORT}" -H "${INPUT_HOST}" >> ~/.ssh/known_hosts
ssh-keygen -q -f ~/.ssh/id_rsa -N "" -C "stack-deploy-action"

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

sshpass -p "${INPUT_PASS}" \
    ssh-copy-id -p "${INPUT_PORT}" -i ~/.ssh/id_rsa -o "StrictHostKeyChecking=no" \
        "${INPUT_USER}@${INPUT_HOST}"

ssh -p "${INPUT_PORT}" "${INPUT_USER}@${INPUT_HOST}" whoami

#export DOCKER_HOST="ssh://${INPUT_USER}@${INPUT_HOST}:${INPUT_PORT}"
docker context create remote --docker "host=ssh://${INPUT_USER}@${INPUT_HOST}:${INPUT_PORT}"
docker context ls
docker context use remote
docker ps

ssh -p "${INPUT_PORT}" "${INPUT_USER}@${INPUT_HOST}" \
    "sed -i '/stack-deploy-action/d' ~/.ssh/authorized_keys"
