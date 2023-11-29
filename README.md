# meta-bitbake-git-version
Provide GIT rev/tag info to a bitbake recipe.

Some string manipulation (via regex) of the tag is available.

## Overview
The following variables are produced by this layer/class
| Variable                      | Description                         |
| ---                           | ---                                 |
| ``BITBAKE_GIT_VER_TAG``       | GIT Tag, after any regex processing |
| ``BITBAKE_GIT_VER_SHA``       | Full  GIT Hash                      |
| ``BITBAKE_GIT_VER_SHA_SHORT`` | Short GIT HASH                      |

## Dependencies
This layer depends on:

    URI: git://git.openembedded.org/bitbake

    URI: git://git.openembedded.org/openembedded-core
    layers: meta
    branch: master

## Installation
### Add Layer to Build
In order to use this layer, the build system must be aware of it.

Assuming this layer exists at the top-level of the yocto build tree; add the location of this layer to ``bblayers.conf``, along with any additional layers needed:

    BBLAYERS ?= "                             \
      /path/to/yocto/meta                     \
      /path/to/yocto/meta-poky                \
      /path/to/yocto/meta-yocto-bsp           \
      /path/to/yocto/meta-bitbake-git-version \
      "

Alternatively, run bitbake-layers to add:

    $ bitbake-layers add-layer /path/to/yocto/meta-bitbake-git-version

## Using Layer
Add ``inherit bitbake-git-version`` to recipe.

Additional, optional, variables are provided to modify behavior:

    ## all config variables are optional
    ## default behavior is no REGEX manipulation
    ## I.E. the tag is passed through as-is

    ## additional arguments for 'git describe' command
    BITBAKE_GIT_DESCRIBE_ARGS      = "--tags --always"

    ## re.sub arguments ##
    ## regex pattern to sub(), if any (blank = noop)
    BITBAKE_GIT_VER_RE_SUB_SEARCH  = ""
    ## string to replace found sub pattern with (blank = delete sub string)
    BITBAKE_GIT_VER_RE_SUB_REPLACE = ""
    ## max number of found instances to replace, 0 = replace them all
    BITBAKE_GIT_VER_RE_SUB_COUNT   = "0"

    ## re.search arguments - performed after re.sub() ##
    ## if found in tag string, only return matching portion
    BITBAKE_GIT_VER_RE_MATCH       = ".*"

## Contributing
Please submit any patches against this layer via pull request.

Commits must be signed off.

Use [conventional commits](https://www.conventionalcommits.org/).

## Release Schedule and Roadmap
This layer will remain compatible with the latest [YOCTO LTS](https://wiki.yoctoproject.org/wiki/Releases).
