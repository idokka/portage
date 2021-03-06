# Copyright (C) 2013-2014 Jonathan Vasquez <fearedbliss@funtoo.org>
# Copyright (C) 2014 Sandy McArthur <Sandy@McArthur.org>
# Copyright (C) 2015 Scott Alfter <scott@alfter.us>
# Copyright (C) 2016 Oleksii Myronenko <idokka@gmail.com>
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit eutils user
NAME="rslsync"
DESCRIPTION="Magic folder style file syncing powered by Resilio."
HOMEPAGE="https://www.resilio.com/"
SRC_URI="
	amd64?	( https://download-cdn.resilio.com/${PV}/linux-x64/resilio-sync_x64.tar.gz -> ${NAME}_x64-${PV}.tar.gz )
	x86?	( https://download-cdn.resilio.com/${PV}/linux-i386/resilio-sync_i386.tar.gz -> ${NAME}_i386-${PV}.tar.gz )
	arm?	( https://download-cdn.resilio.com/${PV}/linux-arm/resilio-sync_arm.tar.gz -> ${NAME}_arm-${PV}.tar.gz )"

RESTRICT="mirror strip"
LICENSE="Resilio no-source-code"
DOCS=( LICENSE.TXT )
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

QA_PREBUILT="opt/${NAME}/${NAME}"

S="${WORKDIR}"

pkg_setup() {
	enewgroup ${NAME}
	enewuser ${NAME} -1 -1 /opt/${NAME} ${NAME}
}

src_install() {
	einfo dodir "/opt/${NAME}"
	dodir "/opt/${NAME}"
	exeinto "/opt/${NAME}"
	doexe ${NAME}
	insinto "/opt/${NAME}"
	doins LICENSE.TXT

	einfo dodir "/etc/init.d"
	dodir "/etc/init.d"
	insinto "/etc/init.d"
	doins "${FILESDIR}/init.d/${NAME}"
	fperms 755 /etc/init.d/${NAME}

	einfo dodir "/etc/conf.d"
	dodir "/etc/conf.d"
	insinto "/etc/conf.d"
	doins "${FILESDIR}/conf.d/${NAME}"

	einfo dodir "/etc/${NAME}"
	dodir "/etc/${NAME}"
	"${D}/opt/${NAME}/${NAME}" --dump-sample-config > "${D}/etc/${NAME}/config"
	sed -i 's|// "pid_file"|   "pid_file"|' "${D}/etc/${NAME}/config"
	fowners ${NAME} "/etc/${NAME}/config"
	fperms 460 "/etc/${NAME}/config"
}

pkg_preinst() {
	# Customize for local machine
	# Set device name to `hostname`
	sed -i "s/My Sync Device/$(hostname) Gentoo Linux/"  "${D}/etc/${NAME}/config"
	# Update defaults to the ${NAME}'s home dir
	sed -i "s|/home/user|$(egethome ${NAME})|"  "${D}/etc/${NAME}/config"
}

pkg_postinst() {
	elog "Init scripts launch ${NAME} daemon as ${NAME}:${NAME} "
	elog "Please review/tweak /etc/${NAME}/config for default configuration."
	elog "Default web-gui URL is http://localhost:8888/ ."
}
