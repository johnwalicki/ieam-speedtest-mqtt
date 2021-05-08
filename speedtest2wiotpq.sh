#!/bin/sh

export SPEEDTEST_PAUSE_SEC=10
export WIOTP_ORG=quickstart
export WIOTP_DEVICE_TYPE=anystring
export WIOTP_DEVICE_TOKEN=anystring

if [[  -z "${HZN_DEVICE_ID}" ]]; then
  export WIOTP_DEVICE_ID=speedtest
else
  # use HZN_DEVICE_ID instead of WIOTP_DEVICE_ID in the Horizon Service container
  export WIOTP_DEVICE_ID=${HZN_DEVICE_ID}
fi
echo ${WIOTP_DEVICE_ID}

while true; do
  result=`speedtest --accept-license -f json | jq -r '{downloadspeed: ( .download.bandwidth * 8 / 1000000)}'`
  echo "${result}"

  mosquitto_pub -h "${WIOTP_ORG}.messaging.internetofthings.ibmcloud.com" -p 1883 -i "d:${WIOTP_ORG}:${WIOTP_DEVICE_TYPE}:${WIOTP_DEVICE_ID}" -u "use-token-auth" -P "${WIOTP_DEVICE_TOKEN}" -t iot-2/evt/status/fmt/json -m "${result}" -d

  sleep ${SPEEDTEST_PAUSE_SEC}
done
