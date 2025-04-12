# Android App Signing Instructions

This document provides detailed instructions for setting up and managing the signing configuration for your Flutter application. Proper app signing is crucial for app updates, Play Store publishing, and maintaining a consistent app identity.

## Setting Up the Keystore for Local Development

### Creating a Keystore

If you don't already have a keystore file, you can create one using the following steps:

1. Open a terminal/command prompt
2. Navigate to your project's `android/app` directory
3. Run the following command to generate a new keystore:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

4. Follow the prompts to enter password and other information
5. Remember the passwords and alias you used - you'll need them later

### Configuring Local Development Environment

1. Place the `upload-keystore.jks` file in the `android/app` directory
2. You can set environment variables for secure password management:

```bash
# Windows
set KEYSTORE_PASSWORD=your_keystore_password
set KEY_ALIAS=upload
set KEY_PASSWORD=your_key_password

# macOS/Linux
export KEYSTORE_PASSWORD=your_keystore_password
export KEY_ALIAS=upload
export KEY_PASSWORD=your_key_password
```

3. Alternatively, the build.gradle is configured with fallback values for development:
   - Default keystore path: `android/app/upload-keystore.jks`
   - Default keystore password: `android`
   - Default key alias: `upload`
   - Default key password: `android`

> **IMPORTANT**: Never commit your actual keystore or passwords to version control. The default values should only be used for development.

## Configuring GitHub Repository Secrets for Workflows

To enable secure signing in GitHub Actions workflows, you need to set up repository secrets:

1. Convert your keystore file to Base64:

```bash
# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("path\to\upload-keystore.jks")) | Out-File keystore_base64.txt

# macOS/Linux
base64 -i upload-keystore.jks > keystore_base64.txt
```

2. Go to your GitHub repository → Settings → Secrets and variables → Actions → New repository secret

3. Add the following secrets:
   - `KEYSTORE_BASE64`: The content of the keystore_base64.txt file
   - `KEYSTORE_PASSWORD`: Your keystore password
   - `KEY_ALIAS`: Your key alias (usually "upload")
   - `KEY_PASSWORD`: Your key password
   - `GH_PAT_FOR_RELEASES`: A GitHub Personal Access Token with `repo` scope (already configured)

## Updating the GitHub Workflow

The GitHub workflow file has been updated to include the signing configuration. The workflow now:

1. Decodes the Base64 keystore secret and saves it as a file
2. Sets up the environment variables for the build process
3. Uses these credentials when building the release APK

## Troubleshooting Package Conflicts

### Common Issues and Solutions

#### 1. Package Name Conflicts

If you encounter package name conflicts during updates:

- Ensure you're using the same signing key for all builds
- Verify the `applicationId` in `build.gradle` remains consistent
- Check that the version code increases with each release

#### 2. Signature Verification Failures

If users experience signature verification failures when updating:

- Confirm you're using the same keystore for all releases
- Verify the key alias is consistent between builds
- Check if the GitHub workflow is correctly applying the signing configuration

#### 3. ProGuard/R8 Related Issues

If you encounter crashes after enabling code shrinking:

- Review the ProGuard rules in `proguard-rules.pro`
- Add keep rules for any libraries or classes that are being incorrectly optimized
- Test thoroughly after making ProGuard changes

#### 4. GitHub Actions Build Failures

If the GitHub workflow fails to build or sign the APK:

- Check the workflow logs for specific error messages
- Verify all required secrets are correctly configured
- Ensure the Base64 encoding of the keystore was done correctly

## Best Practices

1. **Backup Your Keystore**: Store your keystore file and passwords in a secure location. Losing your keystore means you cannot update your app on the Play Store.

2. **Use Strong Passwords**: Use strong, unique passwords for your keystore and key.

3. **Limit Access to Secrets**: Only share keystore access with team members who absolutely need it.

4. **Regular Verification**: Periodically verify that your signing process works correctly by testing the signed APK.

5. **Document Changes**: Keep this document updated with any changes to the signing process.