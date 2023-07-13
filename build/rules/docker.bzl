load("@rules_oci//oci:defs.bzl", "oci_image", "oci_tarball")

def _dockerfile_image_impl(ctx):
    """Core implementation of dockerfile_image."""

    tag = "bazel/{}:{}".format(ctx.label.package, ctx.label.name)
    image_tar = ctx.actions.declare_file("{}.tar".format(ctx.label.name))
    inputs = [ctx.file.dockerfile]
    for d in ctx.attr.data:
        inputs.extend(d.files.to_list())
    ctx.actions.run(
        outputs = [image_tar],
        inputs = inputs,
        arguments = [
            tag,
            ctx.file.dockerfile.short_path,
            image_tar.path,
        ],
        executable = ctx.executable._builder,
        mnemonic = "DockerBuild",
        execution_requirements = {"no-sandbox": "1"},
    )

    return DefaultInfo(files = depset([image_tar]))

dockerfile_image = rule(
    attrs = {
        "dockerfile": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "The label for the Dockerfile to build the image from.",
        ),
        "data": attr.label_list(allow_files = True),
        "_builder": attr.label(
            allow_single_file = True,
            default = ":docker_build.sh",
            executable = True,
            cfg = "exec",
        ),
    },
    implementation = _dockerfile_image_impl,
)

def _image_impl(ctx):
    runner = ctx.actions.declare_file("run.sh")
    ctx.actions.expand_template(
        template = ctx.file._runner,
        output = runner,
        substitutions = {
            "{TARBALL}": ctx.attr.tarball.files.to_list()[0].short_path,
            "{TAG}": ctx.attr.tag,
        },
        is_executable = True,
    )
    ctx.actions.run(
        outputs = [ctx.outputs.digest],
        inputs = ctx.attr.oci.files.to_list(),
        executable = runner,
        arguments = [
            "--digest",
            ctx.outputs.digest.path,
            ctx.attr.oci.files.to_list()[0].path,
        ],
        mnemonic = "ImageDigest",
    )
    return DefaultInfo(
        runfiles = ctx.runfiles(
            files = ctx.attr.tarball.files.to_list(),
        ),
        executable = runner,
    )

_image = rule(
    implementation = _image_impl,
    attrs = {
        "oci": attr.label(mandatory = True),
        "tarball": attr.label(mandatory = True),
        "tag": attr.string(mandatory = True),
        "_runner": attr.label(
            allow_single_file = True,
            default = ":run.tmpl.sh",
        ),
    },
    outputs = {
        "digest": "%{name}.digest",
    },
    executable = True,
)

def image(name, **kwargs):
    oci = name + ".oci"
    tar = name + ".tar"
    tag = "bazel/{}:{}".format(native.package_name(), name)

    oci_image(name = oci, **kwargs)
    oci_tarball(
        name = tar,
        image = oci,
        repo_tags = [tag],
    )
    _image(name = name, oci = oci, tarball = tar, tag = tag)
