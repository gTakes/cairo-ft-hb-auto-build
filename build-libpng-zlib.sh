# This script is a part of build-all-cairo-ft-hb.sh
# It is called from the parent script with the source command.

# Download packages if not already
wget -nc ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng16/$LIBPNG_VERSION.tar.gz
wget -nc http://www.zlib.net/$ZLIB_VERSION.tar.gz  

# Extract packages if not already
if [ ! -d libpng ]; then
    echo "Extracting $LIBPNG_VERSION..."
    tar -xzf $LIBPNG_VERSION.tar.gz
    mv $LIBPNG_VERSION libpng
fi
if [ ! -d zlib ]; then
    echo "Extracting $ZLIB_VERSION..."
    tar -xzf $ZLIB_VERSION.tar.gz
    mv $ZLIB_VERSION zlib
fi

# Build libpng and zlib
cd libpng
sed s/zlib-1.2.8/zlib/ projects/vstudio/zlib.props > zlib.props.fixed
mv zlib.props.fixed projects/vstudio/zlib.props
if [ ! -d "projects\vstudio\Backup" ]; then
    # Upgrade solution if not already
    devenv.com "projects\vstudio\vstudio.sln" -upgrade
fi
devenv.com "projects\vstudio\vstudio.sln" -build "$MSVC_CONFIG_CNAME Library|$MSVC_PLATFORM_NAME" -project libpng
cd ..

LIBPNG_OUT_DIR=libpng/win32/$MSVC_PLATFORM_NAME/$MSVC_CONFIG_NAME
mkdir -p $LIBPNG_OUT_DIR
if [ $MSVC_PLATFORM_NAME = x64 ]; then
    cp "libpng/projects/vstudio/x64/$MSVC_CONFIG_CNAME Library/libpng16.lib" $LIBPNG_OUT_DIR/libpng.lib
	cp "libpng/projects/vstudio/x64/$MSVC_CONFIG_CNAME Library/zlib.lib" $LIBPNG_OUT_DIR/zlib.lib
else
    cp "libpng/projects/vstudio/$MSVC_CONFIG_CNAME Library/libpng16.lib" $LIBPNG_OUT_DIR/libpng.lib
	cp "libpng/projects/vstudio/$MSVC_CONFIG_CNAME Library/zlib.lib" $LIBPNG_OUT_DIR/zlib.lib
fi

