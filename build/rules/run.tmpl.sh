#!/usr/bin/env bash

set -euo pipefail

main() {
  if [[ ${1-} == "--digest" ]]; then
    cat $3/index.json | jq -r ".manifests[0].digest" > $2
    exit 0
  fi

  docker load --input {TARBALL}
  if [[ ${1-} == "--no-run" ]]; then
    return
  fi
  docker run --rm -it {TAG} $@
}

main "$@"
