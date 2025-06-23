BITBAKE_GIT_LAYER_SRC_PATH         ??= ""
BITBAKE_GIT_LAYER_TAG              ??= "vERROR"
BITBAKE_GIT_LAYER_SHA              ??= "GIT_HASH_ERROR"
BITBAKE_GIT_LAYER_SHA_SHORT        ??= "GIT_HASH_ERROR"
BITBAKE_GIT_LAYER_REVISION         ??= "GIT_REV_ERROR"

BITBAKE_GIT_RECIPE_SRC_PATH        ??= ""
BITBAKE_GIT_RECIPE_TAG             ??= "vERROR"
BITBAKE_GIT_RECIPE_SHA             ??= "GIT_HASH_ERROR"
BITBAKE_GIT_RECIPE_SHA_SHORT       ??= "GIT_HASH_ERROR"
BITBAKE_GIT_RECIPE_REVISION        ??= "GIT_REV_ERROR"

################################################################################
BITBAKE_GIT_DESCRIBE_ARGS          ??= "--tags --always --dirty"

BITBAKE_GIT_RECIPE_TAG_RE[delete]  ??= ""
BITBAKE_GIT_RECIPE_TAG_RE[search]  ??= ""
BITBAKE_GIT_RECIPE_TAG_RE[replace] ??= ""
BITBAKE_GIT_RECIPE_TAG_RE[count]   ??= ""
BITBAKE_GIT_RECIPE_TAG_RE[match]   ??= ".*"

BITBAKE_GIT_LAYER_TAG_RE[match]    ??= ".*"
