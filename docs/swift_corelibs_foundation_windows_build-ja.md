# Swift の swift-corelibs-foundation を Windows で手軽にビルドするためのメモ

- [swift-corelibs-foundation のバグらしき挙動をなおしてマージされた直後に Windows でビルドできなくて Revert された件](https://twitter.com/niw/status/1296607250706882561)について、傾向と対策を行った。

- 基本は https://github.com/apple/swift/blob/master/docs/WindowsBuild.md を参考にする。
- Swift はビルドしないで、既製の Toolchain と SDK を使う。

## Windows の準備

- [Windows の ISO](https://www.microsoft.com/ja-jp/software-download/windows10ISO) をダウンロードして、Windows 10 をインストール。
- 最近の Windows 10 はインストール中はインターネットを切っておかないとローカルオンリーのアカウントが作れない。
- インストール終わったらインターネットに繋いで Windows Update を終わるまで繰り返す。
- Settings の Update & Security にある For developers (猫の上のやつ)で Developer Mode を ON にする。が、実際はしなくてもあんまり問題なかったけど、シンボリックリンクが作れなくなるらしい。

## Visual Studio の準備

- [Visual Studio 2019 Community Edition のインストーラー](https://visualstudio.microsoft.com/ja/downloads/)をダウンロードしてコマンドプロンプトで以下を実行。

```
vs_community ^
--add Component.CPython2.x86 ^
--add Component.CPython3.x64 ^
--add Microsoft.VisualStudio.Component.Git ^
--add Microsoft.VisualStudio.Component.VC.ATL ^
--add Microsoft.VisualStudio.Component.VC.CMake.Project ^
--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 ^
--add Microsoft.VisualStudio.Component.Windows10SDK ^
--add Microsoft.VisualStudio.Component.Windows10SDK.17763
```

- ダウンロードしたインストーラーは `vs_community...exe` と長い名前になっているので置き換えること。
- 実行したあと GUI が表示されるので、その画面でインストールする。

## 既成の Toolchain と SDK の取得

- compnerd さんが [Windows でのビルドを含む CI](https://dev.azure.com/compnerd/swift-build/_build) を作ってるのでそこから入手する([参考記事](https://forums.swift.org/t/windows-nightlies/19174))。

- たとえば、[ここ](https://dev.azure.com/compnerd/swift-build/_build?definitionId=7)の VS2019 で最後に成功しているのを探し、[Artifacts](https://dev.azure.com/compnerd/swift-build/_build/results?buildId=36078&view=artifacts&type=publishedArtifacts) から最近に近い Toolchain のインストーラーがダウンロードできる。

- Artifacts にはいろいろあるが、`installer.exe` で十分なので、それをダウンロードして実行、インストールする。
- 全て `C:\Library` にインストールされる。

- 後でソースから作り直す libdispatch と Foundation を SDK から削除しておく。

```
set SDKROOT=%SystemDrive%\Library\Developer\Platforms\Windows.platform\Developer\SDKs\Windows.sdk

rmdir /s /q %SDKROOT%\usr\include\Block
rmdir /s /q %SDKROOT%\usr\include\dispatch
rmdir /s /q %SDKROOT%\usr\lib\swift\CFURLSession
rmdir /s /q %SDKROOT%\usr\lib\swift\CFXMLInterface
rmdir /s /q %SDKROOT%\usr\lib\swift\CoreFoundation
del %SDKROOT%\usr\lib\swift\windows\BlocksRuntime.lib
del %SDKROOT%\usr\lib\swift\windows\dispatch.lib
del %SDKROOT%\usr\lib\swift\windows\Foundation.lib
del %SDKROOT%\usr\lib\swift\windows\FoundationNetworking.lib
del %SDKROOT%\usr\lib\swift\windows\swiftDispatch.lib
del %SDKROOT%\usr\lib\swift\windows\x85_64\Dispatch.swiftdoc
del %SDKROOT%\usr\lib\swift\windows\x85_64\Dispatch.swiftmodule
del %SDKROOT%\usr\lib\swift\windows\x85_64\Foundation.swiftdoc
del %SDKROOT%\usr\lib\swift\windows\x85_64\Foundation.swiftmodule
del %SDKROOT%\usr\lib\swift\windows\x85_64\FoundationNetworking.swiftdoc
del %SDKROOT%\usr\lib\swift\windows\x85_64\FoundationNetworking.swiftmodule
del %SDKROOT%\usr\lib\swift\windows\x85_64\FoundationXML.swiftdoc
del %SDKROOT%\usr\lib\swift\windows\x85_64\FoundationXML.swiftmodule
```
 
## ソースコードと依存ライブラリを準備

### コマンドプロンプト

- 基本的に作業は Visual Studio 2019 の x64 Native Tools Command Prompt で行う。
- [こちら](https://docs.microsoft.com/en-us/cpp/build/building-on-the-command-line?view=vs-2019)を参考に。
- これを使わないと PATH が通ってなくてなにも使えない。
- また、これを使わないと x86 と x86_64 が混ざって面倒なことになる。

### ソースの取得とワーキングドライブの準備

- `%USERPROFILE%\Sources` を作って、ソースをクローンする。
- `%USERPROFILE%` は `C:\Usres\ユーザー名` のはず。
- `subst` コマンドで、このディレクトリをドライブ(ここでは `S:`)のルートに割り当てておく。
- `swift` は後述の modulemap の入手のためだけに必要、ただ、SDK からコピーできるかも。

```
subst S: %USERPROFILE%\Sources
S:
git clone --depth=1 https://github.com/apple/swift.git
git clone --depth=1 https://github.com/apple/swift-corelibs-libdispatch.git
git clone --depth=1 https://github.com/apple/swift-corelibs-foundation.git
```

### modulemap の準備

- 以下のコマンドを x64 Native Tools Command Prompt 右クリックして Run as Administrator を選択して Administrator で行う。

```
subst S: %USERPROFILE%\Sources
S:
mklink "%UniversalCRTSdkDir%\Include\%UCRTVersion%\ucrt\module.modulemap" S:\swift\stdlib\public\Platform\ucrt.modulemap
mklink "%UniversalCRTSdkDir%\Include\%UCRTVersion%\um\module.modulemap" S:\swift\stdlib\public\Platform\winsdk.modulemap
mklink "%VCToolsInstallDir%\include\module.modulemap" S:\swift\stdlib\public\Platform\visualc.modulemap
mklink "%VCToolsInstallDir%\include\visualc.apinotes" S:\swift\stdlib\public\Platform\visualc.apinotes
```

### 依存ライブラリの準備

- [vcpkg](https://github.com/Microsoft/vcpkg) を使ってインストールする。
- Swift の [WindowsBuild.md](https://github.com/apple/swift/blob/master/docs/WindowsBuild.md) にはなにも書かれてなくて、`C:\Library` にインストールされていることとするとしか書いてないけどそれを手動で準備するのはイバラの道。
- すごい遅い。特に `icu`。

```
cd S:\
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
bootstrap-vcpkg.bat
vcpkg integrate install
vcpkg install curl libxml2 icu
```

## swift-corelibs-libdispatch をビルド

以下を実行。`libdispatch.bat` とかにして `S:\` に置いておく。

```
set TOOLCHAINROOT=%SystemDrive%/Library/Developer/Toolchains/unknown-Asserts-development.xctoolchain
set SDKROOT=%SystemDrive%/Library/Developer/Platforms/Windows.platform/Developer/SDKs/Windows.sdk

cmake -B S:\b\libdispatch ^
-D CMAKE_BUILD_TYPE=RelWithDebInfo ^
-D CMAKE_C_COMPILER=%TOOLCHAINROOT%/usr/bin/clang-cl.exe ^
-D CMAKE_C_FLAGS="-m64" ^
-D CMAKE_CXX_COMPILER=%TOOLCHAINROOT%/usr/bin/clang-cl.exe ^
-D CMAKE_CXX_FLAGS="-m64" ^
-D CMAKE_Swift_COMPILER=%TOOLCHAINROOT%/usr/bin/swiftc.exe ^
-D CMAKE_Swift_FLAGS="-sdk %SDKROOT% -I %SDKROOT%/usr/lib/swift -L %SDKROOT%/usr/lib/swift/windows" ^
-D ENABLE_SWIFT=YES ^
-G Ninja ^
-S S:\swift-corelibs-libdispatch

ninja -C S:\b\libdispatch
```

- `-m64` がないと clang 検証中にエラーになる。
- `-sdk` がないと swiftc 検証中にエラーになる。

## swift-corelibs-foundation をビルド

以下を実行。`foundation.bat` とかにして `S:\` に置いておく。

```
set TOOLCHAINROOT=%SystemDrive%/Library/Developer/Toolchains/unknown-Asserts-development.xctoolchain
set SDKROOT=%SystemDrive%/Library/Developer/Platforms/Windows.platform/Developer/SDKs/Windows.sdk
set VCPKGROOT=S:/vcpkg

cmake -B S:\b\foundation ^
-D CMAKE_TOOLCHAIN_FILE=%VCPKGROOT%\scripts\buildsystems\vcpkg.cmake ^
-D CMAKE_BUILD_TYPE=RelWithDebInfo ^
-D CMAKE_C_COMPILER=%TOOLCHAINROOT%/usr/bin/clang-cl.exe ^
-D CMAKE_C_FLAGS="-m64" ^
-D CMAKE_Swift_COMPILER=%TOOLCHAINROOT%/usr/bin/swiftc.exe ^
-D CMAKE_Swift_FLAGS="-sdk %SDKROOT% -I %SDKROOT%/usr/lib/swift -L %SDKROOT%/usr/lib/swift/windows" ^
-D dispatch_DIR=S:/b/libdispatch/cmake/modules ^
-D ICU_ROOT=%VCPKGROOT%/installed/x64-windows ^
-D ICU_INCLUDE_DIR=%VCPKGROOT%/installed/x64-windows/include ^
-D ENABLE_TESTING=NO ^
-G Ninja ^
-S S:\swift-corelibs-foundation

ninja -C S:\b\foundation
```

- `-m64` がないと clang 検証中にエラーになる。
- `-sdk` がないと swiftc 検証中にエラーになる。
- `CMAKE_TOOLCHAIN_FILE` がないと `libcurl` と `libxml2` が見つけられない。

## 補足

- コマンドプロンプトはかなりシンドイので、OpenSSH を有効にして ssh 経由で操作したほうが、繰り返しの作業があるなら楽。
- Windows Terminal だとちょっとだけマシかもしれないけれど、コマンドプロンプト自体がアレなのでまあ、ね。
- 多分上記が全部設定済の Azure インスタンスをポチッと作れてリモートログインできるようになればみんな幸せになるんだと思うので誰かお願いします。
