
include $(CLEAR_VARS)
LOCAL_MODULE := rilchroot
LOCAL_ADDITIONAL_DEPENDENCIES := $(TARGET_OUT)/rilchroot

$(TARGET_OUT)/rilchroot: $(TARGET_OUT)/cm12chroot $(TARGET_OUT)/vrtchroot $(TARGET_OUT)/xbin/select_ril.sh
	ln -sf cm12chroot $(TARGET_OUT)/rilchroot

$(TARGET_OUT)/cm12chroot:
	tar xzf device/samsung/i9305/rilchroot/cm12chroot.tgz -C $(TARGET_OUT)

$(TARGET_OUT)/vrtchroot:
	tar xzf device/samsung/i9305/rilchroot/vrtchroot.tgz -C $(TARGET_OUT)

$(TARGET_OUT)/xbin/select_ril.sh:
	cp device/samsung/i9305/rilchroot/select_ril.sh $(TARGET_OUT)/xbin/select_ril.sh

include $(BUILD_PHONY_PACKAGE)
