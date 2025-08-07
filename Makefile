KOTLIN_NATIVE_BIN := kotlinc-native
BUILD_DIR := ./build
SRC_DIRS := ./src
SRC_FILES := $(shell find $(SRC_DIRS) -name '*.kt')

FRAMEWORK_NAME := Kotlib.framework
XCFRAMEWORK_NAME := Kotlib.xcframework
XCFRAMEWORK_OUTPUT_PATH := $(BUILD_DIR)/$(XCFRAMEWORK_NAME)

arch_path = $(BUILD_DIR)/frameworks/$(strip $1)
framework_arch_path = $(call arch_path, $1)/$(FRAMEWORK_NAME)

PACKAGE_SWIFT_PATH := $(BUILD_DIR)/Package.swift
FRAMEWORK_MACOS_ARM64 := $(call framework_arch_path, macos_arm64)

build_framework = $(KOTLIN_NATIVE_BIN) $(SRC_FILES) \
		-g \
		-target macos_arm64 \
		-produce framework \
		-library libs/uri-kmp-macosarm64-0.0.20.klib \
		-module-name Kotlib \
		-Xbinary=bundleId=com.kotlib.framework \
		-Xbackend-threads=0 \
		-Xexport-kdoc \
		-output $(call framework_arch_path, $1)

.PHONY: clean macos run test

all: clean macos test

$(BUILD_DIR):
	mkdir -p $@

$(PACKAGE_SWIFT_PATH): $(BUILD_DIR)
	@echo "// swift-tools-version:6.1" > $(PACKAGE_SWIFT_PATH)
	@echo "import PackageDescription" >> $(PACKAGE_SWIFT_PATH)
	@echo "let package = Package(" >> $(PACKAGE_SWIFT_PATH)
	@echo "    name: \"Kotlib\"," >> $(PACKAGE_SWIFT_PATH)
	@echo "    platforms: [.iOS(.v18), .macOS(.v15)]," >> $(PACKAGE_SWIFT_PATH)
	@echo "    products: [.library(name: \"Kotlib\", targets: [\"Kotlib\"])]," >> $(PACKAGE_SWIFT_PATH)
	@echo "    targets: [.binaryTarget(name: \"Kotlib\", path: \"Kotlib.xcframework\")]" >> $(PACKAGE_SWIFT_PATH)
	@echo ")" >> $(PACKAGE_SWIFT_PATH)

$(FRAMEWORK_MACOS_ARM64): $(BUILD_DIR) $(SRC_FILES)
	$(call build_framework, macos_arm64)

macos: $(PACKAGE_SWIFT_PATH) $(FRAMEWORK_MACOS_ARM64)
	rm -Rf $(XCFRAMEWORK_OUTPUT_PATH)
	xcodebuild -create-xcframework \
		-framework $(call framework_arch_path, macos_arm64) \
		-output $(XCFRAMEWORK_OUTPUT_PATH)

clean:
	rm -rf $(BUILD_DIR)

run:
	swift run --package-path Swift

test:
	swift test --package-path Swift
