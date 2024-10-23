# API module

## Current version

Current API module version is `b0fd99e` (`v2.0.0-beta`)

### Prerequisites

```bash
# Install Dart dependencies
dart pub get

# Use Node version 18
nvm use 18
```

### Usage

The script will check the `.api_last_updated_[PLATFORM_NAME]` file for every platform listed in `platforms`, and if the last updated version is different from the current API `version`, it will update the API module, `.api_last_updated_[PLATFORM_NAME]` file, and [documentation](#current-version).

By default, the script will update the API module for all supported platforms to the version specified in [build_config.json](../app_build/build_config.json).

### Configuration

In [build_config.json](../app_build/build_config.json), update the API version to the latest commit hash from the [atomicDEX-API](https://github.com/KomodoPlatform/atomicDEX-API) repository. Example:

```json
    "api": {
        "api_commit_hash": "fa74561",
        ...
    }
```

To add a new platform to the update script, add a new item to the `platforms` list in [build_config.json](../app_build/build_config.json).

```json
    "api": {
        ...
        "platforms": {
            "linux": {
                "keywords": ["linux", "x86_64"],
                "path": "linux"
            },
            ...
        }
    }
```

- `keywords` is a list of keywords that will be used to find the platform-specific API module zip file on the API CI upload server (`base_url`).
- `path` is the path to the API module directory in the project.

### Error handling

In case of errors, please check our [Project setup](PROJECT_SETUP.md) section and verify your environment.

One possible solution is to run:

```bash
npm i
```

By updating the documentation, users can now rely on the Dart-based build process for fetching and updating the API module, simplifying the workflow and removing the dependency on the Python script.
