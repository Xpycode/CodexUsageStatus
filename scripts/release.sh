#!/bin/zsh
set -euo pipefail
root="${0:A:h:h}"
version="${1:?Usage: scripts/release.sh VERSION}"
output="$root/dist"
rm -rf "$output"
mkdir -p "$output"
cd "$root"
xcodegen generate
xcodebuild -project CodexUsageStatus.xcodeproj -scheme CodexUsageStatus -configuration Release -destination 'platform=macOS' -derivedDataPath "$output/DerivedData" build
ditto -c -k --sequesterRsrc --keepParent "$output/DerivedData/Build/Products/Release/CodexUsageStatus.app" "$output/CodexUsageStatus-$version.zip"
rm -rf "$output/DerivedData"
print "Created $output/CodexUsageStatus-$version.zip"
