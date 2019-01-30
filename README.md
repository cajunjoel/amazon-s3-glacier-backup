# amazon-s3-glacier-backup
A script to use Amazon Glacier and tar incremental backups for long term storage of stuff. 

# Requirements

## glacier-cmd
Install this from GitHub for your system and configure for your Amazon S3 Glacier account.
https://github.com/uskudnik/amazon-glacier-cmd-interface

## GNU Privacy Guard
Install with Apt or Yum or whatever
https://gnupg.org/

# Setup
Copy the `envvars.sample` file to `envvars` and edit the new file to set the following variables for your system
* SOURCE_DIR
* WORKING_DIR
* DIRS
* PASSWD

# Usage
`/bin/bash glacier-backup` 

That's it!
