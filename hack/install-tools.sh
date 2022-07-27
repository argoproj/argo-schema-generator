#!/bin/bash
set -eux -o pipefail

SRCROOT="$( CDPATH='' cd -- "$(dirname "$0")/.." && pwd -P )"

# This script installs all our golang-based codegen utility CLIs necessary for codegen.
# Some dependencies are vendored in go.mod (ones which are actually imported in our codebase).
# Other dependencies are only used as a CLI and do not need vendoring in go.mod (doing so adds
# unecessary dependencies to go.mod). We want to maintain a single source of truth for versioning
# our binaries (either go.mod or go install <pkg>@<version>), so we use two techniques to install
# our CLIs:
# 1. For CLIs which are NOT vendored in go.mod, we can run `go install <pkg>@<version>` with an explicit version
# 2. For packages which we *do* vendor in go.mod, we determine version from go.mod followed by `go install` with that version
go_mod_install() {
    module=$(go list -f '{{.Module}}' $1 | awk '{print $1}')
    module_version=$(go list -m $module | awk '{print $NF}' | head -1)
    go install $1@$module_version
}

# All binaries are compiled into the argo-cd/dist directory, which is added to the PATH during codegen
export GOBIN="${SRCROOT}/dist"
mkdir -p $GOBIN

# We still install openapi-gen from go.mod since upstream does not utilize release tags
go_mod_install k8s.io/kube-openapi/cmd/openapi-gen