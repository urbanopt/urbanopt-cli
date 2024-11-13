#!/bin/bash

# Installs Python via Miniconda for Linux and MacOS.

function log_message
{
	# Severity is first argument.
	echo ${@:2}
	echo "$(date) - $1 - ${@:2}" >> $LOG_FILE
}

function debug
{
	if [ $VERBOSE -eq 1 ]; then
		log_message "DEBUG" $@
	fi
}

function info
{
	log_message "INFO" $@
}

function error
{
	log_message "ERROR" $@
}

function run_command
{
	debug "run command [$@]"
	$@ > /dev/null
	ret=$?
	if [ $ret != 0 ]; then
		error "command=[$@] failed return_code=$ret"
		exit $ret
	fi
}

function show_help
{
	echo "Usage:  $0 MINICONDA_VERSION PYTHON_VERSION PATH"
}

### MAIN ###

LOG_FILE="/tmp/install_python.log"
> $LOG_FILE

if [ -z $VERBOSE ]; then
	VERBOSE=0
fi

# Developers can set this to 0 to prevent repeated downloads.
# Normal operation is download the file every run and delete it afterwards.
if [ -z $FORCE_DOWNLOAD ]; then
	FORCE_DOWNLOAD=1
fi

if [ -z $3 ]; then
	show_help
	exit 1
fi

CONDA_VERSION=$1
PYTHON_FULL_VERSION=$2
IFS="." read -ra VER_ARRAY <<< "$PYTHON_FULL_VERSION"
if [ ${#VER_ARRAY[@]} -lt 2 ] ; then
	error "invalid python version: format x.y.z"
	exit 1
fi
PYTHON_MAJOR_MINOR="${VER_ARRAY[0]}${VER_ARRAY[1]}"
INSTALL_BASE=$3

if [ ! -d $INSTALL_BASE ]; then
	error "path $INSTALL_BASE does not exist"
	exit 1
fi

architecture=$(uname -m)

echo "$architecture"

# Handle multiple chip architectures (ARM & x86) as well as OS types (Linux & MacOS)
if [[ $architecture == "x86"* || $architecture == "i686" || $architecture == "i386" ]]; then
	if [[ "$OSTYPE" == "linux-gnu" ]]; then
		PLATFORM=Linux-x86_64
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		PLATFORM=MacOSX-x86_64
	else
		error "unknown OS type $OSTYPE"
		exit 1
	fi
elif [[ $architecture == "arm"* || $architecture == "aarch"* ]]; then
	if [[ "$OSTYPE" == "linux-gnu" ]]; then
		PLATFORM=Linux-aarch64
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		PLATFORM=MacOSX-arm64
	else
		error "unknown OS type $OSTYPE"
		exit 1
	fi
fi

CONDA_PACKAGE_NAME=Miniconda3-py${PYTHON_MAJOR_MINOR}_${CONDA_VERSION}-${PLATFORM}.sh
CONDA_URL=https://repo.anaconda.com/miniconda/$CONDA_PACKAGE_NAME
CONDA_PACKAGE_PATH=/tmp/$CONDA_PACKAGE_NAME

INSTALL_PATH=./Miniconda-${CONDA_VERSION}
PIP=$INSTALL_PATH/bin/pip
PYTHON=$INSTALL_PATH/bin/python

debug "PYTHON_FULL_VERSION=$PYTHON_FULL_VERSION"
debug "PYTHON_MAJOR_MINOR=$PYTHON_MAJOR_MINOR"
debug "CONDA_VERSION=$CONDA_VERSION"
debug "CONDA_PACKAGE_NAME=$CONDA_PACKAGE_NAME"
debug "CONDA_URL=$CONDA_URL"
debug "CONDA_PACKAGE_PATH=$CONDA_PACKAGE_PATH"
debug "INSTALL_PATH=$INSTALL_PATH"
debug "PIP=$PIP"

if [ $FORCE_DOWNLOAD -eq 1 ] && [ -f $CONDA_PACKAGE_PATH ]; then
	run_command "rm -f $CONDA_PACKAGE_PATH"
fi

if [ ! -f $CONDA_PACKAGE_PATH ]; then
	run_command "curl $CONDA_URL -o $CONDA_PACKAGE_PATH"
	debug "Finished downloading $CONDA_PACKAGE_NAME"
fi

run_command "bash $CONDA_PACKAGE_PATH -b -p $INSTALL_PATH -u"
if [ $FORCE_DOWNLOAD -eq 1 ]; then
	run_command "rm -rf $CONDA_PACKAGE_PATH"
fi

debug "Finished installation of Python $PYTHON_FULL_VERSION"
