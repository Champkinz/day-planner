# Releasing DayPlanner

## Quick Release

1. Update `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in `DayPlanner.xcodeproj/project.pbxproj` (both Debug and Release configs)
2. Commit and push
3. Tag and push:

```bash
git tag v1.X.0
git push origin v1.X.0
```

CI handles the rest: build, Sparkle EdDSA signing, appcast update, and GitHub Release creation.

## What CI Does

1. Builds the app (`CODE_SIGN_IDENTITY="-"`, ad-hoc signed)
2. Zips the `.app` bundle
3. Signs the zip with the Sparkle EdDSA private key (stored as `SPARKLE_PRIVATE_KEY` GitHub secret)
4. Updates `appcast.xml` and commits it to `main`
5. Creates a GitHub Release with the signed zip attached

## Version Numbers

- `MARKETING_VERSION` — user-facing version (e.g. `1.6.0`), maps to `CFBundleShortVersionString`
- `CURRENT_PROJECT_VERSION` — internal build number (e.g. `7`), maps to `CFBundleVersion`. Sparkle uses this to compare versions. Must increase with each release.

## Sparkle Keys

- **Public key** is in `DayPlanner/Resources/Info.plist` (`SUPublicEDKey`)
- **Private key** is stored in your macOS Keychain and as a GitHub secret (`SPARKLE_PRIVATE_KEY`)
- To export the private key again: `generate_keys -x /path/to/output.txt`
- To regenerate keys: `generate_keys` (you'll need to update both `Info.plist` and the GitHub secret)

## Manual Release (if CI is unavailable)

```bash
# Build
xcodebuild -scheme DayPlanner -configuration Release -derivedDataPath /tmp/build CODE_SIGN_IDENTITY="-" build

# Zip
ditto -c -k --keepParent /tmp/build/Build/Products/Release/DayPlanner.app /tmp/DayPlanner.zip

# Sign (outputs edSignature and length)
sign_update /tmp/DayPlanner.zip

# Update appcast.xml with the signature and length
# Create GitHub Release and upload zip
gh release create vX.Y.Z /tmp/DayPlanner.zip --title "DayPlanner vX.Y.Z" --notes "Release notes"
```
