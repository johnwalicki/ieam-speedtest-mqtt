# Speedtest service that sends the output to Watson IoT Platform Quickstart via MQTT

DOCKERHUB_ID:=walicki
SERVICE_NAME:="speedtest-mqtt-example-instructor"
SERVICE_VERSION:="2.0.0"
PATTERN_NAME:="pattern-speedtest-mqtt-example-instructor"
ARCH:="amd64"

# Leave blank for open DockerHub containers
# CONTAINER_CREDS:=-r "registry.wherever.com:myid:mypw"
CONTAINER_CREDS:=

default: build run

build:
	docker build -t $(DOCKERHUB_ID)/$(SERVICE_NAME):$(SERVICE_VERSION) .
	docker image prune --filter label=stage=builder --force
	
dev: stop build
	docker run -it --name ${SERVICE_NAME} \
          $(DOCKERHUB_ID)/$(SERVICE_NAME):$(SERVICE_VERSION) /bin/bash

run: stop
	docker run -d \
          --name ${SERVICE_NAME} \
          --restart unless-stopped \
          $(DOCKERHUB_ID)/$(SERVICE_NAME):$(SERVICE_VERSION)

test:
	xdg-open https://quickstart.internetofthings.ibmcloud.com/

push:
	docker push $(DOCKERHUB_ID)/$(SERVICE_NAME):$(SERVICE_VERSION)

publish-service:
	@ARCH=$(ARCH) \
        SERVICE_NAME="$(SERVICE_NAME)" \
        SERVICE_VERSION="$(SERVICE_VERSION)"\
        SERVICE_CONTAINER="$(DOCKERHUB_ID)/$(SERVICE_NAME):$(SERVICE_VERSION)" \
        hzn exchange service publish -O $(CONTAINER_CREDS) -f service.json --pull-image

publish-pattern:
	@ARCH=$(ARCH) \
        SERVICE_NAME="$(SERVICE_NAME)" \
        SERVICE_VERSION="$(SERVICE_VERSION)"\
        PATTERN_NAME="$(PATTERN_NAME)" \
	hzn exchange pattern publish -f pattern.json

register-pattern:
	hzn register --pattern "${HZN_ORG_ID}/$(PATTERN_NAME)"

stop:
	@docker rm -f ${SERVICE_NAME} >/dev/null 2>&1 || :

clean:
	@docker rmi -f $(DOCKERHUB_ID)/$(SERVICE_NAME):$(SERVICE_VERSION) >/dev/null 2>&1 || :

.PHONY: build dev run push publish-service publish-pattern test stop clean
