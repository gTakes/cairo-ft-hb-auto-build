# This script is a part of build-all-cairo-ft-hb.sh
# It is called from the parent script with the source command.

# Download package if not already
wget -nc https://www.cairographics.org/releases/$PIXMAN_VERSION.tar.gz

# Extract package if not already
if [ ! -d pixman ]; then
    echo "Extracting $PIXMAN_VERSION..."
    tar -xzf $PIXMAN_VERSION.tar.gz
    mv $PIXMAN_VERSION pixman
fi

# Build pixman
cd pixman
sed s/-MD/-MT/ Makefile.win32.common > Makefile.win32.common.fixed
mv Makefile.win32.common.fixed Makefile.win32.common
if [ $MSVC_PLATFORM_NAME = x64 ]; then
    # pass -B for switching between x86/x64
    make pixman -B -f Makefile.win32 "CFG=$MSVC_CONFIG_NAME" "MMX=off"
else
    make pixman -B -f Makefile.win32 "CFG=$MSVC_CONFIG_NAME"
fi
cd ..
