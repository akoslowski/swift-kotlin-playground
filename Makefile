KOTLIN_NATIVE_BIN := kotlinc-native
BUILD_DIR := ./build
SRC_DIRS := ./src
SRC_FILES := $(shell find $(SRC_DIRS) -name '*.kt')
FRAMEWORK_NAME := Kotlib.framework
PACKAGE_SWIFT_PATH := $(BUILD_DIR)/Package.swift

define PACKAGE_SWIFT_CONTENT
// swift-tools-version:6.1
import PackageDescription
let package = Package(
    name: "Kotlib",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "Kotlib", targets: ["Kotlib"])],
    targets: [.binaryTarget(name: "Kotlib", path: "Kotlib.xcframework")]
)
endef

.PHONY: clean macos

arch_path = $(BUILD_DIR)/frameworks/$(strip $1)
framework_arch_path = $(BUILD_DIR)/frameworks/$(strip $1)/$(FRAMEWORK_NAME)

build_framework = $(KOTLIN_NATIVE_BIN) $(SRC_FILES) \
		-target $1 \
		-produce framework \
		-module-name Kotlib \
		-Xbinary=bundleId=com.kotlib.framework \
		-Xexport-kdoc \
		-output $(call framework_arch_path, $1)

$(BUILD_DIR):
	@mkdir -p $@

$(PACKAGE_SWIFT_PATH): $(BUILD_DIR)
	@echo "// swift-tools-version:6.1" > $(PACKAGE_SWIFT_PATH)
	@echo "import PackageDescription" >> $(PACKAGE_SWIFT_PATH)
	@echo "let package = Package(" >> $(PACKAGE_SWIFT_PATH)
	@echo "    name: \"Kotlib\"," >> $(PACKAGE_SWIFT_PATH)
	@echo "    platforms: [.iOS(.v18), .macOS(.v15)]," >> $(PACKAGE_SWIFT_PATH)
	@echo "    products: [.library(name: \"Kotlib\", targets: [\"Kotlib\"])]," >> $(PACKAGE_SWIFT_PATH)
	@echo "    targets: [.binaryTarget(name: \"Kotlib\", path: \"Kotlib.xcframework\")]" >> $(PACKAGE_SWIFT_PATH)
	@echo ")" >> $(PACKAGE_SWIFT_PATH)

macos: $(PACKAGE_SWIFT_PATH)
	$(call build_framework, macos_arm64)
	$(call build_framework, macos_x64)
	
	mkdir -p $(call arch_path, macos_arm64_x64)
	cp -R $(call framework_arch_path, macos_x64) $(call arch_path, macos_arm64_x64)
	cp -R $(call framework_arch_path, macos_x64).dSYM $(call arch_path, macos_arm64_x64)

	lipo -create \
	$(call framework_arch_path, macos_x64)/Versions/A/Kotlib \
	$(call framework_arch_path, macos_arm64)/Versions/A/Kotlib \
	-output $(call framework_arch_path, macos_arm64_x64)/Versions/A/Kotlib

	xcodebuild -create-xcframework \
		-framework $(call framework_arch_path, macos_arm64_x64) \
		-output $(BUILD_DIR)/Kotlib.xcframework

ios: $(PACKAGE_SWIFT_PATH)
	$(call build_framework, ios_arm64)
	$(call build_framework, ios_simulator_arm64)

	xcodebuild -create-xcframework \
		-framework $(call framework_arch_path, ios_arm64) \
		-framework $(call framework_arch_path, ios_simulator_arm64) \
		-output $(BUILD_DIR)/Kotlib.xcframework

universal: $(PACKAGE_SWIFT_PATH)
	$(MAKE) macos
	$(MAKE) ios
	
	rm -rf $(BUILD_DIR)/Kotlib.xcframework

	xcodebuild -create-xcframework \
		-framework $(call framework_arch_path, macos_arm64_x64) \
		-framework $(call framework_arch_path, ios_arm64) \
		-framework $(call framework_arch_path, ios_simulator_arm64) \
		-output $(BUILD_DIR)/Kotlib.xcframework

clean:
	@rm -rf $(BUILD_DIR)
