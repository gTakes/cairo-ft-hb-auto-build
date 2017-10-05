# This script is a part of build-all-cairo-ft-hb.sh
# It is called from the parent script with the source command.

TARGET_DLL=1

# Download package if not already
wget -nc http://download.savannah.gnu.org/releases/freetype/$FREETYPE_VERSION.tar.gz

# Extract package if not already
if [ ! -d freetype ]; then
    echo "Extracting $FREETYPE_VERSION..."
    tar -xzf $FREETYPE_VERSION.tar.gz
    mv $FREETYPE_VERSION freetype
fi 

# Build freetype
cd freetype
if [ ! -d "builds/windows/vc2010/Backup" ]; then
	# Upgrade solution if not already
	devenv.com "builds/windows/vc2010/freetype.sln" -upgrade
fi


if [ $TARGET_DLL -ne 0 ]; then
	MSVC_CONFIG_LNAME=$MSVC_CONFIG_CNAME 
	sed '/<PropertyGroup Condition=.*.[(Release)(Debug)]|[(Win32)(x64)]/{n;/StaticLibrary/s/StaticLibrary/DynamicLibrary/}' builds/windows/vc2010/freetype.vcxproj > freetype.vcxproj.fixed
	mv freetype.vcxproj.fixed builds/windows/vc2010/freetype.vcxproj
	sed '/#define FT_EXPORT(x)/s/.*/#define FT_EXPORT(x) __declspec(dllexport) x/' include/freetype/config/ftoption.h > ftoption.h.fixed1
	sed '/#define FT_EXPORT_DEF(x)/s/.*/#define FT_EXPORT_DEF(x) __declspec(dllexport) x/' ftoption.h.fixed1 > ftoption.h.fixed2
	mv ftoption.h.fixed2 include/freetype/config/ftoption.h
	rm ftoption.h.fixed1	
else
	MSVC_CONFIG_LNAME="$MSVC_CONFIG_CNAME Multithreaded"
	sed '/#define FT_EXPORT(x)/s/.*/\/\* #define FT_EXPORT(x) extern x \*\//' include/freetype/config/ftoption.h > ftoption.h.fixed1
	sed '/#define FT_EXPORT_DEF(x)/s/.*/\/\* #define FT_EXPORT_DEF(x) x \*\//' ftoption.h.fixed1 > ftoption.h.fixed2
	mv ftoption.h.fixed2 include/freetype/config/ftoption.h
	rm ftoption.h.fixed1
fi

devenv.com "builds/windows/vc2010/freetype.sln" -build "$MSVC_CONFIG_LNAME|$MSVC_PLATFORM_NAME"
# cp `ls -1d objs/vc2010/$MSVC_PLATFORM_NAME/freetype*MT.lib` freetype.lib
cd ..

# Package headers with DLL
OUTPUT_FOLDER=output/${FREETYPE_VERSION/freetype-/freetype-windows-}
mkdir -p $OUTPUT_FOLDER/include
cp -a freetype/include/* $OUTPUT_FOLDER/include

mkdir -p $OUTPUT_FOLDER/lib/$OUTPUT_PLATFORM_NAME//$MSVC_CONFIG_NAME
FT_NUM_LIST=`ls freetype/objs/vc2010/$MSVC_PLATFORM_NAME | sed -n '/.*\.lib/s/[^0-9]//gp'`
FT_VER_NUM=`echo $FT_NUM_LIST | sed 's/[^0-9].*//g'`
cp freetype/objs/vc2010/$MSVC_PLATFORM_NAME/freetype${FT_VER_NUM}${DEBUG_ADD_STR}.lib $OUTPUT_FOLDER/lib/$OUTPUT_PLATFORM_NAME/$MSVC_CONFIG_NAME
cp freetype/objs/vc2010/$MSVC_PLATFORM_NAME/freetype${FT_VER_NUM}${DEBUG_ADD_STR}.dll $OUTPUT_FOLDER/lib/$OUTPUT_PLATFORM_NAME/$MSVC_CONFIG_NAME
cp freetype/docs/FTL.TXT $OUTPUT_FOLDER