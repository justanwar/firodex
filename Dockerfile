# Use Ubuntu base image
FROM ubuntu:22.04

LABEL Author="smk <smk@komodoplatform.com>"

ENV OVERRIDE_DEFI_API_DOWNLOAD=true

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
    zip \
    nginx && \
    apt-get clean

# Install Node.js 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean

# Install Flutter v3.22.0
RUN mkdir -p /usr/local/flutter && \
    curl -Lo flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.0-stable.tar.xz && \
    tar -xf flutter.tar.xz -C /usr/local/flutter --strip-components=1 && \
    rm flutter.tar.xz

# Add Flutter to PATH
ENV PATH="/usr/local/flutter/bin:$PATH"

# Create working directory and copy application
WORKDIR /komodo-wallet
COPY ./ /komodo-wallet

# Clean build and intermediate files
RUN git config --global --add safe.directory /usr/local/flutter
RUN rm -rf output/* build/* web/src/mm2/* web/src/kdf/* web/dist/*

# Build the Flutter app
RUN flutter pub get && \
    flutter build web --release || \
    flutter pub get && \
    flutter build web --release

# Move the Flutter build output to the NGINX web root
RUN rm -rf /var/www/html/* && \
    cp -r build/web/* /var/www/html/

# Expose NGINX default port
EXPOSE 80

# Configure NGINX
RUN echo 'server { \
    listen 80; \
    root /var/www/html; \
    index index.html; \
    server_name _; \
    location / { \
        try_files $uri /index.html; \
    } \
}' > /etc/nginx/sites-available/default

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
