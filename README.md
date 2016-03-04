<!-- README.md is generated from README.Rmd. Please edit that file -->
Importing Text Message Data to R with smsProcess
================================================

The smsprocess package contains only two functions: smsProcess() and smsBatch().

To use them, you will need the XML backup files produced by the Android app "SMS Backup & Restore", which is available [here](https://play.google.com/store/apps/details?id=com.riteshsahu.SMSBackupRestore) on Google Play.

Using SMS Process & Restore
---------------------------

To make sure everything works smoothly, install the app on the phone(s) you wish to analyze, and use the following settings in SMS Backup & Restore: -Enable MMS Backup (to ensure group, multi-part, & image messages are saved) -Add Readable Date (smsProcess assumes this will be there) -Add Contact Names (likewise)

Once this is done, simply press Backup to generate the necessary XML file. You must then get the file off your phone by emailing it to yourself or syncing to Dropbox or Google Drive.

Using smsProcess() and smsBatch()
---------------------------------

smsProcess() is the core function: it imports and cleans the raw XML file so that it will be useful in R. To use it, simply make sure the file you want to import is in the working directory, then run smsProcess("filename.xml")

smsProcess() has several options: -file: A character string with the name of the backup file, ie "sms.xml" -keepUnsent: When TRUE, this keeps Failed and Draft messages. FALSE is default. -charCount: When TRUE (default), this adds a column counting the number of characters in each text. -noMMS: Set to TRUE if your backup file has no MMS data in it. This skips the block of code processing MMS data, thereby avoiding errors. If you encounter "variable not found" errors, try setting this to TRUE.

smsBatch() is just a convenience wrapper for processing multiple backup files (either from multiple phones, or backups from different times.) It just calls lapply, rbind, and arrange on smsProcess().

smsBatch() has a few options: -files can take either a character vector of muplitple file names, ie c("sms1.xml", "sms2.xml)"), or (by default) the input "all" will pull and process all XML files in the working directory. -removeDuplicates When TRUE (default), duplicate rows are removed. This is necessary when backup files overlap. -keepUnsent, charCount, and noMMS are passed to smsProcess() to set the options available to that function.

General Usage
-------------

Import one XML file
smsProcess("backup.xml", keepUnsent = TRUE)
Import all XML files in working directory with default options
smsBatch()
Import multiple files, with custom options
smsBatch(c("backup1.xml", "backup2.xml"), keepUnsent = TRUE, noMMS =TRUE)
