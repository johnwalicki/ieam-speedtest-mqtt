FROM alpine:3.13 as build
RUN apk --no-cache add curl
RUN curl -L https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-x86_64-linux.tgz >speedtest.tgz
RUN tar -xzvf speedtest.tgz

FROM alpine:3.13
RUN apk --no-cache add jq mosquitto-clients

LABEL vendor="IBM"
LABEL summary="Send Speedtest Download speed to Watson IoT Platform Quickstart via MQTT"
LABEL description="A container which runs the Speedtest service and sends the output to Watson IoT Platform Quickstart via MQTT"

WORKDIR /
COPY --from=build speedtest /usr/bin/
COPY speedtest2wiotpq.sh /

ENTRYPOINT ["sh", "speedtest2wiotpq.sh"]
