SUMMARY          = "Bitbake Git Version Example"
DESCRIPTION      = "Bitbake Git Version Example"
HOMEPAGE         = "https://github.com/coreycothrum/meta-bitbake-git-version"
LICENSE          = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit bitbake-git-version

do_install() {
  bbwarn "git hash (full)  : ${BITBAKE_GIT_VER_SHA}"
  bbwarn "git hash (short) : ${BITBAKE_GIT_VER_SHA_SHORT}"
  bbwarn "git tag          : ${BITBAKE_GIT_VER_TAG}"
}
