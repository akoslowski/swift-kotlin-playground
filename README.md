# Kotlib XCFramework

```shell
brew install --cask kotlin-native

# maybe trust some random libraries
xattr -d com.apple.quarantine '/opt/homebrew/Caskroom/kotlin-native/2.2.0/kotlin-native-prebuilt-macos-aarch64-2.2.0/konan/nativelib'/*

make clean macos test
```
