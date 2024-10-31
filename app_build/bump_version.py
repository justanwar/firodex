import platform
import shutil
import sys
import re
import os
import subprocess

script_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(script_dir)


def has_deprecated_asset_path(content, current_version_string, new_version_string):
    return content.count(
        f"assets/{current_version_string}") > 0 or content.count(f"assets/{new_version_string}") > 0


# Deprecated. Only kept for backwards compatibility and validation.
def update_docs(current_version_string, new_version_string):
    config_file_path = os.path.join(parent_dir, "docs", "COINS_CONFIG.md")

    with open(config_file_path, "r") as f:
        content = f.read()

    if has_deprecated_asset_path(content, current_version_string, new_version_string):
        print("The docs contain the deprecated asset path. Please update the asset path to the new structure.")
        sys.exit(1)


def main(new_version):
    # Check if the flutter command is available
    flutter_executable = "flutter" if platform.system() != "Windows" else "flutter.bat"
    flutter_path = shutil.which(flutter_executable)
    if not flutter_path:
        print("The flutter command is not found in the system's PATH. Please check the Flutter installation.")
        sys.exit(1)

    npm_executable = "npm"
    if platform.system() == "Windows":
        npm_executable = "npm.cmd"

    print(f"Updating JS files...")
    print("Running 'npm i'...")
    result = subprocess.run([npm_executable, "i"],
                            capture_output=True, text=True)

    if result.returncode == 0:
        print("Done.")
    else:
        print("npm i failed. Please make sure you are using nodejs 18, e.g. `nvm use 18`.")
        print(result.stderr)
        sys.exit(1)

    print("Running 'npm run build'...")
    result = subprocess.run(
        [npm_executable, "run", "build"], capture_output=True, text=True)

    if result.returncode == 0:
        print("Done.")
    else:
        print("npm run build failed. Please make sure you are using nodejs 18, e.g. `nvm use 18`.")
        print(result.stderr)
        sys.exit(1)

    print("JS files updated successfully.")

    with open(f"{parent_dir}/pubspec.yaml", "r") as f:
        content = f.read()

    new_version_string = new_version.replace(".", "")
    current_version = re.search(r"version:\s*([\d.]+)", content).group(1)
    current_version_string = current_version.replace(".", "")
    print(f"Updating app version to {new_version} from {current_version}...")

    print("Validating & updating pubspec.yaml...")

    if has_deprecated_asset_path(content, current_version_string, new_version_string):
        print("The pubspec.yaml file contains the deprecated asset path.")
        sys.exit(1)

    content = content.replace(current_version_string, new_version_string)
    content = content.replace(current_version, new_version)
    print("Done.")

    print("Validating & updating docs...")
    update_docs(current_version_string, new_version_string)
    print("Done.")

    print("Validating assets folder...")
    assets_folder = os.path.join(parent_dir, "assets")
    if not os.path.exists(assets_folder):
        print("The assets folder does not exist.")
        sys.exit(1)

    if os.path.exists(os.path.join(assets_folder, new_version_string)) or os.path.exists(os.path.join(assets_folder, current_version_string)):
        print("The assets folder contains the deprecated asset folder strategy.")
        sys.exit(1)
    print("Done.")

    print("Running `flutter pub get`...")

    result = subprocess.run([flutter_path, "pub", "get"],
                            capture_output=True, text=True)

    if result.returncode == 0:
        print(result.stdout)
        print("Done.")
    else:
        print(result.stderr)
        print("`flutter pub get` failed.")
        sys.exit(1)

    with open(f"{parent_dir}/pubspec.yaml", "w") as f:
        f.write(content)

    print("Running 'flutter build web --pwa-strategy=none'...")
    result = subprocess.run([flutter_path, "build", "web",
                            "--pwa-strategy=none"], capture_output=True, text=True)

    if result.returncode == 0:
        print(result.stdout)
        print("Build successful.")
    else:
        print("Build failed.")
        print(result.stderr)
        sys.exit(1)

    print("\033[32mThe app version has been updated successfully, new version is {}\033[0m".format(
        new_version))


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Please provide the new version number as an argument.")
        print("Example: python bump_version.py 1.0.1")
        sys.exit(1)

    new_version = sys.argv[1]
    main(new_version)
