# 
# Makefile for subutai-ovs
#

all:
	@echo "Nothing to build - for install only"

install:
	@install -D --mode 755 src/subutai-ovs $(DESTDIR)/usr/sbin/subutai-ovs

.PHONY: all

# vim: ts=4 et nowrap autoindent