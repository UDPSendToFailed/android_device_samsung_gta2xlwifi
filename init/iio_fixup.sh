#!/vendor/bin/sh
#
# Fix IIO sysfs permissions for sensors HAL.
# The HAL (uid=system) needs write access to buffer/trigger/scan_elements.
#

for f in /sys/bus/iio/devices/iio:device*/buffer/enable \
         /sys/bus/iio/devices/iio:device*/buffer/length \
         /sys/bus/iio/devices/iio:device*/trigger/current_trigger \
         /sys/bus/iio/devices/iio:device*/sampling_frequency; do
    chown 1000:1000 "$f" 2>/dev/null
    chmod 660 "$f" 2>/dev/null
done

for f in /sys/bus/iio/devices/iio:device*/scan_elements/*_en; do
    chown 1000:1000 "$f" 2>/dev/null
    chmod 660 "$f" 2>/dev/null
done
