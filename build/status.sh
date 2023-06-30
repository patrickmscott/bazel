#!/usr/bin/env bash

set -euo pipefail

main() {
  local today=$(date +%Y%m%d)
  # Allow for setting the git commit in environments without git or where the
  # source might have the .git directory stripped (e.g. AWS Codebuild).
  local commit=${GIT_COMMIT:-$(git rev-parse HEAD)}

  cat <<-EOL
DOCKER_TAG $today-${commit:0:8}
EOL
}

main "$@"
