################################################################################
# pretty much just like gitpkgv.bbclass and gitver.bbclass, except:
#   1) different git describe options
#   2) works with externalsrc
# https://github.com/openembedded/meta-openembedded/blob/master/meta-oe/classes/gitpkgv.bbclass
# https://github.com/openembedded/meta-openembedded/blob/master/meta-oe/classes/gitver.bbclass
################################################################################
BITBAKE_GIT_VER_TAG       = "${@get_git_tag(d)}"
BITBAKE_GIT_VER_SHA       = "${@get_git_hash(d)}"
BITBAKE_GIT_VER_SHA_SHORT = "${@get_git_hash_short(d)}"

################################################################################
################################################################################
################################################################################
def get_layer_path(d):
    import os
    return next(filter(lambda x: (d.getVar("FILE_LAYERNAME") or "") == os.path.basename(x), (d.getVar("BBLAYERS") or "").split()))

def get_layer_name(d):
    import os
    return os.path.basename(get_layer_path(d))

def get_layer_branch(d):
    return oe.buildcfg.get_metadata_git_branch(get_layer_path(d)).strip()

def get_layer_is_modified(d):
    return oe.buildcfg.is_layer_modified(get_layer_path(d))

# short   : short vs full length rev hash
# verbose : return formatted string w/ extra info (name, branch, etc)
#
# warning: verbose=True may return spaces, enclose in single quotes when using this option:
#     e.g. : -DREV='${@get_layer_revision(d, True, True)}'
#
# reference:
#     poky/meta/classes/image-buildinfo.bbclass : get_layer_revs(d):
#     poky/meta/lib/oe/buildcfg.py              : get_layer_revisions(d)
def get_layer_revision(d, short:bool=False, verbose:bool=False):
    rev = oe.buildcfg.get_metadata_git_revision(get_layer_path(d))
    rev = rev[:7] if short else rev
    return ("%s = %s:%s%s" % (get_layer_name(d), get_layer_branch(d), rev, get_layer_is_modified(d))) if verbose else rev

# same as oe.buildcfg.get_metadata_git_describe(path)
# ...but using supplied BITBAKE_GIT_DESCRIBE_ARGS
def get_layer_tag(d):
    try:
        describe,_ = bb.process.run(f'git describe {(d.getVar("BITBAKE_GIT_DESCRIBE_ARGS") or "")}', cwd=get_layer_path(d))
    except bb.process.ExecutionError:
        return "GIT_ERROR"
    return describe.strip()

################################################################################
def get_git_tag(d):
  return do_git_regex( do_git_describe(d)['tag'], d )

def get_git_hash(d):
  return do_git_describe(d)['rev']

def get_git_hash_short(d):
  return get_git_hash(d)[:7]

################################################################################
def do_git_regex(git_str, d):
  import re

  git_str = re.sub(
                    d.getVar('BITBAKE_GIT_VER_RE_SUB_SEARCH'),
                    d.getVar('BITBAKE_GIT_VER_RE_SUB_REPLACE'),
                    git_str,
                    count=int(d.getVar('BITBAKE_GIT_VER_RE_SUB_COUNT', 0))
                  )

  match   = re.search(d.getVar('BITBAKE_GIT_VER_RE_MATCH'), git_str)

  if match:
    git_str = match[0] if match[0] else git_str

  return git_str

################################################################################
def do_git_describe(d):
  import bb
  import os
  from pipes import quote

  vars = {
           'args'    : d.getVar('BITBAKE_GIT_DESCRIBE_ARGS'),
           'repodir' : "GIT_REPO_ERROR",
           'rev'     : "GIT_HASH_ERROR",
           'tag'     : "GIT_TAG_ERROR",
         }

  if d.getVar('EXTERNALSRC', None):
    vars['repodir'] = os.path.abspath(os.path.join(d.getVar('EXTERNALSRC', expand=True), ".git"))

    if os.path.isdir(vars['repodir']):
      (vars['rev'], _) = bb.process.run("git --git-dir=%(repodir)s rev-parse HEAD     2>/dev/null" % vars)
      (vars['tag'], _) = bb.process.run("git --git-dir=%(repodir)s describe  %(args)s 2>/dev/null" % vars)

      vars['rev'].strip()
      vars['tag'].strip()

      return vars

  else:
    src_uri = d.getVar('SRC_URI').split()
    fetcher = bb.fetch2.Fetch(src_uri, d)
    ud      = fetcher.ud

    for url in ud.values():
      if url.type == 'git' or url.type == 'gitsm':
        for name, rev in url.revisions.items():
          if not os.path.exists(url.localpath):
            continue

          try:
            vars['args']    = vars['args'].replace('--dirty', '').replace('--broken', '') # not compat w/ <commit-ish> :(
            vars['repodir'] = quote(url.localpath)
            vars['rev']     = quote(rev)
            vars['tag']     = bb.fetch2.runfetchcmd( "git --git-dir=%(repodir)s describe %(rev)s %(args)s 2>/dev/null" % vars, d, quiet=True).strip()

            return vars

          except Exception:
            continue

  return vars

################################################################################
