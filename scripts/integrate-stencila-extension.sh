#!/usr/bin/env bash

set -e

EXTENSION_REPO=git@github.com:stencila/vscode-extension.git
EXTENSION_PATH=extensions/stencila-editor

if [[ "$OSTYPE" == "darwin"* ]]; then
	realpath() { [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"; }
	ROOT=$(dirname "$(dirname "$(realpath "$0")")")
else
	ROOT=$(dirname "$(dirname "$(readlink -f $0)")")
fi

# clone extension
rm -rf ${EXTENSION_PATH} && git clone ${EXTENSION_REPO} ${EXTENSION_PATH}

# compile extension
npm --prefix ${EXTENSION_PATH} i && npm --prefix ${EXTENSION_PATH} run compile

exit 0
