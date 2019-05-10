# Copyright (C) 2013-2019 Digi International Inc.

FILESEXTRAPATHS_prepend := "${THISDIR}/${BP}:"

INITSCRIPT_NAME = "networking"
INITSCRIPT_PARAMS = "start 03 2 3 4 5 . stop 80 0 6 1 ."

inherit systemd

SRC_URI_append = " \
    file://ifupdown.service \
    file://interfaces.br0.example \
    file://interfaces.p2p \
    file://p2plink \
    file://resolv \
"

SRC_URI_append_ccimx6qpsbc = "\
    file://interfaces.wlan1.static \
    file://interfaces.wlan1.dhcp \
    file://virtwlans \
"

SRC_URI_append_ccimx6ul = "\
    file://interfaces.wlan1.static \
    file://interfaces.wlan1.dhcp \
    file://virtwlans \
"

SRC_URI_append_ccimx8x = "\
    file://interfaces.wlan1.static \
    file://interfaces.wlan1.dhcp \
    file://virtwlans \
"

SYSTEMD_SERVICE_${PN} = "ifupdown.service"

WPA_DRIVER ?= "nl80211"

do_install_append() {
	# Install 'ifupdown' scripts
	install -m 0755 ${WORKDIR}/p2plink ${D}${sysconfdir}/network/if-up.d/
	install -m 0755 ${WORKDIR}/resolv ${D}${sysconfdir}/network/if-up.d/

	# Install systemd service
	install -d ${D}${systemd_unitdir}/system/
	install -m 0644 ${WORKDIR}/ifupdown.service ${D}${systemd_unitdir}/system/
	sed -i -e 's,@SBINDIR@,${base_sbindir},g' ${D}${systemd_unitdir}/system/ifupdown.service

	if [ -n "${HAVE_WIFI}" ]; then
		if [ -n "${WLAN_P2P_INTERFACE}" ]; then
			cat ${WORKDIR}/interfaces.p2p >> ${D}${sysconfdir}/network/interfaces
			[ -n "${WLAN_P2P_AUTO}" ] && sed -i -e 's/^#auto ##WLAN_P2P_INTERFACE##/auto ##WLAN_P2P_INTERFACE##/g' ${D}${sysconfdir}/network/interfaces
			sed -i -e 's,##WLAN_P2P_INTERFACE##,${WLAN_P2P_INTERFACE},g' ${D}${sysconfdir}/network/interfaces
		fi
	fi

	# Remove config entries if corresponding variable is not defined
	[ -z "${P2P0_STATIC_DNS}" ] && sed -i -e "/##P2P0_STATIC_DNS##/d" ${D}${sysconfdir}/network/interfaces
	[ -z "${P2P0_STATIC_GATEWAY}" ] && sed -i -e "/##P2P0_STATIC_GATEWAY##/d" ${D}${sysconfdir}/network/interfaces
	[ -z "${P2P0_STATIC_IP}" ] && sed -i -e "/##P2P0_STATIC_IP##/d" ${D}${sysconfdir}/network/interfaces
	[ -z "${P2P0_STATIC_NETMASK}" ] && sed -i -e "/##P2P0_STATIC_NETMASK##/d" ${D}${sysconfdir}/network/interfaces

	# Replace interface parameters
	sed -i -e "s,##P2P0_STATIC_IP##,${P2P0_STATIC_IP},g" ${D}${sysconfdir}/network/interfaces
	sed -i -e "s,##P2P0_STATIC_NETMASK##,${P2P0_STATIC_NETMASK},g" ${D}${sysconfdir}/network/interfaces
	sed -i -e "s,##P2P0_STATIC_GATEWAY##,${P2P0_STATIC_GATEWAY},g" ${D}${sysconfdir}/network/interfaces
	sed -i -e "s,##P2P0_STATIC_DNS##,${P2P0_STATIC_DNS},g" ${D}${sysconfdir}/network/interfaces
	sed -i -e "s,##WPA_DRIVER##,${WPA_DRIVER},g" ${D}${sysconfdir}/network/interfaces

	cat ${WORKDIR}/interfaces.br0.example >> ${D}${sysconfdir}/network/interfaces
}

install_virtwlans() {
	install -d ${D}${sysconfdir}/network/if-pre-up.d
	install -m 0755 ${WORKDIR}/virtwlans ${D}${sysconfdir}/network/if-pre-up.d/
	ln -s ../if-pre-up.d/virtwlans ${D}${sysconfdir}/network/if-post-down.d/virtwlans
}

WLAN1_POST_UP_ACTION = "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemctl start hostapd@wlan1.service', '/etc/init.d/hostapd start', d)}"
WLAN1_PRE_DOWN_ACTION = "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemctl stop hostapd@wlan1.service', '/etc/init.d/hostapd stop', d)}"

install_wlan1() {
	if [ -n "${HAVE_WIFI}" ]; then
		cat ${WORKDIR}/interfaces.wlan1.${WLAN1_MODE} >> ${D}${sysconfdir}/network/interfaces
		[ -n "${WLAN1_AUTO}" ] && sed -i -e 's/^#auto wlan1/auto wlan1/g' ${D}${sysconfdir}/network/interfaces
	fi

	# Remove config entries if corresponding variable is not defined
	[ -z "${WLAN1_STATIC_DNS}" ] && sed -i -e "/##WLAN1_STATIC_DNS##/d" ${D}${sysconfdir}/network/interfaces
	[ -z "${WLAN1_STATIC_GATEWAY}" ] && sed -i -e "/##WLAN1_STATIC_GATEWAY##/d" ${D}${sysconfdir}/network/interfaces
	[ -z "${WLAN1_STATIC_IP}" ] && sed -i -e "/##WLAN1_STATIC_IP##/d" ${D}${sysconfdir}/network/interfaces
	[ -z "${WLAN1_STATIC_NETMASK}" ] && sed -i -e "/##WLAN1_STATIC_NETMASK##/d" ${D}${sysconfdir}/network/interfaces

	# Replace interface parameters
	sed -i -e "s,##WLAN1_STATIC_IP##,${WLAN1_STATIC_IP},g" ${D}${sysconfdir}/network/interfaces
	sed -i -e "s,##WLAN1_STATIC_NETMASK##,${WLAN1_STATIC_NETMASK},g" ${D}${sysconfdir}/network/interfaces
	sed -i -e "s,##WLAN1_STATIC_GATEWAY##,${WLAN1_STATIC_GATEWAY},g" ${D}${sysconfdir}/network/interfaces
	sed -i -e "s,##WLAN1_STATIC_DNS##,${WLAN1_STATIC_DNS},g" ${D}${sysconfdir}/network/interfaces
	sed -i -e "s,##WLAN1_POST_UP_ACTION##,${WLAN1_POST_UP_ACTION},g" ${D}${sysconfdir}/network/interfaces
	sed -i -e "s,##WLAN1_PRE_DOWN_ACTION##,${WLAN1_PRE_DOWN_ACTION},g" ${D}${sysconfdir}/network/interfaces
}

do_install_append_ccimx6qpsbc() {
	install_virtwlans
	install_wlan1
}

do_install_append_ccimx6ul() {
	install_virtwlans
	install_wlan1
}

do_install_append_ccimx8x() {
	install_virtwlans
	install_wlan1
}

# Disable wireless interfaces on first boot for non-wireless variants
pkg_postinst_ontarget_${PN}() {
	if [ ! -d "/proc/device-tree/wireless" ]; then
		sed -i -e '/^auto wlan/{s,^,#,g};/^auto p2p/{s,^,#,g}' /etc/network/interfaces
	fi

	# Create the symlinks in the different runlevels
	if type update-rc.d >/dev/null 2>/dev/null; then
		update-rc.d ${INITSCRIPT_NAME} ${INITSCRIPT_PARAMS}
	fi

	exit 0
}
