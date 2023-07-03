#!/usr/bin/env bash

main() {
  local shfmt=$(pwd)/$1

  cd $BUILD_WORKING_DIRECTORY && $shfmt -w -s -i 2 -l $($shfmt -f .)
}

main "$@"
