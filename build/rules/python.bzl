"""py3_download downloads and creates a python toolchain

This toolchain can be registered with bazel for use instead of the local
interpreter. It only supports python3 and expicitly disables python2.
"""

_PY3_CONFIGS = {
    "darwin_arm64": (
        "20220630/cpython-3.10.5+20220630-aarch64-apple-darwin-install_only.tar.gz",
        "19d1aa4a6d9ddb0094fc36961b129de9abe1673bce66c86cd97b582795c496a8",
        ["@platforms//os:osx", "@platforms//cpu:arm64"],
    ),
    "darwin_amd64": (
        "20220630/cpython-3.10.5+20220630-x86_64-apple-darwin-install_only.tar.gz",
        "eca0584397d9a3ef6f7bb32b0476318b01c89b7b0a031ef97a0dcaa5ba5127a8",
        ["@platforms//os:osx", "@platforms//cpu:x86_64"],
    ),
    "linux_amd64": (
        "20220630/cpython-3.10.5+20220630-x86_64-unknown-linux-gnu-install_only.tar.gz",
        "460f87a389be28c953c24c6f942f172f9ce7f331367b4daf89cb450baedd51d7",
        ["@platforms//os:linux", "@platforms//cpu:x86_64"],
    ),
}

_PY3_BASE_URL = "https://github.com/indygreg/python-build-standalone/releases/download/"

def _os_name(rctx):
    """Get the combined os/arch name from a repository context."""
    if rctx.os.name == "linux":
        if rctx.os.arch == "amd64":
            return "linux_amd64"
    elif rctx.os.name == "mac os x":
        if rctx.os.arch == "aarch64":
            return "darwin_arm64"
        elif rctx.os.arch == "x86_64":
            return "darwin_amd64"

    fail("Unsupported operating system: {}/{}".format(rctx.os.name, rctx.os.arch))

def _py3_download_impl(ctx):
    cfg = _PY3_CONFIGS.get(_os_name(ctx))
    ctx.download_and_extract(
        url = _PY3_BASE_URL + cfg[0],
        sha256 = cfg[1],
        stripPrefix = "python",
    )

    ctx.file(
        "BUILD",
        """
load("@bazel_tools//tools/python:toolchain.bzl", "py_runtime_pair")

filegroup(
    name = "interpreter",
    srcs = ["bin/python3"],
    visibility = ["//visibility:public"],
)

py_runtime(
    name = "py_runtime",
    interpreter = ":interpreter",
    python_version = "PY3",
)

py_runtime_pair(
    name = "py_runtime_pair",
    py2_runtime = None,
    py3_runtime = ":py_runtime",
)

toolchain(
    name = "toolchain",
    exec_compatible_with = [{constraints}],
    target_compatible_with = [{constraints}],
    toolchain = ":py_runtime_pair",
    toolchain_type = "@bazel_tools//tools/python:toolchain_type",
    visibility = ["//visibility:public"],
)
""".format(constraints = ",".join(['"{}"'.format(c) for c in cfg[2]])),
    )

    return None

py3_download = repository_rule(
    implementation = _py3_download_impl,
)
