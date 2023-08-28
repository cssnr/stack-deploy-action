#!/usr/bin/env bash
set -e

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

export REMOTE="${INPUT_USER}@${REMOTE_HOST}:${REMOTE_PORT}"
echo "REMOTE: ${REMOTE}"

echo "--- whoami ---"
whoami
echo "--- pwd ---"
pwd
echo "--- ls ---"
ls
echo "--- cat ~/.ssh/config ---"
cat ~/.ssh/config

echo "--- DEBUG ---"
docker context ls

ssh-keyscan -H "${INPUT_HOST}" -p "${INPUT_PORT}" >> ~/.ssh/known_hosts
ssh-keygen -q -N "" -f ./ssh_key
sshpass -p "${INPUT_PASS}" ssh-copy-id -o "StrictHostKeyChecking=no" -i ./ssh_key.pub "${REMOTE}"
ssh -o "StrictHostKeyChecking=no" "${REMOTE}"

export DOCKER_HOST="ssh://${REMOTE}"
docker context create remote --docker "host=ssh://${REMOTE}"
docker context ls
docker --context remote ps
