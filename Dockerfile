FROM ubuntu:22.04

LABEL Author="smk <smk@komodoplatform.com>"

# Install required dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    openjdk-11-jdk \
    chromium-browser \
    clang cmake ninja-build pkg-config \
    curl \
    wget \
    git \
    unzip \
    xz-utils \
    zip && \
    apt-get clean

# Install Node.js 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean

# Install Android SDK
RUN mkdir -p /usr/lib/android-sdk/cmdline-tools/latest && \
    curl -o android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-9123335_latest.zip && \
    unzip -o android-sdk.zip -d /usr/lib/android-sdk/cmdline-tools && \
    rm android-sdk.zip && \
    mv /usr/lib/android-sdk/cmdline-tools/cmdline-tools/* /usr/lib/android-sdk/cmdline-tools/latest && \
    rmdir /usr/lib/android-sdk/cmdline-tools/cmdline-tools && \
    yes | /usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses && \
    /usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2"


# Install Flutter v3.22.0
RUN mkdir -p /usr/local/flutter && \
    curl -Lo flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.0-stable.tar.xz && \
    tar -xf flutter.tar.xz -C /usr/local/flutter --strip-components=1 && \
    rm flutter.tar.xz

# Add Flutter to PATH
ENV PATH="/usr/local/flutter/bin:$PATH"

RUN flutter config --android-sdk /usr/lib/android-sdk
# Verify Flutter installation and enable Android support
RUN flutter doctor --android-licenses && \
    flutter doctor 


WORKDIR /komodo-wallet
COPY ./ /komodo-wallet

RUN git config --global --add safe.directory /usr/local/flutter

RUN rm -rf build/* web/src/mm2/* web/src/kdf/* web/dist/*

CMD ["bash"]

