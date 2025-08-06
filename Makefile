KOTLIN_NATIVE_BIN := kotlinc-native
BUILD_DIR := ./build
SRC_DIRS := ./src
SRC_FILES := $(shell find $(SRC_DIRS) -name '*.kt')

dependencies = \
  $(if $(filter macos_arm64,$(1)),libs/uri-kmp-macosarm64-0.0.20.klib, \
    $(if $(filter macos_x64,$(1)),libs/uri-kmp-macosx64-0.0.20.klib, \
      $(if $(filter ios_arm64,$(1)),libs/uri-kmp-iosarm64-0.0.20.klib, \
        $(if $(filter ios_simulator_arm64,$(1)),libs/uri-kmp-iossimulatorarm64-0.0.20.klib, \
          $(error Unknown target: $(1))))))

FRAMEWORK_NAME := Kotlib.framework
XCFRAMEWORK_NAME := Kotlib.xcframework
XCFRAMEWORK_OUTPUT_PATH := $(BUILD_DIR)/$(XCFRAMEWORK_NAME)

arch_path = $(BUILD_DIR)/frameworks/$(strip $1)
framework_arch_path = $(call arch_path, $1)/$(FRAMEWORK_NAME)

PACKAGE_SWIFT_PATH := $(BUILD_DIR)/Package.swift
FRAMEWORK_MACOS_ARM64 := $(call framework_arch_path, macos_arm64)
FRAMEWORK_MACOS_X64 := $(call framework_arch_path, macos_x64)
FRAMEWORK_MACOS_ARM64_X64 := $(call framework_arch_path, macos_arm64_x64)
FRAMEWORK_IOS_ARM64 := $(call framework_arch_path, ios_arm64)
FRAMEWORK_IOS_SIMULATOR_ARM64 := $(call framework_arch_path, ios_simulator_arm64)

build_framework = $(KOTLIN_NATIVE_BIN) $(SRC_FILES) \
		-target $(strip $1) \
		-produce framework \
		-library $(call dependencies, strip $1) \
		-module-name Kotlib \
		-Xbinary=bundleId=com.kotlib.framework \
		-Xbackend-threads=0 \
		-Xexport-kdoc \
		-output $(call framework_arch_path, $1)

.PHONY: clean macos ios universal run test

all: clean universal

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

$(FRAMEWORK_MACOS_X64): $(BUILD_DIR) $(SRC_FILES)
	$(call build_framework, macos_x64)

$(FRAMEWORK_MACOS_ARM64_X64): $(FRAMEWORK_MACOS_ARM64) $(FRAMEWORK_MACOS_X64)
	mkdir -p $(call arch_path, macos_arm64_x64)
	cp -R $(call framework_arch_path, macos_x64) $(call arch_path, macos_arm64_x64)
	cp -R $(call framework_arch_path, macos_x64).dSYM $(call arch_path, macos_arm64_x64)

	lipo -create \
	$(call framework_arch_path, macos_x64)/Versions/A/Kotlib \
	$(call framework_arch_path, macos_arm64)/Versions/A/Kotlib \
	-output $(call framework_arch_path, macos_arm64_x64)/Versions/A/Kotlib

$(FRAMEWORK_IOS_ARM64): $(BUILD_DIR) $(SRC_FILES)
	$(call build_framework, ios_arm64)

$(FRAMEWORK_IOS_SIMULATOR_ARM64): $(BUILD_DIR) $(SRC_FILES)
	$(call build_framework, ios_simulator_arm64)

macos: $(PACKAGE_SWIFT_PATH) $(FRAMEWORK_MACOS_ARM64_X64)
	rm -Rf $(XCFRAMEWORK_OUTPUT_PATH)
	xcodebuild -create-xcframework \
		-framework $(call framework_arch_path, macos_arm64_x64) \
		-output $(XCFRAMEWORK_OUTPUT_PATH)

ios: $(PACKAGE_SWIFT_PATH) $(FRAMEWORK_IOS_ARM64) $(FRAMEWORK_IOS_SIMULATOR_ARM64)
	rm -Rf $(XCFRAMEWORK_OUTPUT_PATH)
	xcodebuild -create-xcframework \
		-framework $(call framework_arch_path, ios_arm64) \
		-framework $(call framework_arch_path, ios_simulator_arm64) \
		-output $(XCFRAMEWORK_OUTPUT_PATH)

universal: $(PACKAGE_SWIFT_PATH) $(FRAMEWORK_MACOS_ARM64_X64) $(FRAMEWORK_IOS_ARM64) $(FRAMEWORK_IOS_SIMULATOR_ARM64)
	rm -Rf $(XCFRAMEWORK_OUTPUT_PATH)
	xcodebuild -create-xcframework \
		-framework $(call framework_arch_path, macos_arm64_x64) \
		-framework $(call framework_arch_path, ios_arm64) \
		-framework $(call framework_arch_path, ios_simulator_arm64) \
		-output $(XCFRAMEWORK_OUTPUT_PATH)

clean:
	rm -rf $(BUILD_DIR)

run:
	swift run --package-path Swift

test:
	swift test --package-path Swift
