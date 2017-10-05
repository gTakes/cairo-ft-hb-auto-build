# Cairo-FreeType-HarfBuzz自動ビルド
<div style="text-align:right"><a href="./README_EN.md">English</a> | 日本語</div>

## 概要
このリポジトリは、`Cairo`、`FreeType`、`HarfBuzz`の**Windows**用DLLの自動ビルドを補助するためのシェルスクリプトです。  
Jeff Preshingが作成した[build-cairo-windows.sh](https://github.com/preshing/cairo-windows)を元に修正を加え、HarfBuzzのビルド過程を追加しています。元の`build-cairo-windows.sh`との違いは次のようになります。
1. FreeTypeはスタティックライブラリではなく、ダイナミックライブラリとして出力される。
2. CairoはFreeTypeをDLLとしてリンクする。
3. HarfBuzzもFreeTypeをDLLとしてリンクする。
4. スクリプトは一つではなく、それぞれのライブラリのビルド毎に分かれている。
5. デバッグ用のビルドを行うことができる。
5. Visual Studio 2015をターゲットとしている。（build-cairo-windows.shはVisual Studio 2017）

ビルドすると、`cairo.dll`、`freetype28(d).dll`、`harfbuzz-vs14.dll`が生成されます。

次のシェルスクリプトで構成されています。
* build-all-cairo-ft-hb.sh ...メインのスクリプト
* build-cairo.sh ... Cairoをビルドするためのスクリプト
* build-freetype.sh ... FreeTypeをビルドするためのスクリプト
* build-harfbuzz.sh ... HarfBuzzをビルドするためのスクリプト
* build-libpng-zlib.sh ... LibPNGとzlibをビルドするためのスクリプト
* build-pixman.sh ... Pixmanをビルドするためのスクリプト

直接実行可能なスクリプトは、`build-all-cairo-ft-hb.sh`です。その他のスクリプトは`build-all-cairo-ft-hb.sh`より呼び出されるようになっています。

## ビルド方法

`build-all-cairo-ft-hb.sh`と他のシェルスクリプトは必要なライブラリをダウンロードして展開します。可能な限りビルド過程で生成されたものを使用するようになっています。`cairo.dll`と`harfbuzz-vs14.dll`は`freetype28.dll`に依存するように生成されます。

このスクリプトでは `Visual Studio 2015コンパイラ` が使用されます。このスクリプトは、[MSYS2](http://www.msys2.org/)のビルド環境で行われることを前提としています。もし、MSYS2をインストールした直後であれば、MSYS2に `tar` と `make` をセットアップします。

    $ pacman -S tar make

### 32ビット版のビルド

スタートメニューから「VS2015 x86 Native Tools Command Prompt」を開きます。MSYS2のパスを追加します。そして、（VS2015の `INCLUDE`、
 `LIB`、`PATH` などを継承した）MSYS2のシェルを起動し、ビルドスクリプトを実行します。

```sh
(VS2015 x86 Native Tools Command Prompt)
> set PATH=C:\msys32\usr\bin;%PATH%
> sh
$ ./build-all-cairo-ft-hb.sh
```
すべてのビルドに成功すると次のように表示されます。

    Success!


終了すると、次のフォルダにパッケージが作成されています。
+ `output/cairo-windows-1.15.6`
+ `output/freetype-windows-2.8`
+ `output/harfbuzz-windows-1.5.1`

デバッグ版の場合は、引数に `x86` と `debug` を追加してスクリプトを実行します。

    $ ./build-all-cairo-ft-hb.sh x86 debug

### 64ビット版のビルド
64ビット版のビルドは32ビット版をビルドした後に行います。

1. `libpng\projects\vstudio\vstudio.sln` をVisual Studioで開きます。
2.  次のように、ソリューションにx64プラットフォームを追加します。
    * メニューから、「ビルド」 &rarr; 「構成マネージャー」
    * アクティブ ソリューション プラットフォーム： &rarr; <新規作成...>
    * x64を選択、 OKをクリック、 構成マネージャーを閉じる
    * メニューから、「ファイル」 &rarr; 「すべて保存」
3. 「VS2015 **x64** Native Tools Command Prompt」を開き、32ビット版のように行う。スクリプトの引数には `x64` を追加する：

```sh
(VS2015 x64 Native Tools Command Prompt)
> set PATH=C:\msys32\usr\bin;%PATH%
> sh
$ ./build-cairo-windows.sh x64
```
デバッグ版の場合は、引数に `x64` と `debug` を追加してスクリプトを実行します。

    $ ./build-all-cairo-ft-hb.sh x64 debug

## ライセンス
ライセンスは、[The Unlicense](http://unlicense.org/) が適用されます。動作保証はありません。著作権表示の必要もなく、自由に使用することができます。

## 謝辞
このスクリプトの元になった`build-cairo-windows.sh`を作成、公開されたJeff Preshing氏に感謝いたします。  
また、Cairo、FreeType、HarfBuzzその他関連するライブラリを作成された方々にも感謝いたします。