# Android Keystore Setup

This document explains how to work with the keystore for signing your Android app, both locally and in GitHub Actions.

## Local Development

### Using the Existing Keystore

If you have the keystore file (`upload-keystore.jks`), place it in the `android/app/` directory. The app's `build.gradle` is configured to look for this file by default.

### Decoding from Base64

If you have the base64-encoded keystore (in `keystore_base64.txt`), you can decode it using the provided scripts:

#### On Windows:
```
.\decode_keystore.bat
```

#### On Linux/Mac:
```
./decode_keystore.sh
```

This will create the `upload-keystore.jks` file in the current directory.

## GitHub Actions

The GitHub workflow is configured to automatically decode the keystore from the `KEYSTORE_BASE64` secret and use it for signing the APK. The workflow:

1. Decodes the base64 secret to `android/app/upload-keystore.jks`
2. Sets the required environment variables for the build process
3. Builds the signed APK

## Troubleshooting

### Common Issues

1. **Keystore file not found**: Ensure the keystore file is in the correct location (`android/app/upload-keystore.jks`) or that the environment variable `KEYSTORE_FILE` points to the correct location.

2. **Invalid keystore format**: If the base64 encoding/decoding process is incorrect, the keystore file may be corrupted. Try decoding the keystore locally to verify it works.

3. **GitHub Actions failure**: Check the workflow logs to see if the keystore file was correctly decoded and if the file exists at the expected location.

### Verifying the Keystore

You can verify the keystore using the `keytool` command:

```
keytool -list -v -keystore upload-keystore.jks -alias upload
```

You'll be prompted for the keystore password.