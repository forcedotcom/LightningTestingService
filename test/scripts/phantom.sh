#!/usr/bin/env bash

# Fail immediately on non-zero exit code.
set -e
# Fail on undeclared variables.
set -u
# Debug, echo every command
#set -x

OUTPUT_DIR=$1
PHANTOM_VER=2.1.1
PHANTOM_PATH=phantomjs-$PHANTOM_VER-linux-x86_64
PHANTOM_FILE=$PHANTOM_PATH.tar.bz2
PHANTOM_URL=https://github.com/Medium/phantomjs/releases/download/v$PHANTOM_VER/$PHANTOM_FILE

if [ ! -d "$OUTPUT_DIR/$PHANTOM_PATH" ]; then
    if [ ! -f "$OUTPUT_DIR/$PHANTOM_FILE" ]; then
        echo "Downloading $PHANTOM_URL"
        curl -L -o $OUTPUT_DIR/$PHANTOM_FILE $PHANTOM_URL
    else echo "Found cached phantom release"; fi

    tar jxf $OUTPUT_DIR/$PHANTOM_FILE -C $OUTPUT_DIR
else
    echo "Using cached phantom binaries"
fi
