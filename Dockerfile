# syntax=docker/dockerfile:1

# Build Stencila Writer
# See https://github.com/microsoft/vscode/wiki/How-to-Contribute for more
FROM jetify/sandbox:latest AS build

# Install dependencies for building VS Code.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked <<EOF
#!/bin/sh

set -e

rm -f /etc/apt/apt.conf.d/docker-clean
echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

apt-get update
apt-get upgrade -y

# Package list from https://github.com/microsoft/vscode/wiki/How-to-Contribute
apt-get --no-install-recommends install -y build-essential g++ libx11-dev libxkbfile-dev libsecret-1-dev libkrb5-dev python-is-python3
EOF

# Copy local dir into image
COPY . /root/writer
WORKDIR /root/writer

# Install Node.js dependencies
RUN yarn

# Build the "reh-web" server where the editor runs in the browser and extensions
# run on the server. reh = remote extension host
#
# DISABLE_V8_COMPILE_CACHE=1 is a workaround for a known issues with yarn v1
# where it'll randomly segfault.
RUN DISABLE_V8_COMPILE_CACHE=1 yarn gulp vscode-reh-web-linux-x64-min

# Build the server image
FROM jetify/sandbox:latest

# Delete the default editor and replace it with Stencila Writer.
RUN rm -rf /opt/code-oss
COPY --link --from=build /root/vscode-reh-web-linux-x64 /opt/code-oss

# Copy in the Stencila CLI (used by the extension)
COPY ./stencila /opt/stencila

# Rename the directory and binaries back to codeoss-cloudworkstations to keep it
# compatible with the other scripts in the base image.
RUN mv /opt/code-oss/bin/stencila-server-oss /opt/code-oss/bin/codeoss-cloudworkstations
RUN mv /opt/code-oss/bin/remote-cli/stencila /opt/code-oss/bin/remote-cli/code-oss-cloud-workstations

# Patch the command to start the server so it doesn't use its own auth token in the URL.
RUN sed -i -e '/runuser.*codeoss-cloudworkstations/ s/"$/ --without-connection-token"/' /etc/workstation-startup.d/110_start-code-oss.sh
