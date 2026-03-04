#!/bin/bash -e
pkgdir=$(pwd)/out

build_janus_gateway() {
#	cd "janus-gateway-$pkgver"
#	cd "janus-gateway-$_commit"
	patch -p1 < ../pikvm-packages/packages/janus-gateway-pikvm/0001-js.patch
	./autogen.sh
	./configure \
		--prefix=/usr \
		--sysconfdir=/etc \
		--disable-docs \
		--disable-data-channels \
		--disable-turn-rest-api \
		--disable-all-plugins \
		--disable-all-loggers \
		--disable-all-transports \
		--enable-websockets \
		--disable-sample-event-handler \
		--disable-websockets-event-handler \
		--disable-gelf-event-handler
	make
}

package_janus_gateway() {
#	cd "janus-gateway-$pkgver"
#	cd "janus-gateway-$_commit"
	make DESTDIR="$pkgdir" install
	mkdir "$pkgdir/usr/lib/janus/loggers"
	cp html/demos/adapter.js "$pkgdir/usr/share/janus/javascript/adapter.js"
}

build_janus_gateway
package_janus_gateway

echo OK
