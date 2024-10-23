# Build Configuration Guide

## TL;DR

- **Configure API**: Ensure your `build_config.json` includes the correct API commit hash, update flags, source URLs, and platform-specific paths and targets.
- **Configure Coins**: Set up the coins repository details, including commit hashes, URLs, branches, and runtime update settings.
- **Run Build Process**: The build steps are automatically executed as part of Flutter's build process. Ensure Node.js 18 is installed.

---

## `build_config.json` Structure

### Top-Level Keys

- `api`: Configuration related to the DeFi API updates and supported platforms.
- `coins`: Configuration related to coin assets and updates.

### Example Configuration

```json
{
    "api": {
        "api_commit_hash": "b0fd99e8406e67ea06435dd028991caa5f522b5c",
        "branch": "main",
        "fetch_at_build_enabled": true,
        "source_urls": [
            "https://api.github.com/repos/KomodoPlatform/komodo-defi-framework",
            "https://sdk.devbuilds.komodo.earth"
        ],
        "platforms": {
            "web": {
                "matching_keyword": "wasm",
                "valid_zip_sha256_checksums": [
                    "f4065f8cbfe2eb2c9671444402b79e1f94df61987b0cee6d503de567a2bc3ff0"
                ],
                "path": "web/src/mm2"
            },
            "ios": {
                "matching_keyword": "ios-aarch64",
                "valid_zip_sha256_checksums": [
                    "17156647a0bac0e630a33f9bdbcfd59c847443c9e88157835fff6a17738dcf0c"
                ],
                "path": "ios"
            },
            "macos": {
                "matching_keyword": "Darwin-Release",
                "valid_zip_sha256_checksums": [
                    "9472c37ae729bc634b02b64a13676e675b4ab1629d8e7c334bfb1c0360b6000a"
                ],
                "path": "macos"
            },
            "windows": {
                "matching_keyword": "Win64",
                "valid_zip_sha256_checksums": [
                    "f65075f3a04d27605d9ce7282ff6c8d5ed84692850fbc08de14ee41d036c4c5a"
                ],
                "path": "windows/runner/exe"
            },
            "android-armv7": {
                "matching_keyword": "android-armv7",
                "valid_zip_sha256_checksums": [
                    "bae9c33dca4fae3b9d10d25323df16b6f3976565aa242e5324e8f2643097b4c6"
                ],
                "path": "android/app/src/main/cpp/libs/armeabi-v7a"
            },
            "android-aarch64": {
                "matching_keyword": "android-aarch64",
                "valid_zip_sha256_checksums": [
                    "435c857c5cd4fe929238f490d2d3ba58c84cf9c601139c5cd23f63fbeb5befb6"
                ],
                "path": "android/app/src/main/cpp/libs/arm64-v8a"
            },
            "linux": {
                "matching_keyword": "Linux-Release",
                "valid_zip_sha256_checksums": [
                    "16f35c201e22db182ddc16ba9d356d324538d9f792d565833977bcbf870feaec"
                ],
                "path": "linux/mm2"
            }
        }
    },
    "coins": {
        "update_commit_on_build": true,
        "bundled_coins_repo_commit": "6c33675ce5e5ec6a95708eb6046304ac4a5c3e70",
        "coins_repo_api_url": "https://api.github.com/repos/KomodoPlatform/coins",
        "coins_repo_content_url": "https://raw.githubusercontent.com/KomodoPlatform/coins",
        "coins_repo_branch": "master",
        "runtime_updates_enabled": true,
        "mapped_files": {
            "assets/config/coins_config.json": "utils/coins_config_unfiltered.json",
            "assets/config/coins.json": "coins"
        },
        "mapped_folders": {
            "assets/coin_icons/png/": "icons"
        }
    }
}
```

---

## `api` Configuration

### Parameters and Explanation

- **api_commit_hash**: Specifies the commit hash of the API version currently in use. This ensures the API is pulled from a specific commit in the repository, providing consistency and stability by locking to a known state.
#### Platform Configuration

Each platform configuration contains:

---

## `coins` Configuration

### Parameters and Explanation

- **update_commit_on_build**: A boolean flag indicating whether the commit hash should be updated on build. This ensures the coin configurations are in sync with the latest state of the repository.
- **bundled_coins_repo_commit**: Specifies the commit hash of the bundled coins repository. This ensures the coin configurations are in sync with a specific state of the repository, providing consistency and stability.
---

## Configuring and Running the Build Process

1. **Modify `build_config.json`**: Ensure the configuration file reflects your project requirements. Update commit hashes, URLs, and paths as needed.
The build steps are automatically executed as part of Flutter's build process. For any issues or further assistance, refer to the detailed comments within the build scripts or seek support from the project maintainers.
