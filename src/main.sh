#!/usr/bin/env bash
# https://github.com/cssnr/stack-deploy-action

set -e

# shellcheck disable=SC2317,SC2329
function cleanup_trap() {
    _ST="$?"
    if [[ -z "${INPUT_SSH_KEY}" ]];then
        echo "🧹 Cleaning Up authorized_keys"
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

## Check Variables

INPUT_MODE=$(echo "${INPUT_MODE}" | xargs | tr '[:upper:]' '[:lower:]')
echo "::debug::INPUT_MODE: ${INPUT_MODE}"

if [[ "${INPUT_MODE}" == "swarm" ]];then
    if [[ "${INPUT_ARGS}" != "--remove-orphans --force-recreate" ]];then
        echo "::warning::You set compose args but mode is swarm!"
    fi
elif [[ "${INPUT_MODE}" == "compose" ]];then
    if [[ "${INPUT_DETACH}" != "true" ]];then
        echo "::warning::You set detach but mode is compose!"
    fi
    if [[ "${INPUT_PRUNE}" != "false" ]];then
        echo "::warning::You set prune but mode is compose!"
    fi
    if [[ "${INPUT_RESOLVE_IMAGE}" != "always" ]];then
        echo "::warning::You set resolve_image but mode is compose!"
    fi
else
    echo "::error::Input mode must be set to swarm or compose!"
    echo "⛔ Input Parsing Failed. The mode must be set to swarm or compose."
    exit 1
fi

## Setup Script

SSH_DIR="/root/.ssh"

echo "::group::Starting Stack Deploy Action ${GITHUB_ACTION_REF}"
echo "User: $(whoami)"
echo "Script: ${0}"
echo "Current Directory: $(pwd)"
echo "Home Directory: ${HOME}"
echo "SSH Directory: ${SSH_DIR}"
echo "Deploy Mode: ${INPUT_MODE}"

mkdir -p "${SSH_DIR}" ~/.ssh
chmod 0700 "${SSH_DIR}" ~/.ssh

if [[ "${INPUT_DISABLE_KEYSCAN}" != "true" ]];then
    echo "Running: ssh-keyscan"
    ssh-keyscan -p "${INPUT_PORT}" -H "${INPUT_HOST}" >> "${SSH_DIR}/known_hosts"
fi
echo "::endgroup::"

## Setup Authentication

if [[ -z "${INPUT_SSH_KEY}" ]];then
    echo "::group::Copying SSH Key to Remote Host"
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

## Setup Docker Context

echo "::group::Verifying Remote Docker Context"
ssh -o BatchMode=yes -o ConnectTimeout=30 -p "${INPUT_PORT}" \
    "${INPUT_USER}@${INPUT_HOST}" "docker info" > /dev/null
if ! docker context inspect remote >/dev/null 2>&1;then
    docker context create remote --docker "host=ssh://${INPUT_USER}@${INPUT_HOST}:${INPUT_PORT}"
fi
docker context use remote
docker context ls
echo "::endgroup::"

## Export Environment File

if [[ -n "${INPUT_ENV_FILE}" ]];then
    if [[ -f "${INPUT_ENV_FILE}" ]];then
        echo -e "::group::Sourcing Environment File: \u001b[36;1m${INPUT_ENV_FILE}"
        set -a
        # shellcheck disable=SC1090
        source "${INPUT_ENV_FILE}"
        echo "::endgroup::"
    else
        echo "::error::Environment File Not Found: ${INPUT_ENV_FILE}"
    fi
else
    echo "::debug::No environment file specified, skipping export file..."
fi

## Docker Login

if [[ -n "${INPUT_REGISTRY_USER}" && -n "${INPUT_REGISTRY_PASS}" ]];then
    echo -e "::group::Logging in to Registry: \u001b[36;1m${INPUT_REGISTRY_HOST:-Docker Hub}"
    echo "${INPUT_REGISTRY_PASS}" |
        docker login --username "${INPUT_REGISTRY_USER}" --password-stdin "${INPUT_REGISTRY_HOST}"
    INPUT_REGISTRY_AUTH="true"
    echo "::endgroup::"
else
    echo "::debug::No registry user or password, skipping docker login..."
fi

## Collect Arguments

EXTRA_ARGS=()
if [[ "${INPUT_MODE}" == "swarm" ]];then
    echo "::debug::Processing Swarm Arguments"
    if [[ -n "${INPUT_REGISTRY_AUTH}" ]];then
        echo "::debug::Adding: --with-registry-auth"
        EXTRA_ARGS+=("--with-registry-auth")
    fi
    if [[ "${INPUT_DETACH}" == "true" ]];then
        echo "::debug::Adding: --detach=true"
        EXTRA_ARGS+=("--detach=true")
    else
        echo "::debug::Adding: --detach=false"
        EXTRA_ARGS+=("--detach=false")
    fi
    if [[ "${INPUT_PRUNE}" != "false" ]];then
        echo "::debug::Adding: --prune"
        EXTRA_ARGS+=("--prune")
    fi
    if [[ "${INPUT_RESOLVE_IMAGE}" != "always" ]];then
        if [[ "${INPUT_RESOLVE_IMAGE}" == "changed" || "${INPUT_RESOLVE_IMAGE}" == "never" ]];then
            echo "::debug::Adding: --resolve-image=${INPUT_RESOLVE_IMAGE}"
            EXTRA_ARGS+=("--resolve-image=${INPUT_RESOLVE_IMAGE}")
        else
            echo "::warning::Input resolve_image must be one of: always, changed, never"
        fi
    fi
else
    echo "::debug::Processing Compose Arguments"
    echo "::debug::Adding: ${INPUT_ARGS}"
    read -r -a args <<< "${INPUT_ARGS}"
    EXTRA_ARGS+=("${args[@]}")
fi
echo "::debug::EXTRA_ARGS: ${EXTRA_ARGS[*]}"

## Deploy Stack

if [[ "${INPUT_MODE}" == "swarm" ]];then
    DEPLOY_TYPE="Swarm"
    COMMAND=("docker" "stack" "deploy" "-c" "${INPUT_FILE}" "${EXTRA_ARGS[@]}" "${INPUT_NAME}")
else
    DEPLOY_TYPE="Compose"
    COMMAND=("docker" "compose" "-f" "${INPUT_FILE}" "-p" "${INPUT_NAME}" "up" "-d" "-y" "${EXTRA_ARGS[@]}")
fi

echo -e "::group::Deploying Docker ${DEPLOY_TYPE} Stack: \u001b[36;1m${INPUT_NAME}"
echo -e "\u001b[33;1m${COMMAND[*]}\n"
exec 5>&1
set +e
# shellcheck disable=SC2034
STACK_RESULTS=$( "${COMMAND[@]}" 2>&1 | tee >(cat >&5) ; exit "${PIPESTATUS[0]}" )
EXIT_STATUS="$?"
set -e
echo "::endgroup::"

## Write Summary

if [[ "${INPUT_SUMMARY}" == "true" ]];then
    echo "📝 Writing Job Summary"
    # shellcheck source=/src/summary.sh
    source /src/summary.sh >> "${GITHUB_STEP_SUMMARY}" ||
        echo "::error::Failed to Write Job Summary!"
fi

echo "::debug::EXIT_STATUS: ${EXIT_STATUS}"
exit "${EXIT_STATUS}"
