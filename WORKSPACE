workspace(name = "pms")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

####
# Go
####

http_archive(
    name = "io_bazel_rules_go",
    sha256 = "51dc53293afe317d2696d4d6433a4c33feedb7748a9e352072e2ec3c0dafd2c6",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.40.1/rules_go-v0.40.1.zip",
        "https://github.com/bazelbuild/rules_go/releases/download/v0.40.1/rules_go-v0.40.1.zip",
    ],
)

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains(
    nogo = "@//:nogo",
    version = "1.20",
)

http_archive(
    name = "bazel_gazelle",
    sha256 = "b8b6d75de6e4bf7c41b7737b183523085f56283f6db929b86c5e7e1f09cf59c9",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.31.1/bazel-gazelle-v0.31.1.tar.gz",
        "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.31.1/bazel-gazelle-v0.31.1.tar.gz",
    ],
)

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
load("//:godeps.bzl", "go_deps")

# gazelle:repository_macro godeps.bzl%go_deps
go_deps()

gazelle_dependencies()

###########################
# Packaging (tar, zip, etc)
###########################

http_archive(
    name = "rules_pkg",
    sha256 = "8f9ee2dc10c1ae514ee599a8b42ed99fa262b757058f65ad3c384289ff70c4b8",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_pkg/releases/download/0.9.1/rules_pkg-0.9.1.tar.gz",
        "https://github.com/bazelbuild/rules_pkg/releases/download/0.9.1/rules_pkg-0.9.1.tar.gz",
    ],
)

load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")

rules_pkg_dependencies()

##########
# Protobuf
##########

http_archive(
    name = "com_google_protobuf",
    sha256 = "0aa7df8289c957a4c54cbe694fbabe99b180e64ca0f8fdb5e2f76dcf56ff2422",
    strip_prefix = "protobuf-21.9",
    urls = ["https://github.com/protocolbuffers/protobuf/archive/v21.9.tar.gz"],
)

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()
