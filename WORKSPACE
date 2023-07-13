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

########
# Python
########

load("//build/rules:python.bzl", "py3_download")

py3_download(name = "py3")

register_toolchains("@py3//:toolchain")

http_archive(
    name = "rules_python",
    sha256 = "84aec9e21cc56fbc7f1335035a71c850d1b9b5cc6ff497306f84cced9a769841",
    strip_prefix = "rules_python-0.23.1",
    url = "https://github.com/bazelbuild/rules_python/releases/download/0.23.1/rules_python-0.23.1.tar.gz",
)

load("@rules_python//python:pip.bzl", "pip_parse")

http_archive(
    name = "rules_python_gazelle_plugin",
    sha256 = "84aec9e21cc56fbc7f1335035a71c850d1b9b5cc6ff497306f84cced9a769841",
    strip_prefix = "rules_python-0.23.1/gazelle",
    url = "https://github.com/bazelbuild/rules_python/releases/download/0.23.1/rules_python-0.23.1.tar.gz",
)

pip_parse(
    name = "pip",
    python_interpreter_target = "@py3//:bin/python3",
    requirements_lock = "//:requirements.txt",
)

load("@pip//:requirements.bzl", "install_deps")

# Initialize repositories for all packages in requirements_lock.txt.
install_deps()

load("@rules_python//gazelle:deps.bzl", _py_gazelle_deps = "gazelle_deps")

_py_gazelle_deps()

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

#####
# OCI
#####

http_archive(
    name = "rules_oci",
    sha256 = "db57efd706f01eb3ce771468366baa1614b5b25f4cce99757e2b8d942155b8ec",
    strip_prefix = "rules_oci-1.0.0",
    url = "https://github.com/bazel-contrib/rules_oci/releases/download/v1.0.0/rules_oci-v1.0.0.tar.gz",
)

load("@rules_oci//oci:dependencies.bzl", "rules_oci_dependencies")

rules_oci_dependencies()

load("@rules_oci//oci:repositories.bzl", "LATEST_CRANE_VERSION", "oci_register_toolchains")

oci_register_toolchains(
    name = "oci",
    crane_version = LATEST_CRANE_VERSION,
)

#######
# Tools
#######

# XXX: Replace `http_file` with our custom `tool` rule. `http_file` is part of
# bazel_tools but only supports a single downloaded file. Our tools may be
# archives, binaries, or dmg files. The main reason we do this hack is so that
# renovate can update these dependencies when there are updates. Renovate knows
# about `http_file` and `http_archive` so our custom rule _looks_ like
# `http_file` but can support other types of downloads.
load("//build/rules:tools.bzl", http_file = "tool")

# shfmt
http_file(
    name = "shfmt_darwin_arm64",
    downloaded_file_path = "shfmt",
    sha256 = "633f242246ee0a866c5f5df25cbf61b6af0d5e143555aca32950059cf13d91e0",
    urls = ["https://github.com/mvdan/sh/releases/download/v3.6.0/shfmt_v3.6.0_darwin_arm64"],
)

http_file(
    name = "shfmt_darwin_amd64",
    downloaded_file_path = "shfmt",
    sha256 = "b8c9c025b498e2816b62f0b717f6032e9ab49e725a45b8205f52f66318f17185",
    urls = ["https://github.com/mvdan/sh/releases/download/v3.6.0/shfmt_v3.6.0_darwin_amd64"],
)

http_file(
    name = "shfmt_linux_amd64",
    downloaded_file_path = "shfmt",
    sha256 = "5741a02a641de7e56b8da170e71a97e58050d66a3cf485fb268d6a5a8bb74afb",
    urls = ["https://github.com/mvdan/sh/releases/download/v3.6.0/shfmt_v3.6.0_linux_amd64"],
)
