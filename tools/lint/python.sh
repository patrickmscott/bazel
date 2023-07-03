#!/usr/bin/env bash

set -euo pipefail

main() {
  local tools=()
  for t in $@; do
    tools+=($(pwd)/$t)
  done

  cd $BUILD_WORKING_DIRECTORY

  # Find additional files using a python shebang
  local files=()
  for file in $(git ls-files -o -c --exclude-standard | grep "\.py"); do
    files+=($file)
  done
  for file in $(git ls-files -o -c --exclude-standard); do
    if head -n1 $file | grep "#\!/usr/bin/env python" >/dev/null; then
      files+=($file)
    fi
  done

  for t in ${tools[@]}; do
    $t $files
  done
}

main "$@"
