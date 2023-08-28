#!/usr/bin/env bash
set -ex

echo "GITHUB_REF: ${GITHUB_REF}"
echo "GITHUB_REF_TYPE: ${GITHUB_REF_TYPE}"
echo "GITHUB_BASE_REF: ${GITHUB_BASE_REF}"
echo "GITHUB_HEAD_REF: ${GITHUB_HEAD_REF}"
echo "GITHUB_REF_NAME: ${GITHUB_REF_NAME}"
echo "GITHUB_REPOSITORY: ${GITHUB_REPOSITORY}"
echo "GITHUB_RUN_NUMBER: ${GITHUB_RUN_NUMBER}"
echo "GITHUB_RUN_ATTEMPT: ${GITHUB_RUN_ATTEMPT}"

echo "INPUT_HOST: ${INPUT_HOST}"
echo "INPUT_USER: ${INPUT_USER}"
echo "INPUT_PASS: ${INPUT_PASS}"
echo "INPUT_PORT: ${INPUT_PORT}"
echo "INPUT_NAME: ${INPUT_NAME}"
echo "INPUT_FILE: ${INPUT_FILE}"

mkdir -p ~/.ssh
#echo "IdentityFile /ssh_key" > ~/.ssh/config
ssh-keyscan -p "${INPUT_PORT}" -H "${INPUT_HOST}" >> ~/.ssh/known_hosts
ssh-keygen -q -f ~/.ssh/id_rsa -N "" -C "stack-deploy-action"
sshpass -p "${INPUT_PASS}" \
    ssh-copy-id -p "${INPUT_PORT}" -i ~/.ssh/id_rsa -o "StrictHostKeyChecking=no" \
        "${INPUT_USER}@${INPUT_HOST}"

echo "--- 1 ---"
ssh -p "${INPUT_PORT}" -o "StrictHostKeyChecking=no" "${INPUT_USER}@${INPUT_HOST}" whoami
echo "--- 2 ---"
ssh -p "${INPUT_PORT}" "${INPUT_USER}@${INPUT_HOST}" whoami

echo "--- 3 ---"
export REMOTE="${INPUT_USER}@${INPUT_HOST}:${INPUT_PORT}"
echo "REMOTE: ${REMOTE}"

echo "--- 4 ---"
export DOCKER_HOST="ssh://${REMOTE}"
docker context create remote --docker "host=ssh://${REMOTE}"

echo "--- 5 ---"
docker context ls
docker --context remote ps
