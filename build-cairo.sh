# This script is a part of build-all-cairo-ft-hb.sh
# It is called from the parent script with the source command.

# Download packages if not already
wget -nc https://www.cairographics.org/snapshots/$CAIRO_VERSION.tar.xz 

# Extract packages if not already
if [ ! -d cairo ]; then
    echo "Extracting $CAIRO_VERSION..."
    tar -xJf $CAIRO_VERSION.tar.xz
    mv $CAIRO_VERSION cairo
fi

# Build cairo
cd cairo

LIBPNG_LIB_SPECIFY="CAIRO_LIBS += \$\(top_builddir\)\/..\/libpng\/win32\/$MSVC_PLATFORM_NAME\/$MSVC_CONFIG_NAME"
sed "s/-MD/-MT/;/^ZLIB_CFLAGS += -I/{n;s/^CAIRO_LIBS.*/$LIBPNG_LIB_SPECIFY\/zlib.lib/};/^LIBPNG_CFLAGS +=/{n;s/^CAIRO_LIBS.*/$LIBPNG_LIB_SPECIFY\/libpng.lib/}" build/Makefile.win32.common > Makefile.win32.common.fixed
mv Makefile.win32.common.fixed build/Makefile.win32.common

if [ $USE_FREETYPE -ne 0 ]; then
	NUMLIST=`ls ../freetype/objs/vc2010/$MSVC_PLATFORM_NAME | sed -n '/.*\.lib/s/[^0-9]//gp'`
	FVER_NUMBER=`echo $NUMLIST | sed 's/[^0-9].*//g'`
	FTLIB_DIR="CAIRO_LIBS \+\= \$\(top_builddir\)\/..\/freetype\/objs\/vc2010\/$MSVC_PLATFORM_NAME\/freetype$FVER_NUMBER$DEBUG_ADD_STR.lib"
	sed "/^CAIRO_LIBS = /{n;s/.*/$FTLIB_DIR/}" build/Makefile.win32.common > Makefile.win32.common.tmp

	FT_INC_DIR='-I\$\(top_srcdir\)\/..\/freetype\/include'
	DEFAULT_CFLAGS_STR="DEFAULT_CFLAGS \= \-nologo \$\(CFG_CFLAGS\) $FT_INC_DIR"
	sed "/^DEFAULT_CFLAGS = /s/.*/$DEFAULT_CFLAGS_STR/" Makefile.win32.common.tmp > Makefile.win32.common.fixed
	rm Makefile.win32.common.tmp
else
	sed '/^CAIRO_LIBS = /{n;/^CAIRO_LIBS += /d}' build/Makefile.win32.common > Makefile.win32.common.tmp
	DEFAULT_CFLAGS_STR="DEFAULT_CFLAGS \= \-nologo \$\(CFG_CFLAGS\)"
	sed "/^DEFAULT_CFLAGS = /s/.*/$DEFAULT_CFLAGS_STR/" Makefile.win32.common.tmp > Makefile.win32.common.fixed
	rm Makefile.win32.common.tmp
fi
mv Makefile.win32.common.fixed build/Makefile.win32.common

sed "s/CAIRO_HAS_FT_FONT=./CAIRO_HAS_FT_FONT=$USE_FREETYPE/" build/Makefile.win32.features > Makefile.win32.features.fixed
mv Makefile.win32.features.fixed build/Makefile.win32.features
# pass -B for switching between x86/x64
make -B -f Makefile.win32 cairo "CFG=$MSVC_CONFIG_NAME"
cd ..

# Package headers with DLL
OUTPUT_FOLDER=output/${CAIRO_VERSION/cairo-/cairo-windows-}
mkdir -p $OUTPUT_FOLDER/include
for file in cairo/cairo-version.h \
            cairo/src/cairo-features.h \
            cairo/src/cairo.h \
            cairo/src/cairo-deprecated.h \
            cairo/src/cairo-win32.h \
            cairo/src/cairo-script.h \
            cairo/src/cairo-ps.h \
            cairo/src/cairo-pdf.h \
            cairo/src/cairo-svg.h; do
    cp $file $OUTPUT_FOLDER/include
done
if [ $USE_FREETYPE -ne 0 ]; then
    cp cairo/src/cairo-ft.h $OUTPUT_FOLDER/include
fi
mkdir -p $OUTPUT_FOLDER/lib/$OUTPUT_PLATFORM_NAME/$MSVC_CONFIG_NAME
cp cairo/src/$MSVC_CONFIG_NAME/cairo.lib $OUTPUT_FOLDER/lib/$OUTPUT_PLATFORM_NAME/$MSVC_CONFIG_NAME
cp cairo/src/$MSVC_CONFIG_NAME/cairo.dll $OUTPUT_FOLDER/lib/$OUTPUT_PLATFORM_NAME/$MSVC_CONFIG_NAME
cp cairo/COPYING* $OUTPUT_FOLDER

