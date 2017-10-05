#! bash

#
# This script will automatically build Cairo, HarfBuzz, FreeType and their dependent libraries.
# It requires some scripts as follows:
#
#	build-libpng-zlib.sh
#	build-pixman.sh
#	build-freetype.sh
#	build-cairo.sh
#	build-harfbuzz.sh
#
# These scripts are written by Takeshi WATANABE (Fukuneko Inc.)
# 	https://github.com/gTakes/cairo-ft-hb-auto-build
#
# They was created based on cairo-windows from GitHub -- Jeff Preshing, thank him a lot!
# 	https://github.com/preshing/cairo-windows
# 
# 
# Running this script should be on MSYS2 environment through "VS2015 x86 Native Tools Command Prompt".
# 

set -e
trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG
trap 'echo FAILED COMMAND: $previous_command' EXIT

# Versions used
USE_FREETYPE=1
CAIRO_VERSION=cairo-1.15.6
PIXMAN_VERSION=pixman-0.34.0
LIBPNG_VERSION=libpng-1.6.34
ZLIB_VERSION=zlib-1.2.11
FREETYPE_VERSION=freetype-2.8
HARFBUZZ_VERSION=harfbuzz-1.5.1

# Set variables according to command line argument
if [ ${1:-x86} = x64 ]; then
    MSVC_PLATFORM_NAME=x64
    OUTPUT_PLATFORM_NAME=x64
else
    MSVC_PLATFORM_NAME=Win32
    OUTPUT_PLATFORM_NAME=x86
fi
if [ ${2:-release} = debug ]; then
	MSVC_CONFIG_NAME=debug
	MSVC_CONFIG_CNAME=Debug
	DEBUG_ADD_STR=d
else
	MSVC_CONFIG_NAME=release
	MSVC_CONFIG_CNAME=Release
fi

# Make sure the MSVC linker appears first in the path
MSVC_LINK_PATH=`whereis link | sed "s| /usr/bin/link.exe||" | sed "s|.*\(/c.*\)link.exe.*|\1|"`
export PATH="$MSVC_LINK_PATH:$PATH"

# Run each script
source build-libpng-zlib.sh
source build-pixman.sh
source build-freetype.sh
source build-cairo.sh
source build-harfbuzz.sh

trap - EXIT
echo 'Success!'
