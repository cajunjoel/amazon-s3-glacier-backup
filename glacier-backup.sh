#!/bin/bash

# Locate some programs just in case they are different for you
CMD="/usr/local/bin/glacier-cmd"
TAR="/bin/tar"
GPG="/usr/bin/gpg"

# Make some other settings
DAY=$(date +"%Y%m%d")
LONGDAY=$(date +"%c")

# Fill this in with the path to the folders to backup
SOURCE_DIR="/path/to/folders"

# This directory will contain the control files for TAR and temporary space for
# tarring and encrypting. Do not delete stuff in here!
WORKING_DIR="/path/to/working/dir"

# Fill this in with an array of subfolders to backup that live in $SOURCE_DIR
# i.e. /path/to/folders/stuff and /path/to/folders/more-stuff
DIRS=("stuff" "more-stuff")

# This is a very long password to use with gpg to encrypt your stuff.
PASSWD=""

# Echo Backup Date for Logs
echo
echo "***********************************************************************"
echo "Start: $LONGDAY..."
 
for IDX in ${!DIRS[*]}
do
	BACKUP_DEST="$WORKING_DIR/${DIRS[$IDX]}-$DAY.tgz"
	BACKUP_FULL="$WORKING_DIR/${DIRS[$IDX]}-FULL.tgz"
	INC_FILE="$WORKING_DIR/${DIRS[$IDX]}.listing"
	VAULT=$(echo "${DIRS[$IDX]}" | sed -e 's/-/_/' -e 's/\(.*\)/\L\1/')

	if [ -e $BACKUP_FULL ]; then
		echo "Making an incremental backup..."
                $TAR fczv "$BACKUP_DEST" -g "$INC_FILE" -C "$SOURCE_DIR" "${DIRS[$IDX]}"
	else
		echo "Making a full backup..."
		$TAR fczv "$BACKUP_FULL" -g "$INC_FILE" -C "$SOURCE_DIR" "${DIRS[$IDX]}"
		BACKUP_DEST=$BACKUP_FULL
	fi		

	# Encrypt the backup file
	$GPG --symmetric --batch --passphrase=$PASSWD $BACKUP_DEST
	BACKUP_DEST_GPG=$(echo "$BACKUP_DEST.gpg")
	
	# Calculate the Tree hash for posterity
	$CMD treehash $BACKUP_DEST_GPG

	# Send file to Glacier
	echo "Sending to Glacier..."
	$CMD upload $VAULT $BACKUP_DEST_GPG --description "${DIRS[$IDX]} as of $LONGDAY"

	# Delete backup file
	echo "Deleting backup file..."
	rm $BACKUP_DEST_GPG
	rm $BACKUP_DEST
done

