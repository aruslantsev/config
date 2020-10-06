# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils

DESCRIPTION="Cisco AnyConnect VPN Client"
HOMEPAGE="http://www.cisco.com"
LICENSE="cisco"
SLOT="0"
KEYWORDS="amd64"

PKG_NAME="anyconnect-linux64-${PV}"
UNPACKED_NAME="${PKG_NAME}-predeploy-k9.tar.gz"

SRC_URI="${UNPACKED_NAME}"
RESTRICT="fetch strip"

RDEPEND="
	x11-libs/pangox-compat
"

INSTPREFIX="/opt/cisco"
# BINDIR=${INSTPREFIX}/bin
# PROFILEDIR=${INSTPREFIX}/profile
# SCRIPTDIR=${INSTPREFIX}/script

S="${WORKDIR}/ciscovpn"

pkg_nofetch() {
	einfo "Fetch ${SRC_URI} and put it into ${DISTDIR}"
}

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${PKG_NAME}" "${S}"
}

src_install() {
	echo "exit 0" > "${S}/vpn/vpndownloader"
	echo "exit 0" > "${S}/vpn/vpndownloader-cli"
	domenu "${S}/vpn/cisco-anyconnect.menu"

	insinto "${INSTPREFIX}"
	insopts -m444
	doins -r "${S}/vpn"
	doins -r "${S}/posture"

	# Attempt to install the init script in the proper place
	newinitd "${S}/vpn/vpnagentd_init" vpnagentd
	newinitd "${S}/posture/ciscod_init" ciscod
}
