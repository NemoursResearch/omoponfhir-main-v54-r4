#!/bin/bash

set -x

echo Stopping any existing containers...
systemctl --user stop container-container-omoponfhir.service
podman container stop container-omoponfhir
podman container rm container-omoponfhir

sleep 1

echo Creating new container...
set -e
podman create \
	--name=container-omoponfhir \
	--label "io.containers.autoupdate=local" \
	-v $(pwd)/container/var/lib/tomcat/webapps/:/usr/local/tomcat/webapps/ \
	-v $(pwd)/container/etc/tomcat/conf.d/setenv.sh:/usr/local/tomcat/bin/setenv.sh \
	-p 127.0.0.1:8080:8080 \
	-t localhost/omoponfhir

echo Creating and restarting in systemd...
pushd $HOME/.config/systemd/user/
podman generate systemd --new --files --name container-omoponfhir
popd
systemctl --user daemon-reload
systemctl --user restart container-container-omoponfhir.service
