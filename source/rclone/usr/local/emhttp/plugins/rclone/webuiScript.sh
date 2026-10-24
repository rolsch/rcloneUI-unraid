#!/bin/bash
if [ "${1}" == "true" ]; then
  echo "Enabling rclone WebUI, please wait..."
  sed -i "/WEBUI_ENABLED=/c\WEBUI_ENABLED=${1}" "/boot/config/plugins/rclone/settings.cfg"
  if pgrep -f "rcloneorig.*--rc-web-gui" > /dev/null 2>&1 ; then
    echo
    echo "rclone WebUI already started!"
    exit 0
  fi
elif [ "${1}" == "false" ]; then
  KILL_PID="$(pgrep -f "rcloneorig.*--rc-web-gui")"
  echo "Disabling rclone WebUI, please wait..."
  if [ -n "$KILL_PID" ]; then
    kill -SIGINT $KILL_PID
  fi
  sed -i "/WEBUI_ENABLED=/c\WEBUI_ENABLED=${1}" "/boot/config/plugins/rclone/settings.cfg"
  echo "rclone WebUI disabled"
  exit 0
else
  echo "Error: Invalid argument"
  exit 1
fi

START_PARAMS="$(cat /boot/config/plugins/rclone/settings.cfg | grep "^WEBUI_START_PARAMS=" | cut -d '=' -f2- | sed 's/\"//g')"
PORT="$(cat /boot/config/plugins/rclone/settings.cfg | grep "^WEBUI_PORT=" | cut -d '=' -f2- | sed 's/\"//g')"

echo "Starting rclone WebUI"
echo "rcloneorig --config=\"/boot/config/plugins/rclone/.rclone.conf\" rcd --rc-web-gui --rc-web-gui-no-open-browser --rc-addr=0.0.0.0:${PORT} ${START_PARAMS}" | at now -M > /dev/null 2>&1

sleep 2

if pgrep -f "rcloneorig.*--rc-web-gui" > /dev/null 2>&1 ; then
  echo
  echo "rclone WebUI started, you can now connect to the WebUI through Port: ${PORT}"
else
  echo
  echo "rclone WebUI start failed, please check your settings and your logs what went wrong."
fi
