#!/bin/bash

# Simple script to build Kotlin/Native iOS frameworks and create XCFramework

set -e

echo "Building Kotlin code..."

KOTLIN_NATIVE_BIN="kotlinc-native"

# Ensure kotlinc-native is available
if ! command -v $KOTLIN_NATIVE_BIN &> /dev/null; then
    echo "Error: $KOTLIN_NATIVE_BIN is not installed or not in your PATH."
    exit 1
fi

all_targets=(
    "ios_arm64"
    "ios_x64"
    "ios_simulator_arm64"
    "macos_arm64"
    "macos_x64"
)

file_list=$(find src -name "*.kt" | tr '\n' ' ')

for target in "${all_targets[@]}"; do
    echo "Building for target: $target"
    $KOTLIN_NATIVE_BIN $file_list \
        -target "$target" \
        -produce framework \
        -module-name Kotlib \
        -Xbinary=bundleId=com.kotlib.framework \
        -Xexport-kdoc \
        -output "build/frameworks/${target}/Kotlib"
done

# Remove existing XCFramework if it exists
rm -rf build/Kotlib.xcframework

# Create a combined simulator framework
echo "Combining simulator frameworks..."
mkdir -p build/frameworks/ios_simulator
cp -R build/frameworks/ios_x64/Kotlib.framework build/frameworks/ios_simulator/
cp -R build/frameworks/ios_x64/Kotlib.framework.dSYM build/frameworks/ios_simulator/

# Create a fat binary with both simulator architectures
lipo -create \
    build/frameworks/ios_x64/Kotlib.framework/Kotlib \
    build/frameworks/ios_simulator_arm64/Kotlib.framework/Kotlib \
    -output build/frameworks/ios_simulator/Kotlib.framework/Kotlib

# Create a combined macOS framework
echo "Combining macOS frameworks..."
mkdir -p build/frameworks/macos
cp -R build/frameworks/macos_x64/Kotlib.framework build/frameworks/macos/
cp -R build/frameworks/macos_x64/Kotlib.framework.dSYM build/frameworks/macos/

# Create a fat binary with both macOS architectures
lipo -create \
    build/frameworks/macos_x64/Kotlib.framework/Versions/A/Kotlib \
    build/frameworks/macos_arm64/Kotlib.framework/Versions/A/Kotlib \
    -output build/frameworks/macos/Kotlib.framework/Versions/A/Kotlib

# Ensure the main binary symlink exists for macOS framework
MACOS_FRAMEWORK="build/frameworks/macos/Kotlib.framework"
if [ ! -L "$MACOS_FRAMEWORK/Kotlib" ]; then
    ln -sfh "Versions/Current/Kotlib" "$MACOS_FRAMEWORK/Kotlib"
fi

# Create XCFramework with device and combined simulator
xcodebuild -create-xcframework \
    -framework build/frameworks/ios_arm64/Kotlib.framework \
    -framework build/frameworks/ios_simulator/Kotlib.framework \
    -framework build/frameworks/macos/Kotlib.framework \
    -output build/Kotlib.xcframework

echo "Creating Package.swift for Swift Package Manager..."

# Create Package.swift in build directory
cat > build/Package.swift << EOF
// swift-tools-version:6.1
import PackageDescription
let package = Package(
    name: "Kotlib",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "Kotlib", targets: ["Kotlib"])],
    targets: [.binaryTarget(name: "Kotlib", path: "Kotlib.xcframework")]
)
EOF

echo "✅ XCFramework created successfully at: build/Kotlib.xcframework"
echo "✅ Package.swift created for Swift Package Manager at: build/Package.swift"
