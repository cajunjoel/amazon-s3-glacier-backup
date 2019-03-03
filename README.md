# amazon-s3-glacier-backup
A script to use Amazon Glacier and tar incremental backups for long term storage of stuff. 

# Requirements

## glacier-cmd
Install this from GitHub for your system *and configure* for your Amazon S3 Glacier account.
https://github.com/uskudnik/amazon-glacier-cmd-interface

## GNU Privacy Guard
Install with apt or yum or whatever
https://gnupg.org/

# Setup
Copy the `glacier-backup.conf.dist` file to `glacier-backup.conf` and edit the new file to set the following variables for your system
* GPG_PASSWORD - Required. Something to encrypy your files. Keep it secret, keep it safe.
* BACKUP_PATH - Required. May be supplied more than once to backup different paths
* WORKING_PATH - Optional. If not specified, will use the same path as the script.

# Usage
```
Usage: glacier-backup [-s] [-h]

Parameters
    -s   Simulate. Will print all commands instead of executing.
    -h   Dislpay this information.
```
Ideally, you'd put something like this in cron:

```
0 0 * * * /path/to/glacier-backup >> /path/to/glacier-backup/logs/backup.log 2>&1
```
That's it!
