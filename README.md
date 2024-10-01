# meta-bitbake-git-version
Provide GIT rev/tag info to a bitbake recipe.

Some string manipulation (via regex) of the tag is available.

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

## Configuration
### Variables
| Variable                           | Defaults                    | Description                                                     |
| ---                                | ---                         | ---                                                             |
| ``BITBAKE_GIT_DESCRIBE_ARGS``      | ``--tags --always --dirty`` | arguments for ``git describe`` command                          |
| ``BITBAKE_GIT_VER_RE_SUB_SEARCH``  | ````                        | regex pattern to replace, if any (blank = noop)                 |
| ``BITBAKE_GIT_VER_RE_SUB_REPLACE`` | ````                        | replace found regex pattern with (blank = delete)               |
| ``BITBAKE_GIT_VER_RE_SUB_COUNT``   | ``0``                       | max number of found instances to replace (0 = replace them all) |
| ``BITBAKE_GIT_VER_RE_MATCH``       | ``.``                       | if found in tag string, only return matching portion            |

These are all optional. All the ``_RE_`` variables are hooks to manipulate the returned tag/rev.

## Usage
* Add ``inherit bitbake-git-version`` to the recipe(s).
* Additional/optional set [configuration variables](#Variables).

The following variables are produced by this layer/class.
| Variable                      | Description                         |
| ---                           | ---                                 |
| ``BITBAKE_GIT_VER_TAG``       | GIT Tag, after any regex processing |
| ``BITBAKE_GIT_VER_SHA``       | Full  GIT Hash                      |
| ``BITBAKE_GIT_VER_SHA_SHORT`` | Short GIT HASH                      |

These variables can be used inside other recipes to embedded git version information.

## Release Schedule and Roadmap
This layer will remain compatible with the latest [YOCTO LTS](https://wiki.yoctoproject.org/wiki/Releases).
