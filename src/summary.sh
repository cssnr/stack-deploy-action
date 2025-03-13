#!/usr/bin/env bash

# shellcheck disable=SC2154
cat << EOM
## Stack Deploy Action

🚀 ${_type} Stack \`${INPUT_NAME}\` Successfully Deployed.

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
