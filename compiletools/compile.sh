#!/bin/bash

echo "SOURCE_HOME=$SOURCE_HOME, GIT_LINK=$GIT_LINK, FMOD_LINK=$FMOD_LINK"

if [ -z "$SOURCE_HOME" -o -z "$GIT_LINK" -o -z "$FMOD_LINK" ]; then
	echo "One or more variables not defined! Following variables needed to be defined: SOURCE_HOME, GIT_LINK, FMOD_LINK"
	exit 2
fi

if [ ! -e "$SOURCE_HOME/CMakeLists.txt" ]; then
	echo "No source code found in directory. Will clone it from repo"
	git clone $GIT_LINK $SOURCE_HOME
	if [ ! $? -eq "0" ]; then
		echo "failed to clone!"
		exit 3
	fi
fi

echo "Success while cloning! will proceed..."
echo "changing dir to $SOURCE_HOME..."
pushd $SOURCE_HOME # ------------ BEGIN

echo "updating repo..."
git config --local --add remote.origin.fetch +refs/tags/*:refs/tags/*
git pull
echo "creating build dir..."
mkdir -p $SOURCE_HOME/build
FMOD_INSTALL_STATUS=666
echo "Installing FMOD..."
if [[ $FMOD_LINK == "http"* ]]; then
	echo "Downloading from remote..."
	wget -nc -O - $FMOD_LINK | tar -xzf - -C .
	FMOD_INSTALL_STATUS=$?
else
	echo "Coping from local source..."
	if [ ! -f "$FMOD_LINK" ]; then
		echo "failed to get specified FMOD! will try to obtain static version..."
		tar -xzf /home/dmwm/Docker-projects/testrepo/fmodapi42636linux.tar.gz -C .
		FMOD_INSTALL_STATUS=$?
	else
		tar -xzf $FMOD_LINK -C .
		FMOD_INSTALL_STATUS=$?
	fi
fi

if [ $FMOD_INSTALL_STATUS -eq 0 ]; then
	echo "FMOD installed! proceed..."
	pushd $SOURCE_HOME/build
	echo "executing cmake 1..."
	cmake .. $1

	echo "Compiling..."
	
	c="$(lscpu -p | grep -v '#' | sort -u -t , -k 2,4 | wc -l)" ; [ "$c" = 0 ] && c=1
	echo "Using $c cores to compile..."
	rm -f output_sdl/liboutput_sdl.so && \
	if [ -d ../fmodapi44464linux ]; then 
		f="-DFMOD_LIBRARY=../fmodapi44464linux/api/lib/libfmodex${a}-4.44.64.so -DFMOD_INCLUDE_DIR=../fmodapi44464linux/api/inc"
	else 
		f='-UFMOD_LIBRARY -UFMOD_INCLUDE_DIR'
	fi
	echo "flags = $f"
	echo "executing cmake 2..."
	cmake .. -DCMAKE_BUILD_TYPE=Release $f
	CMAKE_STATUS=$?
	if [ ! $CMAKE_STATUS -eq 0 ]; then
		echo "Failed to cmake project [rc=$CMAKE_STATUS]... Exiting"
		exit 5
	else
		echo "making..."
		make -j$c
		MAKE_STATUS=$?
		if [ $MAKE_STATUS -eq 0 ]; then
			echo "Hooray!! your binary in ./gzdoom"
		else
			echo "Failed to make it to the binary [rc=$MAKE_STATUS]!"
			exit $MAKE_STATUS
		fi
		
	fi
	popd 
fi


if [ ! $? -eq 0 ]; then
	echo "Something gone wrong [rc=$?]..."
	exit 4;
fi


popd # -------------- END
