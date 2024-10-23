#!/bin/bash

# Uncomment this to fail on the first error. This is useful to debug the script.
# However, it is not recommended for production.
# set -e

sudo git config core.fileMode false
git config --global --add safe.directory /__w/komodo-defi-framework/komodo-defi-framework
sudo chmod -R u+rwx /home/komodo/workspace
sudo chown -R komodo:komodo /home/komodo/workspace

mkdir -p android/app/src/main/cpp/libs/armeabi-v7a 
mkdir -p android/app/src/main/cpp/libs/arm64-v8a 
mkdir -p web/src/mm2

rustup default stable 
cargo install wasm-pack
rustup default nightly-2023-06-01

cd /kdf 
export PATH="$HOME/.cargo/bin:$PATH" 
export PATH=$PATH:/android-ndk/bin
CC_aarch64_linux_android=aarch64-linux-android21-clang CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER=aarch64-linux-android21-clang cargo rustc --target=aarch64-linux-android --lib --release --crate-type=staticlib --package mm2_bin_lib
CC_armv7_linux_androideabi=armv7a-linux-androideabi21-clang CARGO_TARGET_ARMV7_LINUX_ANDROIDEABI_LINKER=armv7a-linux-androideabi21-clang cargo rustc --target=armv7-linux-androideabi --lib --release --crate-type=staticlib --package mm2_bin_lib
wasm-pack build --release mm2src/mm2_bin_lib --target web --out-dir ../../target/target-wasm-release

mv /kdf/target/aarch64-linux-android/release/libkdflib.a /home/komodo/workspace/android/app/src/main/cpp/libs/arm64-v8a/libmm2.a
mv /kdf/target/armv7-linux-androideabi/release/libkdflib.a /home/komodo/workspace/android/app/src/main/cpp/libs/armeabi-v7a/libmm2.a
rm -rf /home/komodo/workspace/web/src/mm2/
cp -R /kdf/target/target-wasm-release/ /home/komodo/workspace/web/src/mm2/

cd /home/komodo/workspace
flutter pub get
npm i && npm run build