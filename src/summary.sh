#!/usr/bin/env bash

cat << EOM
## Stack Deploy Action

🎉 Stack \`${INPUT_NAME}\` Successfully Deployed.

<details><summary>Results</summary>

\`\`\`text
${STACK_RESULTS}
\`\`\`

</details>

[Report an issue or request a feature](https://github.com/cssnr/stack-deploy-action?tab=readme-ov-file#readme)
EOM
