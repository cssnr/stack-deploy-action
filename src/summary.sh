#!/usr/bin/env bash
# shellcheck disable=SC2154

echo -e "## Stack Deploy Action\n"

if [[ "${EXIT_STATUS}" == 0 ]];then
    echo "🚀 ${_type} Stack \`${INPUT_NAME}\` Successfully Deployed."
else
    echo "⛔ ${_type} Stack \`${INPUT_NAME}\` Failed to Deploy!"
fi

cat << EOM

\`\`\`text
${COMMAND[*]}
\`\`\`

<details><summary>Results</summary>

\`\`\`text
${STACK_RESULTS}
\`\`\`

</details>

[View Documentation, Report Issues or Request Features](https://github.com/cssnr/stack-deploy-action?tab=readme-ov-file#readme)

---
EOM
