#!/bin/bash

# Patch Package.swift for a release: module name, version and checksum of the
# binary asset. The manifest is what gets zipped and PUT into the JFrog Swift
# registry afterwards, e.g.
#
#   zip Package.zip Package.swift
#   curl -f -X PUT --user "$JFROG_USER:$JFROG_PASSWORD" \
#        -H "Accept: application/vnd.swift.registry.v1+json" \
#        -F source-archive="@Package.zip" \
#        https://dxfeed.jfrog.io/artifactory/api/swift/spm-open/spm/dxfeedframework/$SHORT_VERSION
#
# Usage: ./release_sp.sh <version> <framework-name>
#   <version>         registry version and GitHub release tag, e.g. 1.6.0
#   <framework-name>  module/zip name without extension, e.g. DXFeedFramework
#
# The binaryTarget URL the manifest ends up with:
#   https://github.com/dxFeed/dxfeed-graal-swift-api/releases/download/<version>/<framework-name>.zip

set -euo pipefail

# Check for arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <version> <framework-name>" >&2
    echo "  e.g. $0 1.6.0 DXFeedFramework" >&2
    exit 1
fi

# 1. Get params
NEW_VERSION=$1
FRAMEWORK_NAME=$2
ARCHIVE="build/${FRAMEWORK_NAME}.zip"

if [ ! -f "$ARCHIVE" ]; then
    echo "Archive not found: $ARCHIVE" >&2
    exit 1
fi

# 2. Calculate checksum and store it
echo "calculate new checksum"
NEW_CHECKSUM=$(swift package compute-checksum "$ARCHIVE")
echo "print out new shasum for convenience reasons"
echo "New checksum is $NEW_CHECKSUM"

# 3. Replace all data from Package.swift manifest
echo "replace name module information in package manifest"
sed -E -i '' "s/let moduleName = \".+\"/let moduleName = \"$FRAMEWORK_NAME\"/" Package.swift
echo "replace version information in package manifest"
sed -E -i '' "s/let version = \".+\"/let version = \"$NEW_VERSION\"/" Package.swift
echo "replace checksum information in package manifest"
sed -E -i '' "s/let checksum = \".+\"/let checksum = \"$NEW_CHECKSUM\"/" Package.swift

# 4. Fail loudly instead of publishing a manifest a sed silently missed
for expected in "let moduleName = \"$FRAMEWORK_NAME\"" \
                "let version = \"$NEW_VERSION\"" \
                "let checksum = \"$NEW_CHECKSUM\""; do
    if ! grep -qF "$expected" Package.swift; then
        echo "Package.swift was not patched, expected line missing: $expected" >&2
        exit 1
    fi
done

# 5. Print new content of manifest
echo "print out package manifest for convenience reasons"
cat Package.swift
echo "binary target url:"
echo "https://github.com/dxFeed/dxfeed-graal-swift-api/releases/download/$NEW_VERSION/$FRAMEWORK_NAME.zip"
