#!/bin/sh
# --batch to prevent interactive command
# --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$ANDROID_KEYS_ZIP_PASSPHRASE" \
--output android/key_files.zip android/key_files.zip.gpg && cd android && jar xvf key_files.zip && cd -
ls -d $PWD/android/*