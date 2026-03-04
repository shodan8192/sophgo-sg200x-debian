#!/bin/bash -e
pkgdir=$(pwd)/out

_options="WITH_V4P=1 WITH_GPIO=1 WITH_SYSTEMD=1"
if [ -e /usr/bin/python3 ]; then
	_options="$_options WITH_PYTHON=1"
	#depends+=("python>=3.14" "python<3.15")
	#makedepends+=(python-setuptools python-pip python-build python-wheel)
fi
if [ -e /usr/include/janus/plugins/plugin.h ];then
	#depends+=(janus-gateway-pikvm alsa-lib opus)
	#makedepends+=(janus-gateway-pikvm alsa-lib opus)
	_options="$_options WITH_JANUS=1"
fi

echo $_options > .options

build_ustreamer() {
	#cd "$srcdir"
	#rm -rf $pkgname-build
	#cp -r $pkgname $pkgname-build
	#cd $pkgname-build
	make $_options $MAKEFLAGS
}

package_ustreamer() {
	#cd "$srcdir/$pkgname-build"
	make $_options DESTDIR="$pkgdir" PREFIX=/usr install
}

build_ustreamer
package_ustreamer

echo OK
