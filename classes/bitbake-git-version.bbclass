################################################################################
# references:
#     https://github.com/openembedded/meta-openembedded/blob/master/meta-oe/classes/gitpkgv.bbclass
#     https://github.com/openembedded/meta-openembedded/blob/master/meta-oe/classes/gitver.bbclass
#     https://github.com/yoctoproject/poky/blob/master/meta/classes/image-buildinfo.bbclass
#     https://github.com/yoctoproject/poky/blob/master/meta/lib/oe/buildcfg.py
################################################################################
# fmt: off
SSTATE_SKIP_CREATION         = "1"

BITBAKE_GIT_LAYER_SRC_PATH   = "${@get_layer_src_path(d)}"
BITBAKE_GIT_LAYER_TAG        = "${@do_re_processing(d, get_tag(d, '${BITBAKE_GIT_LAYER_SRC_PATH}'),  d.getVarFlags('BITBAKE_GIT_LAYER_TAG_RE'))}"
BITBAKE_GIT_LAYER_SHA        = "${@get_revision(d,                '${BITBAKE_GIT_LAYER_SRC_PATH}', short=False)}"
BITBAKE_GIT_LAYER_SHA_SHORT  = "${@get_revision(d,                '${BITBAKE_GIT_LAYER_SRC_PATH}', short=True)}"
BITBAKE_GIT_LAYER_REVISION   = "${@get_revision(d,                '${BITBAKE_GIT_LAYER_SRC_PATH}', verbose=True)}"
BITBAKE_GIT_RECIPE_SRC_PATH  = "${@get_recipe_src_path(d)}"
BITBAKE_GIT_RECIPE_TAG       = "${@do_re_processing(d, get_tag(d, '${BITBAKE_GIT_RECIPE_SRC_PATH}'), d.getVarFlags('BITBAKE_GIT_RECIPE_TAG_RE'))}"
BITBAKE_GIT_RECIPE_SHA       = "${@get_revision(d,                '${BITBAKE_GIT_RECIPE_SRC_PATH}', short=False)}"
BITBAKE_GIT_RECIPE_SHA_SHORT = "${@get_revision(d,                '${BITBAKE_GIT_RECIPE_SRC_PATH}', short=True)}"
BITBAKE_GIT_RECIPE_REVISION  = "${@get_revision(d,                '${BITBAKE_GIT_RECIPE_SRC_PATH}', verbose=True)}"
# fmt: on


################################################################################
################################################################################
################################################################################
def do_re_processing(d, tag: str, re_opts: dict) -> str:
    """
    do regex manipulation

    Each `re_opts` key is a space delimited string/array.
    Each `re_opts` key is processed sequentially, in the order of the following documentation.
    Each `re_opts` key's value(s) are split(' ') and then processed sequentially.

    `re_opts['search']` and `re_opts['replace']` must have equal number entries.
    `re_opts['count']` also, though it can be left blank to default all pairs to zero.

    Parameters
    ----------
    re_opts: dict

    `re_opts['delete']` : str, regex, space separated list
        delete any/all matches from this list (i.e. replace match w/ empty string)
    `re_opts['search']` : str, regex, space separated list
        replace matches with corresponding value in `re_opts['replace']`
    `re_opts['replace']` : str, space separated list
        replacement value for corresponding `re_opts['search']` matches
    `re_opts['count']` : str, space separated list of int values
        max number of occurences to replace for each corresponding search/replace pair
        zero will replace all occurences
        missing/empty/undefined will default to zero for all search/replace pairs
    `re_opts['match']` : str, regex, space separated list
        extract match and truncate/assign `tag` to that value
    """
    import re
    import functools

    tag = functools.reduce(
        lambda tag, delete: re.sub(delete, "", tag),
        re_opts.get("delete", "").strip().split(" "),
        tag,
    )

    try:
        searches = re_opts.get("search" , "").strip().split(" ")  # fmt: skip
        replaces = re_opts.get("replace", "").strip().split(" ")  # fmt: skip
        counts   = re_opts.get("count"  , "").strip().split(" ")  # fmt: skip

        # filter counts list to only include valid ints
        # this can be empty (and will default to all zeros)
        # ... otherwise its len should match search/replace
        counts = [int(c) for c in counts if (isinstance(c, int) or c.isdigit())]
        counts = counts if counts else ([0] * len(searches))

        for search, replace, count in zip(searches, replaces, counts, strict=True):
            tag = re.sub(str(search), str(replace), tag, count=int(count))
    except ValueError as e:
        bb.warn(f"{e}")
        bb.fatal(
            f"bitbake-git-version [search] [replace] and [count] must have equal number of entries"
        )

    for match in re_opts.get("match", "").strip().split(" "):
        if m := re.search(match, tag):
            tag = m[0] if m[0] else tag

    return tag


################################################################################
################################################################################
################################################################################
def _do_fetch2_git_cmd(d, src_path: str, git_sub_cmd: str) -> str:
    """wrapper to exec and return git cmd stdout via `bb.fetch2.runfetchcmd`"""
    work_dir = src_path
    git_dir = os.path.abspath(os.path.join(src_path, ".git"))
    if os.path.isdir(git_dir):
        return bb.fetch2.runfetchcmd(
            f"git --git-dir={git_dir} --work-tree={work_dir} {git_sub_cmd}",
            d,
            quiet=True,
        ).strip()
    return ""


def get_branch(d, src_path: str) -> str:
    """current branch of git repo `src_path`"""
    return _do_fetch2_git_cmd(d, src_path, "rev-parse --abbrev-ref HEAD")


def get_is_modified(d, src_path: str) -> str:
    """
    determine if git repo `src_path` is clean or modified

    Returns
    -------
    str
        A clean repo will return an empty string.
        A dirty repo will return ` -- modified`.

        This format matches `oe.buildcfg.get_is_layer_modified`.
    """

    return (
        " -- modified"
        if _do_fetch2_git_cmd(d, src_path, f"describe --always --dirty").endswith( "-dirty")  # fmt: skip
        else ""
    )


def get_revision(d, src_path: str, short: bool = False, verbose: bool = False) -> str:
    """
    current revision of git repo `src_path`

    Parameters
    ----------
    short : bool
        control to select full length vs truncated hash
    verbose : bool
        control to include additional information (name, branch, etc)
        This format matches `oe.buildcfg.get_layer_revisions` (used by `image-buildinfo.bbclass`)

        `verbose` output may have spaces; variable expansion may need to be enclsoed in single quotes.

    Returns
    -------
    str
        If `verbose=False`, return only the git rev/hash
        If `verbose=True`, return: `name = branch:HASH[ -- modified]`
    """
    rev = _do_fetch2_git_cmd(d, src_path, "rev-parse HEAD")
    rev = rev[:7] if short else rev
    if verbose:
        return "%s = %s:%s%s" % (  # format should match oe.buildcfg.get_layer_revisions
            determine_repo_name(d, src_path),
            get_branch(d, src_path),
            rev,
            get_is_modified(d, src_path),
        )
    return rev


def get_tag(d, src_path: str) -> str:
    """
    current tag of git repo `src_path`

    Parameters
    ----------
    `BITBAKE_GIT_DESCRIBE_ARGS` : bitbake env variable, str, `git describe` options
        used as args to the `git describe` command
    """
    args = d.getVar("BITBAKE_GIT_DESCRIBE_ARGS") or ""
    return _do_fetch2_git_cmd(d, src_path, f"describe {args}")


################################################################################
################################################################################
################################################################################
def get_layer_name(d) -> str:
    """name of layer"""
    return os.path.basename(get_layer_path(d)) or ""


def get_layer_path(d) -> str:
    """path to layer directory"""
    return (
        os.path.abspath(
            next(
                filter(
                    lambda x: (d.getVar("FILE_LAYERNAME") or "") == os.path.basename(x),
                    (d.getVar("BBLAYERS") or "").split(),
                )
            )
        )
        or ""
    )


def get_layer_src_path(d) -> str:
    """path to layer source directory"""
    return os.path.abspath(get_layer_path(d)) or ""


################################################################################
################################################################################
################################################################################
def get_recipe_name(d) -> str:
    """name of recipe"""
    return d.getVar("PN") or ""


def get_recipe_path(d) -> str:
    """path to recipe file"""
    return os.path.abspath(d.getVar("FILE")) or ""


def get_recipe_src_path(d) -> str:
    """path to recipe source directory"""
    return (
        os.path.abspath(
            (d.getVar("EXTERNALSRC", expand=True) or d.getVar("S", expand=True))
        )
        or ""
    )


################################################################################
################################################################################
################################################################################
def determine_repo_name(d, src_path: str) -> str:
    """
    derive/determine name based on source directory path

    Compare to known paths (recipe, layer, etc) and return name on match.
    """
    match os.path.abspath(src_path.strip()):
        case str(s) if s == get_layer_src_path(d):
            return get_layer_name(d)
        case str(s) if s == get_recipe_src_path(d):
            return get_recipe_name(d)
        case _:
            return "REPO_NAME_ERROR"


################################################################################
