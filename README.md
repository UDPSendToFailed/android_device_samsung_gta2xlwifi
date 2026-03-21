# Android device tree for Samsung Galaxy Tab A 10.5 WiFi (gta2xlwifi) running mainline kernel

## Kernel repository

|    Target   |               Path               |                    URL                    |         Branch         |
|-------------|----------------------------------|-------------------------------------------|------------------------|
| gta2xlwifi  | kernel/mainline/msm8953-mainline | https://github.com/msm8953-mainline/linux | barni2000/6.19/develop |

## Kernel edits

- After applying kernel patches specified below, on `mm/Kconfig`, on config option `MEMFD_ASHMEM_SHIM`, remove the dependency on `ASHMEM_C`.

## Kernel patches

| Commit name | Purpose | Source |
|-------------|---------|--------|
| `ANDROID: usb: gadget: configfs: Add Uevent to notify userspace` | Fixes USB in normal mode | https://android.googlesource.com/kernel/common-patches/+/refs/heads/main-kernel/android-mainline/ANDROID-usb-gadget-configfs-Add-Uevent-to-notify-userspace.patch |
| `ANDROID: mm/memfd-ashmem-shim: Introduce shim layer` | Fixes media codec | https://android.googlesource.com/kernel/common-patches/+/refs/heads/main-kernel/android-mainline/ANDROID-mm-memfd-ashmem-shim-Introduce-shim-layer.patch |
| `ANDROID: mm: shmem: Use memfd-ashmem-shim ioctl handler"` | Fixes media codec | https://android.googlesource.com/kernel/common-patches/+/refs/heads/main-kernel/android-mainline/ANDROID-mm-shmem-Use-memfd-ashmem-shim-ioctl-handler.patch |

## Notes for `gta2xlwifi` target

- Samsung Galaxy Tab A 10.5 WiFi (SM-T590) uses SDM450, which is based on the MSM8953 platform.
- Uses LK2ND bootloader for mainline kernel booting.
