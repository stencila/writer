#!/usr/bin/env bash

#
# Integrate Stencila Extension:
# -----------------------------
# This script clones and installs the stencila/vscode extension into the code
# base from the stencila repo. It performs the following tasks:
#
# 1. Clone the stencila/stencila repo
# 2. Move the vscode folder from the repo into the extensions directory
# 3. Installs the rewuires npm packages
# 4. Compiles the extension
# 5. Removes the cloned repo
#
# NOTE: It is assumed that the git user running this command has access to the
# stencila/stencila repo.
#
# This extension is referenced in product.json. Remove from there if you'd like
# to disable this extension.

set -e

EXTENSION_REPO=git@github.com:stencila/stencila.git
EXTENSION_REPO_NAME=stencila
EXTENSION_REPO_FOLDER_NAME=vscode
EXTENSION_PATH=extensions/stencila-editor

if [[ "$OSTYPE" == "darwin"* ]]; then
	realpath() { [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"; }
	ROOT=$(dirname "$(dirname "$(realpath "$0")")")
else
	ROOT=$(dirname "$(dirname "$(readlink -f $0)")")
fi

# cleanup existing extension
rm -rf ${EXTENSION_PATH}

# clone stencila repo
git clone ${EXTENSION_REPO} ${EXTENSION_REPO_NAME}
# move stencila vscode directory to extensions
mv ${EXTENSION_REPO_NAME}/${EXTENSION_REPO_FOLDER_NAME} ${EXTENSION_PATH}

# compile extension
npm --prefix ${EXTENSION_PATH} i && npm --prefix ${EXTENSION_PATH} run compile

exit 0
