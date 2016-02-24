#!/usr/bin/env bash
set -e
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


for d in `find "$BASE_DIR/apps/" -maxdepth 1 -mindepth 1 -type d`
do
	echo $d
	cp -frv --symbolic-link $d/. ~/
done
