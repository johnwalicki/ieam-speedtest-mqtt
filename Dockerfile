FROM alpine:3.13 as build
LABEL stage=builder
RUN apk --no-cache add curl
RUN curl -L https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-x86_64-linux.tgz >speedtest.tgz
RUN tar -xzvf speedtest.tgz
COPY speedtest2wiotp.sh /
COPY messaging.pem /

FROM alpine:3.13
RUN apk --no-cache add jq mosquitto-clients

LABEL vendor="IBM"
LABEL summary="Send Speedtest Download speed to Watson IoT Platform via MQTT"
LABEL description="A container which runs the Speedtest service and sends the output to Watson IoT Platform via MQTT"

WORKDIR /
COPY --from=build . /

ENTRYPOINT ["sh", "speedtest2wiotp.sh"]
