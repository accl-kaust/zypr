#!/usr/bin/env bash
if [ $# != 2 ]; then
	echo "Usage:       $0 [tftp_dir] [version]"
	echo
	echo "for example: $0 `pwd` 2018.2"
	exit 1;
fi

docker_context=`pwd`
tftp_dir=$1
version=$2

cd ${tftp_dir}
if [ -f "vivado-v${version}-final-installer.run" ]; then
	echo [${tftp_dir}/vivado-v${version}-final-installer.run] exists
	python3 -m http.server &
	server_pid=$!
	echo PID [${server_pid}] http.server starting...
	echo
else  
	echo make sure [vivado-v${version}-final-installer.run] exists in the [${tftp_dir}]
	echo
	kill ${server_pid}
	exit 1
fi

cd ${docker_context}
if [ -f "Dockerfile" ]; then
	echo Dockerfile exists in [${docker_context}]
	echo
	timestamp=`date +"%Y-%m-%d-%H-%M-%S"`
	docker build -t zycap/vivado:$timestamp . 
	docker tag zycap/vivado:$timestamp zycap/vivado:latest
else
	echo make sure Dockerfile exists in [${docker_context}]
	echo
fi

kill ${server_pid}

echo "-------------------------------------------------------------------"
echo "                   finished building vivado                        "
echo "-------------------------------------------------------------------"
docker images | grep vivado