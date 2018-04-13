#!/bin/sh

# Source your custom motion configurations
source /system/sdcard/config/motion.conf
source /system/sdcard/scripts/common_functions.sh

# Turn on the amber led
if [ "$motion_trigger_led" = true ] ; then
	yellow_led on
fi

# Save a snapshot
if [ "$save_snapshot" = true ] ; then
	save_dir=/system/sdcard/motion/stills
	filename=`date +%d-%m-%Y_%H.%M.%S`.jpg
	if [ ! -d "$save_dir" ]; then
		mkdir -p $save_dir
	fi
	/system/sdcard/bin/getimage > $save_dir/$filename &
fi

# Publish a mqtt message
if [ "$publish_mqtt_message" = true ] ; then
	source /system/sdcard/config/mqtt.conf
	/system/sdcard/bin/mosquitto_pub.bin -h "$HOST" -u "$USER" -P "$PASS" -t "${TOPIC}"/motion ${MOSQUITTOOPTS} ${MOSQUITTOPUBOPTS} -m "ON"
	/system/sdcard/bin/mosquitto_pub.bin -h "$HOST" -u "$USER" -P "$PASS" -t "${TOPIC}"/motion_snapshots ${MOSQUITTOOPTS} ${MOSQUITTOPUBOPTS} -f $save_dir/$filename

fi

# Send emails ...
if [ "$sendemail" = true ] ; then
    /system/sdcard/scripts/sendPictureMail.sh&
fi