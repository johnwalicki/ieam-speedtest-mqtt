#!/bin/sh

export SPEEDTEST_PAUSE_SEC=10
export WIOTP_ORG=spzdfr
export WIOTP_DEVICE_TYPE=SpeedTest
export WIOTP_DEVICE_TOKEN=`echo ${HZN_EXCHANGE_USER_AUTH} | cut -d- -f2`

if [[  -z "${HZN_DEVICE_ID}" ]]; then
  export WIOTP_DEVICE_ID=SpeedTest002
else
  # use HZN_DEVICE_ID instead of WIOTP_DEVICE_ID in the Horizon Service container
  export WIOTP_DEVICE_ID=${HZN_DEVICE_ID}
fi
export WIOTP_DEVICE_ID=SpeedTest002
echo ${WIOTP_DEVICE_ID}

while true; do
  result=`./speedtest --accept-license -f json | jq -r '{downloadspeed: ( .download.bandwidth * 8 / 1000000)}'`
  echo "${result}"

echo mosquitto_pub -h "${WIOTP_ORG}.messaging.internetofthings.ibmcloud.com" -p 8883 --cafile ./messaging.pem -i "d:${WIOTP_ORG}:${WIOTP_DEVICE_TYPE}:${WIOTP_DEVICE_ID}" -u "use-token-auth" -P "${WIOTP_DEVICE_TOKEN}" -t iot-2/evt/status/fmt/json -m "${result}" -d

  mosquitto_pub -h "${WIOTP_ORG}.messaging.internetofthings.ibmcloud.com" -p 8883 --cafile ./messaging.pem -i "d:${WIOTP_ORG}:${WIOTP_DEVICE_TYPE}:${WIOTP_DEVICE_ID}" -u "use-token-auth" -P "${WIOTP_DEVICE_TOKEN}" -t iot-2/evt/status/fmt/json -m "${result}" -d

  sleep ${SPEEDTEST_PAUSE_SEC}
done
