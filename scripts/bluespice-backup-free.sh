#!/bin/sh
set -e

#timestamp for file names
current_time=$(date "+%Y.%m.%d-%H.%M.%S")

#define and create backup dir
backup_dir=$BLUESPICE_DATA_PATH/backup
mkdir -p $backup_dir

#define destination files
filename_zip=$backup_dir/bluespice_webroot_$current_time.zip
filename_db=$backup_dir/bluespice_db_$current_time.sql.gz
filename_files=$backup_dir/bluespice_files_$current_time.zip

#backup webroot
cd $BLUESPICE_WEBROOT
zip -r $filename_zip .

#backup files: cache  compiled_templates  config  data  images
cd $BLUESPICE_DATA_PATH
zip -r $filename_files cache compiled_templates config data images

#backup db
mysqldump -u $DB_USER -h $DB_HOST -p$DB_PASSWORD --port $DB_PORT $DB_NAME | gzip > $filename_db
