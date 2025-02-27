#!/usr/bin/env bash
# https://github.com/cssnr/stack-deploy-action

set -e

function cleanup_trap() {
    _ST="$?"
    if [[ "${_ST}" != "0" ]]; then
        echo -e "⛔ \u001b[31;1mFailed to Deploy Stack! See logs for details..."
    fi
    if [ -z "${INPUT_SSH_KEY}" ];then
        echo -e "Cleaning Up authorized_keys on: \u001b[36;1m${INPUT_HOST}"
        ssh -p "${INPUT_PORT}" "${INPUT_USER}@${INPUT_HOST}" \
            "sed -i '/docker-stack-deploy-action/d' ~/.ssh/authorized_keys"
    fi
    if [[ "${_ST}" == "0" ]]; then
        echo -e "✅ \u001b[32;1mFinished Success."
    fi
    exit "${_ST}"
}

echo "::group::Starting Stack Deploy Action"
echo "User: $(whoami)"
echo "Script: ${0}"
echo -e "Directory: $(pwd)"
mkdir -p /root/.ssh
chmod 0700 /root/.ssh
ssh-keyscan -p "${INPUT_PORT}" -H "${INPUT_HOST}" >> /root/.ssh/known_hosts
echo "::endgroup::"

if [ -z "${INPUT_SSH_KEY}" ];then
    echo -e "::group::Copying SSH Key to: \u001b[36;1m${INPUT_HOST}"
    ssh-keygen -q -f /root/.ssh/id_rsa -N "" -C "docker-stack-deploy-action"
    eval "$(ssh-agent -s)"
    ssh-add /root/.ssh/id_rsa
    mkdir ~/.ssh
    sshpass -eINPUT_PASS \
        ssh-copy-id -i /root/.ssh/id_rsa -o ConnectTimeout=15 \
            -p "${INPUT_PORT}" "${INPUT_USER}@${INPUT_HOST}"
else
    echo "::group::Adding SSH Key to SSH Agent"
    echo "${INPUT_SSH_KEY}" > /root/.ssh/id_rsa
    chmod 0600 /root/.ssh/id_rsa
    eval "$(ssh-agent -s)"
    ssh-add /root/.ssh/id_rsa
fi
echo "::endgroup::"

trap cleanup_trap EXIT HUP INT QUIT PIPE TERM

echo "::group::Verifying Docker and Setting Context."
ssh -o BatchMode=yes -o ConnectTimeout=15 -p "${INPUT_PORT}" \
    "${INPUT_USER}@${INPUT_HOST}" "docker info" > /dev/null
if ! docker context inspect remote >/dev/null 2>&1;then
    docker context create remote --docker "host=ssh://${INPUT_USER}@${INPUT_HOST}:${INPUT_PORT}"
fi
docker context use remote
docker context ls
echo "::endgroup::"

if [ -n "${INPUT_ENV_FILE}" ];then
    echo -e "::group::Sourcing Environment File: \u001b[36;1m${INPUT_ENV_FILE}"
    stat "${INPUT_ENV_FILE}"
    set -a
    # shellcheck disable=SC1090
    source "${INPUT_ENV_FILE}"
echo "::endgroup::"
fi

if [[ -n "${INPUT_REGISTRY_USER}" && -n "${INPUT_REGISTRY_PASS}" ]];then
    echo -e "::group::Logging in to Registry: \u001b[36;1m${INPUT_REGISTRY_HOST:-Docker Hub}"
    echo "${INPUT_REGISTRY_PASS}" |
        docker login --username "${INPUT_REGISTRY_USER}" --password-stdin "${INPUT_REGISTRY_HOST}"
    INPUT_REGISTRY_AUTH="true"
    echo "::endgroup::"
fi

echo -e "Deploying Stack: \u001b[36;1m${INPUT_NAME}"
EXTRA_ARGS=()
if [[ -n "${INPUT_REGISTRY_AUTH}" ]];then
    echo -e "Enabling Registry Authentication"
    EXTRA_ARGS+=("--with-registry-auth")
fi
# shellcheck disable=SC2034
STACK_RESULTS=$(docker stack deploy -c "${INPUT_FILE}" "${INPUT_NAME}" "${EXTRA_ARGS[@]}")

if [[ "${INPUT_SUMMARY}" == "true" ]];then
    echo "📝 Writing Job Summary"
    # shellcheck source=/src/summary.sh
    source /src/summary.sh >> "${GITHUB_STEP_SUMMARY}"
fi
