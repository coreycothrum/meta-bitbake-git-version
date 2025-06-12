SUMMARY          = "Bitbake Git Version Example"
DESCRIPTION      = "Bitbake Git Version Example"
LICENSE          = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRCBRANCH        = "master"
SRCREV           = "${AUTOREV}"
SRC_URI          = "git://github.com/coreycothrum/meta-bitbake-git-version.git;branch=${SRCBRANCH};protocol=https;"

inherit bitbake-git-version

do_install() {
  bbwarn "layer git hash (full)   : ${BITBAKE_GIT_LAYER_SHA}"
  bbwarn "layer git hash (short)  : ${BITBAKE_GIT_LAYER_SHA_SHORT}"
  bbwarn "layer git tag           : ${BITBAKE_GIT_LAYER_TAG}"
  bbwarn "layer git revision      : ${BITBAKE_GIT_LAYER_REVISION}"

  bbwarn "recipe git hash (full)  : ${BITBAKE_GIT_RECIPE_SHA}"
  bbwarn "recipe git hash (short) : ${BITBAKE_GIT_RECIPE_SHA_SHORT}"
  bbwarn "recipe git tag          : ${BITBAKE_GIT_RECIPE_TAG}"
  bbwarn "recipe git revision     : ${BITBAKE_GIT_RECIPE_REVISION}"
}
