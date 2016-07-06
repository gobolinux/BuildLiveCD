
VERSION =
PROGRAM = BuildLiveCD
PREFIX = /Programs/$(PROGRAM)/$(VERSION)
PACKAGE_DIR = $(HOME)
PACKAGE_ROOT = $(PACKAGE_DIR)/$(PROGRAM)
PACKAGE_BASE = $(PACKAGE_ROOT)/$(VERSION)
PACKAGE_FILE = $(PACKAGE_DIR)/$(PROGRAM)--$(VERSION)--$(shell uname -m).tar.bz2
TAG=`echo $(PROGRAM)_$(VERSION) | tr "[:lower:]" "[:upper:]" | sed  's,\.,_,g'`

all: version_check

snapshot: VERSION = `date +%Y%m%d`-snapshot
snapshot: dist

version_check:
	@[ "$(VERSION)" = "" ] && { echo -e "Error: run make with VERSION=<version-number>.\n"; exit 1 ;} || exit 0

cleanup:
	rm -rf Resources/FileHash*
	find * -path "*~" -or -path "*/.\#*" | xargs rm -f

verify:
	! { git pull 2>&1 | grep "^[\?]" | grep -v "Resources/SettingsBackup" ;}

dist: version_check cleanup verify all
	rm -rf $(PACKAGE_ROOT)
	mkdir -p $(PACKAGE_BASE)
	SignProgram $(PROGRAM)
	cat Resources/FileHash
	ListProgramFiles $(PROGRAM) | cpio -p $(PACKAGE_BASE)
	cd $(PACKAGE_DIR); tar cvp $(PROGRAM) | bzip2 > $(PACKAGE_FILE)
	rm -rf $(PACKAGE_ROOT)
	@echo; echo "Package at $(PACKAGE_FILE)"
	@echo; echo "Now run 'git tag $(TAG)' (please test)"; echo
	! { git pull  2>&1 | grep "^M" ;}

install: version_check
	mkdir -p $(PREFIX)
	cp -R * $(PREFIX)
