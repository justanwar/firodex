# Build Release version of the App

### Environment setup

Before building the app, make sure you have all the necessary tools installed. Follow the instructions in the [Environment Setup](./PROJECT_SETUP.md) document. Alternatively, you can use the Docker image as described here: (TODO!).

### Firebase Analytics Setup

Optionally, you can enable Firebase Analytics for the app. To do so, follow the instructions in the [Firebase Analytics Setup](./FIREBASE_SETUP.md) document.

## Build for Web

```bash
flutter build web --csp --no-web-resources-cdn
```

The release version of the app will be located in `build/web` folder. Specifying the `--release` flag is not necessary, as it is the default behavior.

## Native builds

Run `flutter build {TARGET}` command with one of the following targets:

- `apk` - builds Android APK (output to `build/app/outputs/flutter-apk` folder)
- `appbundle` - builds Android bundle (output to `build/app/outputs/bundle/release` folder)
- `ios` - builds for iOS (output to `build/ios/iphoneos` folder)
- `macos` - builds for macOS (output to `build/macos/Build/Products/Release` folder)
- `linux` - builds for Linux (output to `build/linux/x64/release/bundle` folder)
- `windows` - builds for Windows (output to `build/windows/runner/Release` folder)

Example:

```bash
flutter build apk
```

## Docker builds

### Build for Web

Update `app_build/build_config.json` with the branch/commit of `KDF` and `coins` repos to use for the build, then from the project root folder:

```bash
docker compose build && docker compose up -d
```

This will build and then launch the wallet on port 8080 (this can be changed in `docker-compose.yaml`). Build files will also be available on the host in the `output/` subfolder.


### Build for Android

```bash
sh .docker/build.sh android release
```

Alternatively, you can run the docker build commands directly:

```bash
# Build the supporting images
docker build -f .docker/kdf-android.dockerfile . -t komodo/kdf-android --build-arg KDF_BRANCH=main
docker build -f .docker/android-sdk.dockerfile . -t komodo/android-sdk:34
docker build -f .docker/komodo-wallet-android.dockerfile . -t komodo/komodo-wallet
# Build the app
mkdir -p build
docker run --rm -v ./build:/app/build komodo/komodo-wallet:latest bash -c "flutter pub get && flutter build apk --release || flutter build apk --release"
```
