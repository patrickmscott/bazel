#!/usr/bin/env bash

set -euo pipefail

main() {
  trap "docker rmi $1 >/dev/null || true" EXIT ERR

  docker build -q --no-cache -t $1 $(dirname $2) >/dev/null
  docker save $1 -o $3
}

main "$@"
