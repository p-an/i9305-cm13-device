
include $(CLEAR_VARS)
LOCAL_MODULE := cm12chroot
LOCAL_ADDITIONAL_DEPENDENCIES := $(TARGET_OUT)/cm12chroot

$(TARGET_OUT)/cm12chroot:
	mkdir -p $(TARGET_OUT)/cm12chroot
	tar xzf device/samsung/i9305/cm12chroot/cm12chroot.tgz -C $(TARGET_OUT)

include $(BUILD_PHONY_PACKAGE)
