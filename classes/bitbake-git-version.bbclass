# pretty much just like gitpkgv.bbclass, except I wanted git describe --tags --always
# https://github.com/openembedded/meta-openembedded/blob/master/meta-oe/classes/gitpkgv.bbclass

BITBAKE_GIT_VER_TAG       = "${@get_git_tag(d)}"
BITBAKE_GIT_VER_SHA       = "${@get_git_hash(d)}"
BITBAKE_GIT_VER_SHA_SHORT = "${@get_git_hash_short(d)}"

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
    import os
    import bb
    from pipes import quote

    src_uri = d.getVar('SRC_URI').split()
    fetcher = bb.fetch2.Fetch(src_uri, d)
    ud      = fetcher.ud
    vars    = {
                'repodir' : "GIT_INVALID_URL",
                'rev'     : "GIT_HASH_ERROR",
                'tag'     : "GIT_TAG_ERROR",
                'args'    : d.getVar('BITBAKE_GIT_DESCRIBE_ARGS'),
              }

    for url in ud.values():
      if url.type == 'git' or url.type == 'gitsm':
        for name, rev in url.revisions.items():
          if not os.path.exists(url.localpath):
            return vars

          try:
            vars['repodir'] = quote(url.localpath)
            vars['rev']     = quote(rev)
            vars['tag']     = bb.fetch2.runfetchcmd( "git --git-dir=%(repodir)s describe %(rev)s %(args)s 2>/dev/null" % vars, d, quiet=True).strip()

            return vars

          except Exception:
            continue

    return vars
