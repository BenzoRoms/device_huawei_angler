# Release name
PRODUCT_RELEASE_NAME := Nexus6P

# Inherit device configuration
$(call inherit-product, device/huawei/angler/aosp_angler.mk)

# Inherit some common stuff.
$(call inherit-product, vendor/benzo/config/common.mk)
$(call inherit-product, vendor/benzo/config/common_full_phone.mk)

# CM Overlay
DEVICE_PACKAGE_OVERLAYS += device/huawei/angler/overlay-cm

## Device identifier. This must come after all inclusions
PRODUCT_DEVICE := angler
PRODUCT_NAME := benzo_angler
PRODUCT_BRAND := google
PRODUCT_MODEL := Nexus 6P
PRODUCT_MANUFACTURER := Huawei
TARGET_VENDOR := huawei

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=angler \
    PRIVATE_BUILD_DESC="angler-user 6.0.1 MTC20F 3031278 release-keys" \
    BUILD_FINGERPRINT="google/angler/angler:6.0.1/MTC20F/3031278:user/release-keys"

# Copy device specific prebuilt files.
PRODUCT_COPY_FILES += \
    vendor/benzo/prebuilt/common/bootanimations/bootanimation.zip:system/media/bootanimation.zip

