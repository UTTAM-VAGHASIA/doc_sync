#!/bin/bash

# This script decodes the base64 keystore file and saves it to the correct location
# Usage: ./decode_keystore.sh

# Path to the base64 encoded keystore file
BASE64_FILE="keystore_base64.txt"

# Path where the decoded keystore should be saved
KEYSTORE_FILE="upload-keystore.jks"

# Check if the base64 file exists
if [ ! -f "$BASE64_FILE" ]; then
  echo "Error: $BASE64_FILE not found!"
  exit 1
fi

# Decode the base64 content and save it as the keystore file
cat "$BASE64_FILE" | base64 --decode > "$KEYSTORE_FILE"

# Check if the decoding was successful
if [ $? -eq 0 ] && [ -f "$KEYSTORE_FILE" ]; then
  echo "Successfully decoded keystore to $KEYSTORE_FILE"
  # Make the keystore file readable
  chmod 644 "$KEYSTORE_FILE"
  echo "Keystore file permissions updated"
else
  echo "Error: Failed to decode keystore!"
  exit 1
fi