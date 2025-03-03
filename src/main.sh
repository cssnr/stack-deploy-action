#!/usr/bin/env bash
# https://github.com/cssnr/stack-deploy-action

set -e

function cleanup_trap() {
    _ST="$?"
    if [ -z "${INPUT_SSH_KEY}" ];then
        echo -e "🧹 Cleaning Up authorized_keys"
        ssh -o BatchMode=yes -o ConnectTimeout=30 -p "${INPUT_PORT}" "${INPUT_USER}@${INPUT_HOST}" \
            "sed -i '/docker-stack-deploy-action/d' ~/.ssh/authorized_keys"
    fi
    if [[ "${_ST}" != "0" ]]; then
        echo -e "⛔ \u001b[31;1mFailed to deploy stack ${INPUT_NAME}"
        echo "::error::Failed to deploy stack ${INPUT_NAME}. See logs for details..."
    else
        echo -e "✅ \u001b[32;1mFinished Success"
    fi
    exit "${_ST}"
}

SSH_DIR="/root/.ssh"

echo "::group::Starting Stack Deploy Action"
echo "User: $(whoami)"
echo "Script: ${0}"
echo "Current Directory: $(pwd)"
echo "Home Directory: ${HOME}"
echo "SSH Directory: ${SSH_DIR}"
mkdir -p "${SSH_DIR}" ~/.ssh
chmod 0700 "${SSH_DIR}" ~/.ssh
ssh-keyscan -p "${INPUT_PORT}" -H "${INPUT_HOST}" >> "${SSH_DIR}/known_hosts"
echo "::endgroup::"

if [ -z "${INPUT_SSH_KEY}" ];then
    echo -e "::group::Copying SSH Key to Remote Host"
    ssh-keygen -q -f "${SSH_DIR}/id_rsa" -N "" -C "docker-stack-deploy-action"
    eval "$(ssh-agent -s)"
    ssh-add "${SSH_DIR}/id_rsa"
    sshpass -eINPUT_PASS \
        ssh-copy-id -i "${SSH_DIR}/id_rsa" -o ConnectTimeout=30 \
            -p "${INPUT_PORT}" "${INPUT_USER}@${INPUT_HOST}"
else
    echo "::group::Adding SSH Key to SSH Agent"
    echo "${INPUT_SSH_KEY}" > "${SSH_DIR}/id_rsa"
    chmod 0600 "${SSH_DIR}/id_rsa"
    eval "$(ssh-agent -s)"
    ssh-add "${SSH_DIR}/id_rsa"
fi
echo "::endgroup::"

trap cleanup_trap EXIT HUP INT QUIT PIPE TERM

echo "::group::Verifying Remote Docker Context"
ssh -o BatchMode=yes -o ConnectTimeout=30 -p "${INPUT_PORT}" \
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

echo -e "::group::Deploying Stack: \u001b[36;1m${INPUT_NAME}"
EXTRA_ARGS=()
if [[ -n "${INPUT_REGISTRY_AUTH}" ]];then
    echo -e "Adding: --with-registry-auth"
    EXTRA_ARGS+=("--with-registry-auth")
fi
# shellcheck disable=SC2034
STACK_RESULTS=$(docker stack deploy -c "${INPUT_FILE}" "${INPUT_NAME}" "${EXTRA_ARGS[@]}")
echo "::endgroup::"

echo "${STACK_RESULTS}"

if [[ "${INPUT_SUMMARY}" == "true" ]];then
    echo "📝 Writing Job Summary"
    # shellcheck source=/src/summary.sh
    source /src/summary.sh >> "${GITHUB_STEP_SUMMARY}" ||\
        echo "::error::Failed to Write Job Summary!"
fi
