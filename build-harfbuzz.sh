# This script is a part of build-all-cairo-ft-hb.sh
# It is called from the parent script with the source command.

# Download packages if not already
wget -nc https://www.freedesktop.org/software/harfbuzz/release/$HARFBUZZ_VERSION.tar.bz2 

# Extract packages if not already
if [ ! -d harfbuzz ]; then
    echo "Extracting $HARFBUZZ_VERSION..."
    tar -xf $HARFBUZZ_VERSION.tar.bz2
    mv $HARFBUZZ_VERSION harfbuzz
fi

# Build harfbuzz
cd harfbuzz

if [ $USE_FREETYPE -ne 0 ]; then
	FT_NUMLIST=`ls ../freetype/objs/vc2010/$MSVC_PLATFORM_NAME | sed -n '/.*\.lib/s/[^0-9]//gp'`
	FT_NUM=`echo $FT_NUMLIST | sed 's/[^0-9].*//g'`
	FT_LIB_R="FREETYPE_LIB = ..\\\..\\\freetype\\\objs\\\vc2010\\\\$MSVC_PLATFORM_NAME\\\freetype${FT_NUM}.lib"
	FT_LIB_D="FREETYPE_LIB = ..\\\..\\\freetype\\\objs\\\vc2010\\\\$MSVC_PLATFORM_NAME\\\freetype${FT_NUM}d.lib"
	FT_INC="FREETYPE_DIR = ..\\\..\\\freetype\\\include"
	sed "/^# Freetype is/{n;n;s/.*/$FT_LIB_D/}" win32/config-msvc.mak > config-msvc.mak.fixed2
	sed "/^# Freetype is/{n;n;n;n;s/.*/$FT_LIB_R/}" config-msvc.mak.fixed2 > config-msvc.mak.fixed
	sed "/^# Freetype is/{n;n;n;n;n;n;s/.*/$FT_INC/}" config-msvc.mak.fixed > win32/config-msvc.mak
	rm config-msvc.mak.fixed*	
fi

cd win32

nmake -f Makefile.vc CFG=$MSVC_CONFIG_NAME FREETYPE=1

# Change directory to harfbuzz's root
cd ../..

# Package headers with DLL
OUTPUT_FOLDER=output/${HARFBUZZ_VERSION/harfbuzz-/harfbuzz-windows-}
mkdir -p $OUTPUT_FOLDER/include
for file in harfbuzz/src/hb.h \
			harfbuzz/src/hb-blob.h \
			harfbuzz/src/hb-buffer.h \
			harfbuzz/src/hb-common.h \
			harfbuzz/src/hb-deprecated.h \
			harfbuzz/src/hb-face.h \
			harfbuzz/src/hb-font.h \
			harfbuzz/src/hb-set.h \
			harfbuzz/src/hb-shape.h \
			harfbuzz/src/hb-shape-plan.h \
			harfbuzz/src/hb-unicode.h \
			harfbuzz/src/hb-version.h; do
    cp $file $OUTPUT_FOLDER/include
done
if [ $USE_FREETYPE -ne 0 ]; then
    cp harfbuzz/src/hb-ft.h $OUTPUT_FOLDER/include
fi
mkdir -p $OUTPUT_FOLDER/lib/$OUTPUT_PLATFORM_NAME/$MSVC_CONFIG_NAME
cp harfbuzz/win32/$MSVC_CONFIG_NAME/$MSVC_PLATFORM_NAME/harfbuzz*.lib $OUTPUT_FOLDER/lib/$OUTPUT_PLATFORM_NAME/$MSVC_CONFIG_NAME
cp harfbuzz/win32/$MSVC_CONFIG_NAME/$MSVC_PLATFORM_NAME/harfbuzz*.dll $OUTPUT_FOLDER/lib/$OUTPUT_PLATFORM_NAME/$MSVC_CONFIG_NAME
cp harfbuzz/COPYING* $OUTPUT_FOLDER

