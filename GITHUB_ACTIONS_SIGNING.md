# GitHub Actions Android App Signing Guide

## Overview

This document explains how to set up and use GitHub Actions secrets for signing your Android app. The workflow has been configured to use these secrets to sign the APK during the build process.

## Required Secrets

You have already added the following secrets to your GitHub repository:

1. `KEYSTORE_BASE64`: The base64-encoded keystore file
2. `KEYSTORE_PASSWORD`: The password for the keystore
3. `KEY_ALIAS`: The alias of the key in the keystore
4. `KEY_PASSWORD`: The password for the key

## How the Workflow Uses These Secrets

In the GitHub workflow file (`.github/workflows/release-github.yml`), these secrets are used as follows:

1. The `KEYSTORE_BASE64` secret is decoded and saved as a file at `android/app/upload-keystore.jks`
2. The other secrets are passed as environment variables to the Flutter build command

```yaml
- name: Decode Keystore
  run: |
    echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/upload-keystore.jks
    # Verify the keystore file was created
    ls -la android/app/upload-keystore.jks
    # Set permissions
    chmod 644 android/app/upload-keystore.jks
  shell: bash

- name: Build Release APK
  env:
    KEYSTORE_FILE: android/app/upload-keystore.jks
    KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
    KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
    KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
  run: flutter build apk --release
```

## Troubleshooting

### Common Issues

1. **Keystore file not found**: If the workflow fails with an error about the keystore file not being found, check:
   - The `KEYSTORE_BASE64` secret is correctly set
   - The base64 encoding is valid (no extra newlines or spaces)
   - The path in the workflow matches the path in the `build.gradle` file

2. **Invalid keystore format**: If the keystore file is created but the build fails with an error about an invalid keystore, check:
   - The base64 encoding was done correctly
   - The original keystore file is valid

3. **Wrong passwords or alias**: If the build fails with an error about wrong passwords or alias, verify:
   - The `KEYSTORE_PASSWORD`, `KEY_ALIAS`, and `KEY_PASSWORD` secrets match the values used when creating the keystore

### Testing Locally

To verify your keystore and secrets locally:

1. Decode the base64 keystore using the provided script:
   ```
   ./android/app/decode_keystore.bat  # Windows
   ./android/app/decode_keystore.sh   # Linux/Mac
   ```

2. Build the app locally with the same environment variables:
   ```
   set KEYSTORE_FILE=android/app/upload-keystore.jks
   set KEYSTORE_PASSWORD=your_keystore_password
   set KEY_ALIAS=your_key_alias
   set KEY_PASSWORD=your_key_password
   flutter build apk --release
   ```

## Generating a Base64 Keystore

If you need to regenerate the `KEYSTORE_BASE64` secret:

### On Windows:
```powershell
[System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("path\to\upload-keystore.jks"))
```

### On Linux/Mac:
```bash
base64 -i path/to/upload-keystore.jks
```

Copy the output and add it as the `KEYSTORE_BASE64` secret in your GitHub repository settings.