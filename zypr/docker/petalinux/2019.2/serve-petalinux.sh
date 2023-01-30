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
if [ -f "petalinux-v${version}-final-installer.run" ]; then
	echo [${tftp_dir}/petalinux-v${version}-final-installer.run] exists
	python3 -m http.server &
	server_pid=$!
	echo PID [${server_pid}] http.server starting...
	echo
else  
	echo make sure [petalinux-v${version}-final-installer.run] exists in the [${tftp_dir}]
	echo
	kill ${server_pid}
	exit 1
fi