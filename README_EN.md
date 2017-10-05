# Cairo-FreeType-HarfBuzz Automatically Build
<div style="text-align:right">English | <a href="./README_JA.md">日本語</a></div>

## Overview
This repository is some shell scripts that automatically building `Cairo`, `FreeType` and `HarfBuzz` DLLs for **Windows**.  
They have been changed based on [build-cairo-windows.sh](https://github.com/preshing/cairo-windows) which was created by Jeff Preshing and the HarfBuzz build process has been added. The difference from the original `build-cairo-windows.sh` is as follows.
1. `FreeType` is not a static library but is output as a dynamic link library.
2. `Cairo` links `FreeType` as DLL.
3. `HarfBuzz` also links `FreeType` as DLL.
4. Scripts are not one, they are divided for each build of each library.
5. They can be built for debug.
6. It targets Visual Studio 2015.  
（`build-cairo-windows.sh` targets Visual Studio 2017）

When after build, `cairo.dll`, ` freetype 28(d).dll` and  `harfbuzz-vs14.dll` are generated.

They consist of the following shell scripts.
* build-all-cairo-ft-hb.sh ...Main script
* build-cairo.sh ... Script for building Cairo
* build-freetype.sh ... Script for building FreeType
* build-harfbuzz.sh ... Script for building HarfBuzz
* build-libpng-zlib.sh ... Script for building LibPNG and zlib
* build-pixman.sh ... Script for building Pixman

The directly executable script is `build-all-cairo-ft-hb.sh`. Other scripts are to be called from `build-all-cairo-ft-hb.sh`.

## Build Steps

The `build-all-cairo-ft-hb.sh` and other shell scripts will download, extract, and build all the necessary libraries. It uses the existing build pipelines of each library as much as possible. 
the `cairo.dll` and the `harfbuzz-vs14.dll` are generated to depend on the `freetype 28.dll`.

The Visual Studio 2015 compiler is used.
This script is assumed to be done in the build environment of [MSYS 2](http://www.msys2.org/). 
If you just installed MSYS2, you'll need to install `tar` and `make` first:

    $ pacman -S tar make

### Building 32-bit

From the start menu, open "VS2015 x86 Native Tools Command Prompt". Add the MSYS2 toolchain to the path. Start an MSYS2 shell (which inherits the `INCLUDE`, `LIB` and `PATH` variables from the first prompt), then run the script.

```sh
(from a VS2015 x86 Native Tools Command Prompt)
> set PATH=C:\msys32\usr\bin;%PATH%
> sh
$ ./build-all-cairo-ft-hb.sh
```

If all the builds succeed, they are displayed as follow.

    Success!


When finished, the package is created in the following folders.
+ `output/cairo-windows-1.15.6`
+ `output/freetype-windows-2.8`
+ `output/harfbuzz-windows-1.5.1`

For the debug version, execute the script by adding `x86` and `debug` as arguments.

    $ ./build-all-cairo-ft-hb.sh x86 debug


### Building 64-bit

The 64-bit version build is done after building the 32-bit version.

1. Open `libpng\projects\vstudio\vstudio.sln` in Visual Studio.
2. Then add the "x64" platform to the solution as follows:
   * Build &rarr; Configuration Manager
   * Active solution platform: &rarr; <New...>
   * Select x64, click OK, close the Configuration Manager
   * File &rarr; Save All
3. Perform similar steps as for 32-bit, but open a "VS2015 **x64** Native Tools Command Prompt" instead, and pass `x64` as an argument to the script:

```sh
(from a VS2015 x64 Native Tools Command Prompt)
> set PATH=C:\msys32\usr\bin;%PATH%
> sh
$ ./build-all-cairo-ft-hb.sh x64
```
For the debug version, execute the script by adding `x64` and `debug` as arguments.

    $ ./build-all-cairo-ft-hb.sh x64 debug

## License

The license applies [The Unlicense](http://unlicense.org/). There are no warranty, and can be freely used without the necessity of copyright indication.

## Acknowledgments
I would like to thank *Jeff Preshing* for creating and publishing the `build-cairo-windows.sh`.  
Also I thank those who created Cairo, FreeType, HarfBuzz and other related libraries.