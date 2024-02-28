#!/bin/bash

# Check if rustup is installed
if ! command -v rustup &> /dev/null
then
    echo "rustup could not be found. Please install it using:"
    echo "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

# Adding rustup targets
rustup target add aarch64-apple-ios
rustup target add aarch64-apple-ios-sim
rustup target add x86_64-apple-ios

# Comment a specific line in build_ffi.sh
sed -i '' 's/export CFLAGS="-flto=full ${CFLAGS:-}"/#&/' build_ffi.sh
if [ $? -ne 0 ]; then
    echo "Failed to modify build_ffi.sh."
    exit 1
fi

# Build all the targets
CARGO_BUILD_TARGET=aarch64-apple-ios ./build_ffi.sh --release
CARGO_BUILD_TARGET=aarch64-apple-ios-sim ./build_ffi.sh --release
CARGO_BUILD_TARGET=x86_64-apple-ios ./build_ffi.sh --release

echo "Merging iOS Simulator libraries"

mkdir -p ../target/iOS-simulator

lipo -create \
	"../target/x86_64-apple-ios/release/libsignal_ffi.a" \
	"../target/aarch64-apple-ios-sim/release/libsignal_ffi.a" \
	-output "../target/iOS-simulator/libsignal_simulator_ffi.a"

# Create the XCFramework
echo "Creating XCFramework"

rm -fr ../target/artifacts
mkdir -p ../target/artifacts

xcodebuild -create-xcframework \
    -library "../target/aarch64-apple-ios/release/libsignal_ffi.a" \
    -headers "./Sources/SignalFfi/" \
    -library "../target/iOS-simulator/libsignal_simulator_ffi.a" \
    -headers "./Sources/SignalFfi/" \
    -output "../target/artifacts/SignalFfi.xcframework"

if [ $? -ne 0 ]; then
    echo "Failed to create XCFramework."
    exit 1
fi

echo "Zipping artifacts"
zip -r ../target/artifacts/SignalFfi.xcframework.zip ../target/artifacts/SignalFfi.xcframework

echo "Creating checksum file from generated xcframework"
shasum -a 256 ../target/artifacts/SignalFfi.xcframework.zip > ../target/artifacts/SignalFfi.xcframework.zip.sha256

echo "Process completed successfully."