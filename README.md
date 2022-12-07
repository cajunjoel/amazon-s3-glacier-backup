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

# What it really does

This command uses tar, tar\ listings, and glacier-cmd to back up one or more directories creating full 
backups at first and incremental backups after that. The process is as follows:

Each of configured BACKUP_PATH is processed individually and separately from the other configured paths.

The last component of the path is used to create a [tar incremental metadata file](https://www.gnu.org/software/tar/manual/html_chapter/tar_5.html#SEC96) 
as well as a vault at Amazon S3 Glacier. See "Known Bugs and limitations" below for more information.

After validation, the script checks for the presence of a tar incremental metadata file for the given source. 

If the metadata file is missing, tar is used to back up everything in the directory.

If the metadata file is present, tar is used to only back up that which changed. Due to the nature of the incremental
backup, added, changed, *and* deleted files will be incorporated into the tar file.

The resulting tar file is uploaded to Amazon S3 Glacier.

The results of the upload are saved to a log file that should not be removed. If it is lost, however, it can be recovered. 
In all cases, the tar incremental metadata file should be preseved, but a loss of them still means that recover is possible,
with the loss of deletions. (That is, deleted files will persist after a full restore.)

# Restoring Files

To restore. Download everything from amazon Glacier. Be careful of pricing. For large things, this can get expensive.

$ glacier-cmd inventory [VAULTNAME]
$ glacier-cmd getarchive [VAULTNAME] [ARCHIVE_ID]
$ glacier-cmd download [VAULTNAME] [ARCHIVE_ID] > [FILENAME.tgz.pgp]

Then decrypt

$ gpg -d --passphrase=$PASSWD Test-FULL.tgz.gpg
$ gpg -d --passphrase=$PASSWD Test-1.tgz.gpg
$ gpg -d --passphrase=$PASSWD Test-2.tgz.gpg

$ tar fxz /mnt/data/Backups/Test-FULL.tgz --listed-incremental=/dev/null
$ tar fxz /mnt/data/Backups/Test-1.tgz --listed-incremental=/dev/null
$ tar fxz /mnt/data/Backups/Test-2.tgz --listed-incremental=/dev/null

And pray.

# Known Bugs and limitations

* If two BACKUP_PATHs have the same directory name, they will collide and cause awful unepxected results. 

For example, this will cause unexpected results.

    BACKUP_PATH=/home/glaciertest/files/mobile-phone/photos
    BACKUP_PATH=/data/photography/raw/photos 



