SHELL := /bin/bash

# Dependency Versions
VERSION?=3.5.16
RELEASEVER?=1

# Bash data
SCRIPTPATH=$(shell pwd -P)
CORES=$(shell grep -c ^processor /proc/cpuinfo)
RELEASE=$(shell lsb_release --codename | cut -f2)

major=$(shell echo $(VERSION) | cut -d. -f1)
minor=$(shell echo $(VERSION) | cut -d. -f2)
micro=$(shell echo $(VERSION) | cut -d. -f3)

build: clean gnutls

clean:
	rm -rf /tmp/gnutls-$(VERSION).tar.xz
	rm -rf /tmp/gnutls-$(VERSION)

gnutls:
	cd /tmp && \
	wget ftp://ftp.gnutls.org/gcrypt/gnutls/v$(major).$(minor)/gnutls-$(VERSION).tar.xz && \
	tar -xf gnutls-$(VERSION).tar.xz && \
	cd gnutls-$(VERSION) && \
	./configure \
		--prefix=/usr \
		--without-p11-kit \
		--with-included-libtasn1 \
		--with-included-unistring \
		--with-default-trust-store-file=/etc/ssl/ca-bundle.crt \
		--mandir=/usr/share/man/gnutls/$(VERSION) \
		--infodir=/usr/share/info/gnutls/$(VERSION) \
	    --docdir=/usr/share/doc/gnutls/$(VERSION) && \
	make -j$(CORES) && \
	make install

fpm_debian:
	echo "Packaging gnutls3 for Debian"

	cd /tmp/gnutls-$(VERSION) && make install DESTDIR=/tmp/gnutls3-$(VERSION)-install

	fpm -s dir \
		-t deb \
		-n gnutls3 \
		-v $(VERSION)-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2) \
		-C /tmp/gnutls3-$(VERSION)-install \
		-p gnutls3_$(VERSION)-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2)_$(shell arch).deb \
		-m "charlesportwoodii@erianna.com" \
		--license "GPLv3" \
		--url https://github.com/charlesportwoodii/librotli-build \
		--description "gnutls3" \
		--depends "libunbound2 > 0" \
		--conflicts "libgnutls-dev > 0" \
		--deb-systemd-restart-after-upgrade

fpm_rpm:
	echo "Packaging gnutls3 for RPM"

	cd /tmp/gnutls-$(VERSION) && make install DESTDIR=/tmp/gnutls3-$(VERSION)-install

	fpm -s dir \
		-t rpm \
		-n gnutls3 \
		-v $(VERSION)_$(RELEASEVER) \
		-C /tmp/gnutls3-install \
		-p gnutls3_$(VERSION)-$(RELEASEVER)_$(shell arch).rpm \
		-m "charlesportwoodii@erianna.com" \
		--license "GPLv3" \
		--url https://github.com/charlesportwoodii/gnutls3-build \
		--description "gnutls3" \
		--vendor "Charles R. Portwood II" \
		--rpm-digest sha384 \
		--rpm-compression gzip
