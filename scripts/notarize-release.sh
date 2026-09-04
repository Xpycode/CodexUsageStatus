#!/bin/zsh
set -euo pipefail

version="${1:?Usage: scripts/notarize-release.sh VERSION}"
root="${0:A:h:h}"
auth_dir="${AUTH_DIR:-/Users/sim/ProgrammingProjects/99-AUTH}"
identity="${SIGN_ID:-D3002F5085B4512CAE0CC1A6DF30FAF717D83B62}"
key="${NOTARY_KEY:-${auth_dir}/AuthKey_6HTCUZ9L7L.p8}"
issuer="${NOTARY_ISSUER:-$(grep -oiE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' "${auth_dir}/IssuerID.rtf" | head -1)}"
key_id="$(basename "$key" .p8 | sed 's/^AuthKey_//')"
out="$root/dist"
derived="$out/DerivedData"
app="$derived/Build/Products/Release/CodexUsageStatus.app"
zip="$out/CodexUsageStatus-${version}.zip"

[[ -f "$key" && -n "$issuer" ]] || { print -u2 'Missing notarization API-key credentials.'; exit 1; }
rm -rf "$out"
mkdir -p "$out"
cd "$root"
xcodegen generate
xcodebuild -project CodexUsageStatus.xcodeproj -scheme CodexUsageStatus -configuration Release -destination 'platform=macOS' -derivedDataPath "$derived" build
codesign --force --options runtime --timestamp --sign "$identity" "$app"
codesign --verify --strict --verbose=2 "$app"
ditto -c -k --keepParent "$app" "$zip"
xcrun notarytool submit "$zip" --key "$key" --key-id "$key_id" --issuer "$issuer" --wait
xcrun stapler staple "$app"
ditto -c -k --keepParent "$app" "$zip"
spctl -a -vvv -t exec "$app"
rm -rf "$derived"
print "Notarized release: $zip"
