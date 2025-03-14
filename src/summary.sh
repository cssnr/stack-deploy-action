#!/usr/bin/env bash
# shellcheck disable=SC2154

if [[ "${EXIT_STATUS}" == 0 ]];then
    _result="🚀 ${_type} Stack \`${INPUT_NAME}\` Successfully Deployed."
    _details="<details><summary>Results</summary>"
else
    _result="⛔ ${_type} Stack \`${INPUT_NAME}\` Failed to Deploy!"
    _details="<details open><summary>Errors</summary>"
fi

cat << EOM
## Stack Deploy Action

${_result}

\`\`\`text
${COMMAND[*]}
\`\`\`

${_details}

\`\`\`text
${STACK_RESULTS}
\`\`\`

</details>

[View Documentation, Report Issues or Request Features](https://github.com/cssnr/stack-deploy-action?tab=readme-ov-file#readme)

---
EOM
