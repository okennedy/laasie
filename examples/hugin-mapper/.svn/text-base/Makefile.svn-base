SUPP_FILES = \
	index.php\
	ICON/ICON.php\
	ICON/setup.php

MAJOR_VERSION = b1
BUILD_VERSION = $(shell svn info |grep ^Revision: | sed 's/Revision: //')

DEBUG_PATH   = Build/Debug/Hugin
RELEASE_PATH = Build/Release/Hugin

DEBUG_SUPP_FILES = $(SUPP_FILES:%=$(DEBUG_PATH)/%)
RELEASE_SUPP_FILES = $(SUPP_FILES:%=$(RELEASE_PATH)/%)

debug: jake_debug $(DEBUG_PATH)/ICON $(DEBUG_SUPP_FILES)

release: jake_release $(RELEASE_PATH)/ICON $(RELEASE_SUPP_FILES)

dist: hugin.tgz
	mv hugin.tgz hugin_$(MAJOR_VERSION)_$(BUILD_VERSION).tgz

nibs: $(NIB_FILES)

Resources/%.cib : Resources.base/%.xib
	nib2cib $<
	mv Resources.base/$*.cib $@

hugin.tgz: release
	cp -r $(RELEASE_PATH) hugin
	cp NOTICE README hugin
	tar -zcvvf hugin.tgz hugin
	rm -r hugin

jake_debug: Frameworks
	jake debug
	
jake_release: Frameworks
	jake release

Frameworks:
	capp gen . -f

$(DEBUG_PATH)/ICON $(RELEASE_PATH)/ICON : % :
	mkdir $@

$(DEBUG_SUPP_FILES): $(DEBUG_PATH)/% : %
	cp $< $@

$(RELEASE_SUPP_FILES): $(RELEASE_PATH)/% : %
	cp $< $@

clean: 
	rm -rf Build hugin.tgs

distclean: clean
	rm -rf Frameworks

.PHONY: debug release jake_debug jake_release clean distclean dist nibs all