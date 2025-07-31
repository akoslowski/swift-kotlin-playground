#!/bin/bash

# Simple script to build Kotlin/Native iOS frameworks and create XCFramework

set -e

echo "Building Kotlin code for iOS targets..."

KOTLIN_NATIVE_BIN="kotlinc-native"



# Create output directories
mkdir -p build/frameworks/iosArm64
mkdir -p build/frameworks/iosX64  
mkdir -p build/frameworks/iosSimulatorArm64
mkdir -p build/frameworks/macosArm64
mkdir -p build/frameworks/macosX64

# Build for iOS arm64 (device)
echo "Building for iOS arm64..."
$KOTLIN_NATIVE_BIN src/commonMain/kotlin/Kotlib.kt \
    -target ios_arm64 \
    -produce framework \
    -module-name Kotlib \
    -Xbinary=bundleId=com.kotlib.framework \
    -Xexport-kdoc \
    -output build/frameworks/iosArm64/Kotlib

# Build for iOS x64 (simulator)
echo "Building for iOS x64 simulator..."
$KOTLIN_NATIVE_BIN src/commonMain/kotlin/Kotlib.kt \
    -target ios_x64 \
    -produce framework \
    -module-name Kotlib \
    -Xbinary=bundleId=com.kotlib.framework \
    -Xexport-kdoc \
    -output build/frameworks/iosX64/Kotlib

# Build for iOS simulator arm64 (M1 simulator)
echo "Building for iOS simulator arm64..."
$KOTLIN_NATIVE_BIN src/commonMain/kotlin/Kotlib.kt \
    -target ios_simulator_arm64 \
    -produce framework \
    -module-name Kotlib \
    -Xbinary=bundleId=com.kotlib.framework \
    -Xexport-kdoc \
    -output build/frameworks/iosSimulatorArm64/Kotlib

# Build for macOS arm64 (Apple Silicon)
echo "Building for macOS arm64..."
$KOTLIN_NATIVE_BIN src/commonMain/kotlin/Kotlib.kt \
    -target macos_arm64 \
    -produce framework \
    -module-name Kotlib \
    -Xbinary=bundleId=com.kotlib.framework \
    -Xexport-kdoc \
    -output build/frameworks/macosArm64/Kotlib

# Build for macOS x64 (Intel)
echo "Building for macOS x64..."
$KOTLIN_NATIVE_BIN src/commonMain/kotlin/Kotlib.kt \
    -target macos_x64 \
    -produce framework \
    -module-name Kotlib \
    -Xbinary=bundleId=com.kotlib.framework \
    -Xexport-kdoc \
    -output build/frameworks/macosX64/Kotlib

echo "Creating XCFramework..."

# Remove existing XCFramework if it exists
rm -rf build/Kotlib.xcframework

# Create a combined simulator framework
echo "Combining simulator frameworks..."
mkdir -p build/frameworks/iosSimulator
cp -R build/frameworks/iosX64/Kotlib.framework build/frameworks/iosSimulator/
cp -R build/frameworks/iosX64/Kotlib.framework.dSYM build/frameworks/iosSimulator/

# Create a fat binary with both simulator architectures
lipo -create \
    build/frameworks/iosX64/Kotlib.framework/Kotlib \
    build/frameworks/iosSimulatorArm64/Kotlib.framework/Kotlib \
    -output build/frameworks/iosSimulator/Kotlib.framework/Kotlib

# Create a combined macOS framework
echo "Combining macOS frameworks..."
mkdir -p build/frameworks/macos
cp -R build/frameworks/macosX64/Kotlib.framework build/frameworks/macos/
cp -R build/frameworks/macosX64/Kotlib.framework.dSYM build/frameworks/macos/

# Create a fat binary with both macOS architectures
lipo -create \
    build/frameworks/macosX64/Kotlib.framework/Versions/A/Kotlib \
    build/frameworks/macosArm64/Kotlib.framework/Versions/A/Kotlib \
    -output build/frameworks/macos/Kotlib.framework/Versions/A/Kotlib

# Ensure the main binary symlink exists for macOS framework
MACOS_FRAMEWORK="build/frameworks/macos/Kotlib.framework"
if [ ! -L "$MACOS_FRAMEWORK/Kotlib" ]; then
    ln -sfh "Versions/Current/Kotlib" "$MACOS_FRAMEWORK/Kotlib"
fi

# Create XCFramework with device and combined simulator
xcodebuild -create-xcframework \
    -framework build/frameworks/iosArm64/Kotlib.framework \
    -framework build/frameworks/iosSimulator/Kotlib.framework \
    -framework build/frameworks/macos/Kotlib.framework \
    -output build/Kotlib.xcframework

echo "Creating Package.swift for Swift Package Manager..."

# Create Package.swift in build directory
cat > build/Package.swift << EOF
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Kotlib",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "Kotlib",
            targets: ["Kotlib"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "Kotlib",
            path: "Kotlib.xcframework"
        ),
    ]
)
EOF

echo "✅ XCFramework created successfully at: build/Kotlib.xcframework"
echo "✅ Package.swift created for Swift Package Manager at: build/Package.swift"
