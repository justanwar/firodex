#!/usr/bin/env python3
import sys
import shutil
import platform
import subprocess
from update_api import UpdateAPI


def main():
    # Check if the flutter command is available
    flutter_executable = "flutter" if platform.system() != "Windows" else "flutter.bat"
    flutter_path = shutil.which(flutter_executable)
    if not flutter_path:
        print("The flutter command is not found in the system's PATH. Please check the Flutter installation.")
        sys.exit(1)

    print("Running pre-build routine...")

    # Execute 'flutter clean' and 'flutter pub get' before 'flutter build'
    pre_build_commands = [
        [flutter_path, "clean"],
        [flutter_path, "doctor"],
        [flutter_path, "pub", "get"],
        [flutter_path, "analyze"]
    ]

    for command in pre_build_commands:
        try:
            print(f"Executing {' '.join(command)}...")
            subprocess.run(command, check=True)
        except subprocess.CalledProcessError as e:
            print(f"Command {' '.join(command)} failed with error: {e}")
            sys.exit(1)

    # Run the flutter command
    try:
        args = sys.argv[1:]
        print(f"Executing 'flutter build' with passed arguments...{args}")
        subprocess.run([flutter_path, "build"] + args, check=True)
    except subprocess.CalledProcessError as e:
        print(f"'flutter build' failed with error: {e}")
        sys.exit(1)

    # Add any post-run custom logic here
    if build_platform == "linux":
        try:
            print("Copying Linux icon and desktop file...")
            shutil.copy("linux/KomodoWallet.svg", "build/linux/x64/release/bundle")
            shutil.copy("linux/KomodoWallet.desktop", "build/linux/x64/release/bundle")
            print("Copied Linux icon and desktop file.")
        except IOError as e:
            print(f"Failed to copy files with error: {e}")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    platforms = ["apk", "appbundle", "ios", "macos", "linux", "windows", "web"]
    if len(sys.argv) > 1:
        try:
            build_platform = list(set(sys.argv) & set(platforms))
            if not build_platform:
                print("Please specify the platform for which to build.")
                print(f"Options: {platforms}")
                sys.exit(1)
            else:
                build_platform = build_platform[0]
                
            updateAPI = UpdateAPI(force=True)
            if build_platform == "apk" or build_platform == "appbundle":
                updateAPI.platform = 'android-armv7'
                updateAPI.update_api()
                updateAPI.platform = 'android-aarch64'
                updateAPI.update_api()
            else:
                updateAPI.platform = build_platform
                updateAPI.update_api()

        except Exception as e:
            print(f"Error: {e}")

        main()
    else:
        print("Please specify the platform for which to build.")
        print(f"Options: {platforms}")
