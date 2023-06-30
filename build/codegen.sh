#!/usr/bin/env bash

set -euo pipefail

main() {
  cd $BUILD_WORKSPACE_DIRECTORY

  bazel run @go_sdk//:bin/go mod tidy
  bazel run //build:gazelle -- update-repos \
    -from_file go.mod \
    -to_macro godeps.bzl%go_deps \
    -prune
  bazel run //build:gazelle
  bazel run //build:buildifier
}

main "$@"
