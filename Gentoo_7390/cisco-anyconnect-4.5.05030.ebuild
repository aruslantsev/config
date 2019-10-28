# Copyright 2019 Andrei Ruslantsev aruslantsev@ozon.ru
# Distributed under the terms of the GNU General Public License v2

EAPI=7

BASE_PACKAGENAME="bin"
BASE_AMD64_URI="https://files.ozon.ru/Linux/anyconnect-linux64-4.5.05030-predeploy-k9.tar.gz"

PYTHON_COMPAT=( python3_6 )
DEPEND="x11-libs/pangox-compat"


DESCRIPTION="Cisco anyconnect VPN client"
HOMEPAGE="https://example.com"
SRC_URI_AMD64="${BASE_AMD64_URI}"

SRC_URI="
	amd64? ( ${SRC_URI_AMD64} )
"

LICENSE="EULA"
SLOT="0"
KEYWORDS="-* ~amd64"


S="${WORKDIR}"

PYTHON_UPDATER_IGNORE="1"

QA_PREBUILT="/opt/*"

pkg_pretend() {
	:;
}

pkg_setup() {
	:;
}

src_unpack() {
	einfo "Uncompressing distfile anyconnect-linux64-4.5.05030-predeploy-k9.tar.gz"
	tar xf "${DISTDIR}/anyconnect-linux64-4.5.05030-predeploy-k9.tar.gz" > "${WORKDIR}/anyconnect-linux64-4.5.05030-predeploy-k9" || die
}

src_configure() { :; }

src_compile() {
	exec ${S}/anyconnect-linux64-4.5.05030/vpn/vpn_install.sh
	exec S{S}/anyconnect-linux64-4.5.05030/posture/posture_install.sh
}

src_install() {
	# dodir /usr
	# cp -aR "${S}"/usr/* "${ED}"/usr/
	:;
}
pkg_postinst() {
	# xdg_icon_cache_update
	# xdg_desktop_database_update
	# xdg_mimeinfo_database_update
	:;
}

pkg_postrm() {
	# xdg_icon_cache_update
	# xdg_desktop_database_update
	# xdg_mimeinfo_database_update
	:;
}
