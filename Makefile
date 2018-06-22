# 
# Makefile for subutai-ovs
#

all:
	@echo "Nothing to build - for install only"

install:
	@install -D --mode 755 src/subutai-dnsmasq $(DESTDIR)/usr/sbin/subutai-dnsmasq
	@install -D --mode 755 src/subutai-ovs $(DESTDIR)/usr/sbin/subutai-ovs
	@install -D --mode 755 src/subutai-create-interface $(DESTDIR)/usr/sbin/subutai-create-interface

.PHONY: all

# vim: ts=4 et nowrap autoindent
