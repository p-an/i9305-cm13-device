LZMA_BIN := $(shell which lzma)


$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) \
		$(recovery_ramdisk) \
		$(recovery_uncompressed_ramdisk) \
		$(recovery_kernel)
	@echo -e ${CL_CYN}"----- Compressing recovery ramdisk with lzma ------"${CL_RST}
	rm -f $(recovery_uncompressed_ramdisk).lzma
	$(LZMA_BIN) $(recovery_uncompressed_ramdisk)
	$(hide) cp $(recovery_uncompressed_ramdisk).lzma $(recovery_ramdisk)
	@echo ----- Making recovery image ------
	$(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	@echo -e ${CL_CYN}"----- Made recovery image -------- $@"${CL_RST}
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)


$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES)
	@echo -e ${CL_CYN}"----- Recompressing recovery ramdisk with lzma ------"${CL_RST}
	cat $(BUILT_RAMDISK_TARGET) | gzip -d | $(LZMA_BIN) > $(BUILT_RAMDISK_TARGET).lzma
	mv -f $(BUILT_RAMDISK_TARGET) $(BUILT_RAMDISK_TARGET).gz
	mv -f $(BUILT_RAMDISK_TARGET).lzma $(BUILT_RAMDISK_TARGET)
	$(call pretty,"Target boot image: $@")
	$(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	mv -f $(BUILT_RAMDISK_TARGET) $(BUILT_RAMDISK_TARGET).lzma
	mv -f $(BUILT_RAMDISK_TARGET).gz $(BUILT_RAMDISK_TARGET)
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_CYN}"Made boot image: $@"${CL_RST}
