# Copyright (C) 2018, 2019 Digi International

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

LOCALVERSION = "-dey"
SRCBRANCH = "v4.14.78/master"
SRCREV = "${AUTOREV}"

# Select internal or Github Linux repo
LINUX_GIT_URI ?= "${@oe.utils.conditional('DIGI_INTERNAL_GIT', '1' , '${DIGI_GIT}linux-2.6.git', '${DIGI_GITHUB_GIT}/linux.git', d)}"
SRC_URI = "${LINUX_GIT_URI};branch=${SRCBRANCH}"

S = "${WORKDIR}/git"