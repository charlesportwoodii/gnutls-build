SHELL := /bin/bash

# Dependency Versions
VERSION?=3.4.9
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
		--with-default-trust-store-file=/etc/ssl/ca-bundle.crt \
		--mandir=/usr/share/man/gnutls-$(VERSION) \
		--infodir=/usr/share/info/gnutls-$(VERSION) \
	    --docdir=/usr/share/doc/gnutls-$(VERSION) && \
	make -j$(CORES) && \
	make install

package:
	cp $(SCRIPTPATH)/*-pak  /tmp/gnutls-$(VERSION)

	cd /tmp/gnutls-$(VERSION) && \
	checkinstall \
	    -D \
	    --fstrans \
	    -pkgrelease "$(RELEASEVER)"-"$(RELEASE)" \
	    -pkgrelease "$(RELEASEVER)"~"$(RELEASE)" \
	    -pkgname "gnutls3" \
	    -pkglicense GPLv3 \
	    -pkggroup GPG \
	    -maintainer charlesportwoodii@ethreal.net \
	    -provides "gnutls3" \
	    -requires "libunbound2" \
	    -conflicts "libgnutls-dev" \
	    -pakdir /tmp \
	    -y