"""Rules for downloading and interacting with host tools.

`tool` is used to declare binary tools in `WORKSPACE`
`host_tool` is used to refer to those downloaded tools
"""

load("@bazel_tools//tools/build_defs/repo:utils.bzl", "update_attrs")

def _tool_impl(ctx):
    ctx.file("WORKSPACE", "workspace(name = \"{name}\")".format(name = ctx.name))
    ctx.file("BUILD", """
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "tool",
    srcs = ["{name}"],
)
""".format(name = ctx.attr.downloaded_file_path))

    # Grab the first url to check the extension
    ext = ctx.attr.urls[0].split(".")[-1]
    download_info = None
    if ext == "dmg":
        download_info = _dmg_impl(ctx)
    elif ext in ("tar", "bz2", "gz", "tgz", "zip"):
        download_info = _archive_impl(ctx)
    else:
        download_info = _file_impl(ctx)

    return update_attrs(ctx.attr, _tool_attrs.keys(), {"sha256": download_info.sha256})

def _dmg_impl(ctx):
    """Download a dmg file, mount it to a temp location, and extract the tool."""
    if not ctx.attr.archive_file_path:
        fail("archive_file_path is required for .dmg tools")

    # Download the dmg file to a temporary location.
    download_info = ctx.download(
        url = ctx.attr.urls,
        output = "dl.dmg",
        sha256 = ctx.attr.sha256,
    )

    # Extract the binary to the requested target.
    res = ctx.execute([
        ctx.attr._extractor,
        "dl.dmg",
        ctx.attr.archive_file_path,
        ctx.attr.downloaded_file_path,
    ])
    if res.return_code:
        fail("failed to extract source file: " + res.stderr)

    return download_info

def _archive_impl(ctx):
    """Download an archive and extract the contents."""
    return ctx.download_and_extract(
        url = ctx.attr.urls,
        sha256 = ctx.attr.sha256,
        stripPrefix = ctx.attr.strip_prefix,
    )

def _file_impl(ctx):
    return ctx.download(
        url = ctx.attr.urls,
        output = ctx.attr.downloaded_file_path,
        sha256 = ctx.attr.sha256,
        executable = True,
    )

_tool_attrs = {
    "downloaded_file_path": attr.string(
        mandatory = True,
        doc = "Path assigned to the file downloaded",
    ),
    "sha256": attr.string(
        doc = """The expected SHA-256 of the file downloaded.

This must match the SHA-256 of the file downloaded. _It is a security risk
to omit the SHA-256 as remote files can change._ At best omitting this
field will make your build non-hermetic. It is optional to make development
easier but should be set before shipping.""",
    ),
    "urls": attr.string_list(
        mandatory = True,
        doc = """A list of URLs to a file that will be made available to Bazel.

Each entry must be a file, http or https URL. Redirections are followed.
Authentication is not supported.""",
    ),
    "strip_prefix": attr.string(
        doc = """The prefix to strip when extracting archives.""",
    ),
    "archive_file_path": attr.string(
        doc = """The path within the archive to extract.""",
    ),
    "_extractor": attr.label(default = ":extractor.sh"),
}

tool = repository_rule(
    implementation = _tool_impl,
    attrs = _tool_attrs,
)

def host_tool(name, **kwargs):
    """host_tool is a shortcut for aliasing a tool to the host version.

    It relies on tools being defind using the `tool` rule above with all supported architectures. It
    assumes a certain naming convention:

    <name>_darwin_arm64
    <name>_linux_amd64
    <name>_darwin_amd64
    """
    native.alias(
        name = name,
        actual = select({
            "@bazel_tools//src/conditions:linux_x86_64": "@{}_linux_amd64//:tool".format(name),
            "@bazel_tools//src/conditions:darwin_arm64": "@{}_darwin_arm64//:tool".format(name),
            "@bazel_tools//src/conditions:darwin_x86_64": "@{}_darwin_amd64//:tool".format(name),
        }),
        **kwargs
    )

def _run_with_args_impl(ctx):
    script = ctx.actions.declare_file(ctx.label.name + "_with_args.sh")

    ctx.actions.expand_template(
        template = ctx.file._template,
        output = script,
        substitutions = {
            "{TOOL}": ctx.executable.tool.short_path,
            "{ARGS}": " ".join([ctx.expand_location(v) for v in ctx.attr.arguments]),
        },
        is_executable = True,
    )

    files = ctx.files.tools + [ctx.executable.tool]

    runfiles = ctx.runfiles(files = files).merge_all([
        ctx.attr._runfiles.default_runfiles,
        ctx.attr.tool.default_runfiles,
    ] + [d.default_runfiles for d in ctx.attr.tools])
    return [DefaultInfo(runfiles = runfiles, executable = script)]

run_with_args = rule(
    implementation = _run_with_args_impl,
    attrs = {
        "tool": attr.label(
            mandatory = True,
            allow_files = True,
            executable = True,
            # This might seem wrong but we only use these tools on the host
            # platform. Setting cfg = "host" may cause the tool to be built
            # twice.
            cfg = "target",
        ),
        "arguments": attr.string_list(),
        # "tools" is a hack to get around differences in expand_location. This
        # has been fixed in bazel but has yet to be released.
        # https://github.com/bazelbuild/bazel/commit/414824173363e579d34afc1aa16bc97a220743dc
        "tools": attr.label_list(allow_files = True),
        "_template": attr.label(
            default = ":run_with_args.tmpl.sh",
            allow_single_file = True,
        ),
        "_runfiles": attr.label(
            default = "@bazel_tools//tools/bash/runfiles",
        ),
    },
    executable = True,
)
