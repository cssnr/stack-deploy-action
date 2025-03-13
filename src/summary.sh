#!/usr/bin/env bash

# shellcheck disable=SC2154
cat << EOM
## Stack Deploy Action

🎉 ${_type} Stack \`${INPUT_NAME}\` Successfully Deployed.

\`\`\`text
${COMMAND[*]}
\`\`\`

<details><summary>Results</summary>

\`\`\`text
${STACK_RESULTS}
\`\`\`

</details>

[Report an issue or request a feature](https://github.com/cssnr/stack-deploy-action?tab=readme-ov-file#readme)

---
EOM
