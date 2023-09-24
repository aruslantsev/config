# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

DESCRIPTION="A complete TeX distribution"
HOMEPAGE="http://tug.org/texlive/"

LICENSE=" GPL-1 GPL-2 LPPL-1.3 LPPL-1.3c MIT OFL public-domain TeX TeX-other-free "

SLOT="0"
KEYWORDS="amd64"
IUSE="+fontutils +texi2html imagemagick"

DEPEND=""
RDEPEND="
	virtual/perl-Getopt-Long
	dev-perl/File-HomeDir
	dev-perl/Log-Dispatch
	dev-perl/Unicode-LineBreak
	dev-perl/YAML-Tiny
	app-text/psutils
	app-text/ghostscript-gpl
	sys-apps/texinfo
	app-text/ps2eps
	app-text/libpaper
	media-gfx/sam2p
	media-libs/gd
	media-libs/freeglut
	media-libs/libglvnd
	virtual/libcrypt
	texi2html? ( app-text/texi2html )
	fontutils? (
		media-libs/fontconfig
		media-libs/freetype:2
		media-libs/harfbuzz[graphite,icu]
		app-text/t1utils
	)
	imagemagick? ( media-gfx/imagemagick )
"

BDEPEND=""

SRC_URI="
	http://46.101.168.148/texlive/${PN}-${PV}.tar.xz
"


S="${WORKDIR}"

src_unpack() {
	unpack ${A}
}


src_install() {
	dodir /opt/texlive
	mv ${S}/* ${D}/opt/texlive/ || die "Install failed"
	dodir /etc/env.d
	cp -R ${FILESDIR}/99texlive ${D}/etc/env.d || die "Install failed"
}

pkg_postinst() {
	einfo "See /opt/texlive/2023/index.html for links to documentation."
	einfo "app-text/lcdf-typetools and dev-tex/pgf are not installed because of hardcoded dependencies on kpathsea and texlive"

}
