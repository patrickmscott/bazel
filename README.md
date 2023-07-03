# Bazel examples

This repo is a collection of examples building things under bazel. It is meant
as a guide for how to move from traditional build systems to the complexity that
is bazel.

# Getting started

There should be (almost) 0 dependencies needed to run this repo. However, there are some
things that make it easier.

`./bin/bazel build //...` should work without any fuss.

I recommend installing `direnv` so that `./bin` is added to your $PATH, making
`bazel build //...` work.

## Docker

- [ ] OCI images
- [ ] Dockerfile images
- [ ] Dockerfile images with binaries from the repo

## Testing

- [ ] Integration tests
- [ ] docker-compose tests
- [ ] minikube/k8s/k3s tests

## Golang

- [ ] Custom nogo analyzer
- [ ] Separate golang dependencies from project

## Gazelle

- [ ] Custom plugin

## Misc

- [ ] Aspect CLI plugins?
- [x] Runnable targets with captured arguments
- [x] Linters runnable in the working directory
