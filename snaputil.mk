ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

STRAPPROJECTS    += snaputil
SNAPUTIL_VERSION := 10.15.1
DEB_SNAPUTIL_V   ?= $(SNAPUTIL_VERSION)

snaputil-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/Diatrus/apfs/archive/v$(SNAPUTIL_VERSION).tar.gz
	$(call EXTRACT_TAR,v$(SNAPUTIL_VERSION).tar.gz,apfs-$(SNAPUTIL_VERSION),snaputil)
	mkdir -p $(BUILD_STAGE)/snaputil/usr/bin

ifneq ($(wildcard $(BUILD_WORK)/snaputil/.build_complete),)
snaputil:
	@echo "Using previously built snaputil."
else
snaputil: snaputil-setup
	$(CC) $(ARCH) -Os -Wall -isysroot $(SYSROOT) $(PLATFORM_VERSION_MIN) -o $(BUILD_STAGE)/snaputil/usr/bin/snaputil $(BUILD_WORK)/snaputil/snapUtil.c
	touch $(BUILD_WORK)/snaputil/.build_complete
endif

snaputil-package: snaputil-stage
	# snaputil.mk Package Structure
	rm -rf $(BUILD_DIST)/snaputil
	
	# snaputil.mk Prep snaputil
	cp -a $(BUILD_STAGE)/snaputil $(BUILD_DIST)

	# snaputil.mk Sign
	$(call SIGN,snaputil,snaputil.xml)
	
	# snaputil.mk Make .debs
	$(call PACK,snaputil,DEB_SNAPUTIL_V)
	
	# snaputil.mk Build cleanup
	rm -rf $(BUILD_DIST)/snaputil

.PHONY: snaputil snaputil-package
