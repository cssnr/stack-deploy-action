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
chmod 0700 ~/.ssh
echo -e "Host *\n    IdentityFile ~/.ssh/id_rsa\n    StrictHostKeyChecking no" > ~/.ssh/config
ssh-keyscan -p "${INPUT_PORT}" -H "${INPUT_HOST}" >> ~/.ssh/known_hosts
ssh-keygen -q -f ~/.ssh/id_rsa -N "" -C "stack-deploy-action"

echo "--- 0 ---"
echo "HOME: ${HOME}"
echo -n "~: "
echo ~
echo "--- 0 ---"
cat ~/.ssh/config
echo "--- 0 ---"
stat ~/.ssh
echo "--- 0 ---"
stat ~/.ssh/id_rsa

sleep 3

echo "--- 1 ---"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

sleep 3

echo "--- 2 ---"
sshpass -p "${INPUT_PASS}" \
    ssh-copy-id -p "${INPUT_PORT}" -i ~/.ssh/id_rsa -o "StrictHostKeyChecking=no" \
        "${INPUT_USER}@${INPUT_HOST}"

ssh-add ~/.ssh/nameofkey

echo "--- 3 ---"
ssh -vv -p "${INPUT_PORT}" -o "StrictHostKeyChecking=no" "${INPUT_USER}@${INPUT_HOST}" whoami
ssh -p "${INPUT_PORT}" "${INPUT_USER}@${INPUT_HOST}" whoami

echo "--- 5 ---"
export REMOTE="${INPUT_USER}@${INPUT_HOST}:${INPUT_PORT}"
echo "REMOTE: ${REMOTE}"

echo "--- 5 ---"
export DOCKER_HOST="ssh://${REMOTE}"
docker context create remote --docker "host=ssh://${REMOTE}"

echo "--- 5 ---"
docker context ls
docker --context remote ps
