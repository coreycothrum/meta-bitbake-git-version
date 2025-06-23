# meta-bitbake-git-version
[git](https://git-scm.com) rev/tag access inside bitbake recipe(s)

Convenience [variables](#Variables) to access a recipe's source repo git tag/rev information.

Very similar to
[gitpkgv](https://github.com/openembedded/meta-openembedded/blob/master/meta-oe/classes/gitpkgv.bbclass)
and/or
[gitver](https://github.com/openembedded/meta-openembedded/blob/master/meta-oe/classes/gitver.bbclass)
except:
* nicer/better/more options for [regex post processing](#Configuration) of the recipe's git tag
* convenient access to the parent layer's tag/rev
* works with [externalsrc](https://docs.yoctoproject.org/ref-manual/classes.html#externalsrc)


## Installation
### Add Layer to Build
In order to use this layer, the build system must be aware of it.

Assuming this layer exists at the top-level of the yocto build tree; add the location of this layer to `bblayers.conf`, along with any additional layers needed:

    BBLAYERS ?= "                             \
      /path/to/yocto/meta                     \
      /path/to/yocto/meta-poky                \
      /path/to/yocto/meta-yocto-bsp           \
      /path/to/yocto/meta-bitbake-git-version \
      "

Alternatively, run bitbake-layers to add:

    $ bitbake-layers add-layer /path/to/yocto/meta-bitbake-git-version


### Dependencies
This layer depends on:

    URI: git://git.openembedded.org/bitbake
    layers: meta
    branch: master

    URI: git://git.openembedded.org/openembedded-core
    layers: meta
    branch: master


## Usage
* Add `inherit bitbake-git-version` to the recipe(s).
* Optionally [configuration variables](#Configuration) to process reported git tag.

### Variables
The following variables are produced/set by this layer/class.
These variables can be used inside recipes to embedded git version information.

| Variable                       | Description                                   |
| ---                            | ---                                           |
| `BITBAKE_GIT_LAYER_SRC_PATH`   | parent layer source path                      |
| `BITBAKE_GIT_LAYER_TAG`        | parent layer tag, after regex post processing |
| `BITBAKE_GIT_LAYER_SHA`        | parent layer rev/hash (full)                  |
| `BITBAKE_GIT_LAYER_SHA_SHORT`  | parent layer rev/hash (short)                 |
| `BITBAKE_GIT_LAYER_REVISION`   | parent layer revision string                  |
| `BITBAKE_GIT_RECIPE_SRC_PATH`  | recipe git repo source path                   |
| `BITBAKE_GIT_RECIPE_TAG`       | recipe tag, after regex post processing       |
| `BITBAKE_GIT_RECIPE_SHA`       | recipe rev/hash (full)                        |
| `BITBAKE_GIT_RECIPE_SHA_SHORT` | recipe rev/hash (short)                       |
| `BITBAKE_GIT_RECIPE_REVISION`  | recipe revision string                        |


### Configuration
These variables are available to post-process `BITBAKE_GIT_RECIPE_TAG`.
All variables are optional.
There's a good chance default behavior is the right choice.

Notes:
* Each `BITBAKE_GIT_RECIPE_TAG_RE` flag is a space delimited string/array.
* Each flag is processed sequentially, in the order of the following documentation/table.
  * Each flag's items/entries/values are processed sequentially.
* Only `_RECIPE_` is documented here, but **there are corresponding `_LAYER_` variables to process `BITBAKE_GIT_LAYER_TAG`.**

| Variable                             | Defaults                  | Description                     |
| ---                                  | ---                       | ---                             |
| `BITBAKE_GIT_DESCRIBE_ARGS`          | `--tags --always --dirty` | args provided to `git describe` |
| `BITBAKE_GIT_RECIPE_TAG_RE[delete]`  | `​`                  | regex pattern(s) to search and delete/remove any/all matches (i.e. replace match with empty string)                                            |
| `BITBAKE_GIT_RECIPE_TAG_RE[search]`  | `​`                  | regex pattern(s) to search and replace with corresponding `[replace]` values. `[search]` and `[replace]` must have the same number of entries. |
| `BITBAKE_GIT_RECIPE_TAG_RE[replace]` | `​`                  | string(s) to replace corresponding `[search]` matches. `[search]` and `[replace]` must have the same number of entries.                        |
| `BITBAKE_GIT_RECIPE_TAG_RE[count]`   | `​`                  | max number of occurences to replace. Zero will replace all occurences. This can be left undefined/empty to process all occurences for all pairs. Otherwise each `[search]`/`[replace]` pair must have a corresponding `[count]`. |
| `BITBAKE_GIT_RECIPE_TAG_RE[match]`   | `.*`                      | regex pattern(s) to truncate to. A match will be extracted and the tag assigned to that value. No matches will return the full tag. Empty is a NOOP. |


### Recipe Signature Dependency
To ensure reliable triggering on revision changes, add `BITBAKE_GIT_*_REVISION` to applicable task(s) `[vardeps]`.
e.g.:
```
do_configure[vardeps] += "BITBAKE_GIT_LAYER_REVISION BITBAKE_GIT_RECIPE_REVISION"
```

## Release Schedule and Roadmap
This layer will remain compatible with the latest [YOCTO LTS](https://wiki.yoctoproject.org/wiki/Releases).
