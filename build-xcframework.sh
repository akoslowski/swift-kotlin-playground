#!/bin/bash

# Simple script to build Kotlin/Native iOS frameworks and create XCFramework

set -e

function build_target {
    KOTLIN_NATIVE_BIN="kotlinc-native"
    if ! command -v $KOTLIN_NATIVE_BIN &> /dev/null; then
        echo "Error: $KOTLIN_NATIVE_BIN is not installed or not in your PATH."
        exit 1
    fi

    local output_path="build/frameworks"
    local source_path="src"

    local target=$1
    echo "Building for target: $target"

    file_list=$(find $source_path -name "*.kt" | tr '\n' ' ')
    $KOTLIN_NATIVE_BIN $file_list \
        -target "$target" \
        -produce framework \
        -module-name Kotlib \
        -Xbinary=bundleId=com.kotlib.framework \
        -Xexport-kdoc \
        -output "$output_path/${target}/Kotlib"
}

echo "Building Kotlin code..."

all_targets=(
    "ios_arm64"
    "ios_simulator_arm64"
    "macos_arm64"
    "macos_x64"
)

rm -rf build/frameworks

for target in "${all_targets[@]}"; do
    build_target "$target"
done

# Remove existing XCFramework if it exists
rm -rf build/Kotlib.xcframework

# Create a combined macOS framework
echo "Combining macOS frameworks..."
FAT_MACOS_FRAMEWORK_PATH="build/frameworks/macos_arm64_x64"
mkdir -p $FAT_MACOS_FRAMEWORK_PATH
cp -R build/frameworks/macos_x64/Kotlib.framework $FAT_MACOS_FRAMEWORK_PATH
cp -R build/frameworks/macos_x64/Kotlib.framework.dSYM $FAT_MACOS_FRAMEWORK_PATH

# Create a fat binary with both macOS architectures
lipo -create \
    build/frameworks/macos_x64/Kotlib.framework/Versions/A/Kotlib \
    build/frameworks/macos_arm64/Kotlib.framework/Versions/A/Kotlib \
    -output $FAT_MACOS_FRAMEWORK_PATH/Kotlib.framework/Versions/A/Kotlib

# Create XCFramework with device and combined simulator
xcodebuild -create-xcframework \
    -framework build/frameworks/ios_arm64/Kotlib.framework \
    -framework build/frameworks/ios_simulator_arm64/Kotlib.framework \
    -framework $FAT_MACOS_FRAMEWORK_PATH/Kotlib.framework \
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
