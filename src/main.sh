#!/usr/bin/env bash

set -e

echo "Running: ${0} as: $(whoami) in: $(pwd)"

function cleanup_trap() {
    _ST="$?"
    if [[ "${_ST}" != "0" ]]; then
        echo -e "\u001b[31;1mScript Exited with Error: ${_ST}"
    fi
    if [ -z "${INPUT_SSH_KEY}" ];then
        echo -e "\u001b[35mCleaning Up authorized_keys on: ${INPUT_HOST}"
        ssh -p "${INPUT_HOST_PORT}" "${INPUT_HOST_USERNAME}@${INPUT_HOST}" \
            "sed -i '/docker-stack-deploy-action/d' ~/.ssh/authorized_keys"
    fi
    if [[ "${_ST}" == "0" ]]; then
        echo -e "\u001b[32;1mFinished Success."
    fi
    exit "${_ST}"
}

mkdir -p /root/.ssh
chmod 0700 /root/.ssh
ssh-keyscan -p "${INPUT_HOST_PORT}" -H "${INPUT_HOST}" >> /root/.ssh/known_hosts

if [ -z "${INPUT_SSH_KEY}" ];then
    echo -e "\u001b[36mCreating and Copying SSH Key to: ${INPUT_HOST}"
    ssh-keygen -q -f /root/.ssh/id_rsa -N "" -C "docker-stack-deploy-action"
    eval "$(ssh-agent -s)"
    ssh-add /root/.ssh/id_rsa

    sshpass -p "${INPUT_HOST_PASSWORD}" \
        ssh-copy-id -p "${INPUT_HOST_PORT}" -i /root/.ssh/id_rsa \
            "${INPUT_HOST_USERNAME}@${INPUT_HOST}"
else
    echo -e "\u001b[36mAdding SSH Key to SSH Agent"
    echo "${INPUT_SSH_KEY}" > /root/.ssh/id_rsa
    chmod 0600 /root/.ssh/id_rsa
    eval "$(ssh-agent -s)"
    ssh-add /root/.ssh/id_rsa
fi

trap cleanup_trap EXIT HUP INT QUIT PIPE TERM

login() {
  echo "${INPUT_PASSWORD}" | docker login "${INPUT_REGISTRY}" -u "${INPUT_USERNAME}" --password-stdin
}

if [ -z "${INPUT_USERNAME+x}" ] || [ -z "${INPUT_PASSWORD+x}" ]; then
  echo "Container Registry: No authentication provided"
else
  [ -z ${INPUT_REGISTRY+x} ] && export REGISTRY=""
  if login > /dev/null 2>&1; then
    echo "Container Registry: Logged in ${INPUT_REGISTRY} as ${INPUT_USERNAME}"
  else
    echo "Container Registry: Login to ${INPUT_REGISTRY} as ${INPUT_USERNAME} failed"
    exit 1
  fi
fi

echo -e "\u001b[36mVerifying Docker and Setting Context."
ssh -p "${INPUT_HOST_PORT}" "${INPUT_HOST_USERNAME}@${INPUT_HOST}" "docker info" > /dev/null

docker context create remote --docker "host=ssh://${INPUT_HOST_USERNAME}@${INPUT_HOST}:${INPUT_HOST_PORT}"
docker context ls
docker context use remote

if [ -n "${INPUT_ENV_FILE}" ];then
    echo -e "\u001b[36mSourcing Environment File: ${INPUT_ENV_FILE}"
    stat "${INPUT_ENV_FILE}"
    set -a
    # shellcheck disable=SC1090
    source "${INPUT_ENV_FILE}"
    # echo TRAEFIK_HOST: "${TRAEFIK_HOST}"
    # export ENV_FILE="${INPUT_ENV_FILE}"
fi

echo -e "\u001b[36mDeploying Stack: \u001b[37;1m${INPUT_NAME}"
docker stack deploy --with-registry-auth -c "${INPUT_FILE}" "${INPUT_NAME}"
