# Copyright 2020-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KV_LOCALVERSION="-amd64"
KPV=${PV}${KV_LOCALVERSION}
S=${WORKDIR}

DESCRIPTION="Pre-built Debian Linux kernel"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"
SRC_URI="
	https://ftp.debian.org/debian/pool/main/l/linux-signed-amd64/linux-image-6.4.0-4-amd64_6.4.13-1_amd64.deb
"

LICENSE="GPL-2"
KEYWORDS="amd64"
SLOT="${PV}"

DEPEND=""
RDEPEND=""
BDEPEND="
	app-arch/tar
	app-arch/zstd
	initramfs? ( sys-kernel/dracut )
"

IUSE="+initramfs"

src_unpack () {
	unpack ${A}
	tar xpf data.tar.xz || die "Unpack failed"
}

src_install() {
	cd ${S}
	cp -R boot ${D} || die "Install failed"
	cp -R lib ${D} || die "Install failed"
	# cp -R usr ${D} || die "Install failed" # Nothing valuable
}

pkg_postinst() {
	MY_KPV=$(sed -e "s/_p/-/" <<< $KPV)
	einfo "Running depmod."
	if [ -x "$(command -v depmod)" ]
	then
		depmod -b ${ROOT}/ ${MY_KPV} || die "depmod failed"
	else
		ewarn "depmod is missing"
	fi
	if use initramfs
	then
		einfo "Creating initramfs at ${ROOT}/boot/initramfs-${MY_KPV}.img"
		dracut --force --kver ${MY_KPV} ${ROOT}/boot/initramfs-${MY_KPV}.img || die "dracut failed"
	else
		einfo "This package does not provide initramfs."
		einfo "You may need to build it yourself or to install sys-kernel/dracut"
	fi
}

pkg_postrm() {
	MY_KPV=$(sed -e "s/_p/-/" <<< $KPV)
	if use initramfs
	then
		if [ -f ${ROOT}/boot/initramfs-${MY_KPV}.img ]
		then
			einfo "Removing old initramfs"
			rm ${ROOT}/boot/initramfs-${MY_KPV}.img || ewarn "Initramfs remove failed"
		else
			einfo "Initramfs was not found"
		fi
	fi
}
