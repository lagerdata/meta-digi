# Copyright (C) 2017, 2018 Digi International Inc.

SUMMARY = "Microchip CryptoAuthentication Library"
SECTION = "libs"
LICENSE = "MICROCHIP_CRYPTOAUTHLIB_LICENSE"
LIC_FILES_CHKSUM = "file://license.txt;endline=19;md5=5bcd26c644867b127c2cce82960fae7b"

SRCBRANCH = "master"
SRCREV = "c6da3358a102c10d954372598c6efef8ad84c9ee"

CRYPTOAUTHLIB_URI_STASH = "${DIGI_MTK_GIT}linux/atmel-cryptoauthlib.git;protocol=ssh"
CRYPTOAUTHLIB_URI_GITHUB = "git://github.com/MicrochipTech/cryptoauthlib.git;protocol=git"
GIT_URI ?= "${@base_conditional('DIGI_INTERNAL_GIT', '1' , '${CRYPTOAUTHLIB_URI_STASH}', '${CRYPTOAUTHLIB_URI_GITHUB}', d)}"

SRC_URI = " \
    ${GIT_URI};nobranch=1 \
    file://0001-Port-changes-from-the-cryptoauth-engine-repo-to-the-.patch \
    file://0002-Remove-unused-HAL-implementations.patch \
"

S = "${WORKDIR}/git"

I2C_BUS = ""
I2C_BUS_ccimx6qpsbc = "1"
I2C_BUS_ccimx6ul = "0"

I2C_SPEED = ""
I2C_SPEED_ccimx6qpsbc = "100000"
I2C_SPEED_ccimx6ul = "100000"

CFLAGS += "-DATCA_HAL_I2C_BUS=${I2C_BUS} -DATCA_HAL_I2C_SPEED=${I2C_SPEED}"

do_patch[prefuncs] = "change_line_endings"

change_line_endings() {
	find ${S} -type f -name '*.[ch]' -print0 | xargs -0 sed -i -e 's/\r//g'
}

do_install() {
	oe_runmake DESTDIR=${D} install
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(ccimx6qpsbc|ccimx6ul)"
