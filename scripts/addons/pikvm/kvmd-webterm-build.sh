#!/bin/bash -e
pkgdir=$(pwd)/out

package_kvmd_webterm() {
	mkdir -p "$pkgdir/usr/bin"
	cp nanokvm-motd "$pkgdir/usr/bin/nanokvm-motd"

	mkdir -p "$pkgdir/usr/lib/systemd/system"
	cp kvmd-webterm.service "$pkgdir/usr/lib/systemd/system/kvmd-webterm.service"

	mkdir -p "$pkgdir/usr/lib/sysusers.d"
	cp sysusers.conf "$pkgdir/usr/lib/sysusers.d/kvmd-webterm.conf"

	mkdir -p "$pkgdir/usr/share/kvmd/web/extras/webterm"
	cp terminal.svg "$pkgdir/usr/share/kvmd/web/extras/webterm"

	mkdir -p "$pkgdir/usr/share/kvmd/extras/webterm"
	cp nginx.*.conf manifest.yaml "$pkgdir/usr/share/kvmd/extras/webterm"
}

package_kvmd_webterm
echo OK
