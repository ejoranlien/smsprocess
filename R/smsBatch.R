smsBatch <- function(files = "all", removeDuplicates = TRUE,
                     keepUnsent = FALSE, charCount = TRUE, noMMS = FALSE) {

  #' smsBatch
  #'
  #' Convenience wrapper for smsProcess, to import and combine mulitple files
  #' @details smsBatch is a convenience wrapper for smsProcess, which pulls
  #' and combines multiple XML files of text message records. It can be passed
  #' a character string of file names to pass to process, or by default it will
  #' pull all XML files in the working directory.
  #' @param files A character vector of files to import. Default "all" will
  #' import all XML files from the working directory.
  #' @param removeDuplicates When TRUE (default), will remove duplicate rows;
  #' useful for combining overlapping backups.
  #' @param keepUnsent Keeps unsent Draft and Failed messages when TRUE.
  #' Defaults to FALSE
  #' @param charCount When TRUE, adds a column counting the characters in each
  #' text.
  #' @param noMMS A flag to specify when no MMS data is present. If no MMS data
  #' exists, MMS munging code will throw errors. When TRUE, MMS munging code is
  #' skipped.
  #' @return A data.frame of text message data, sorted by date.
  #' @keywords sms, mms, text messages, android
  #' @export
  #' @examples
  #' #Import all XML files in working directory with default options
  #' smsProcess()
  #' #Import specific files, passing options to smsProceess
  #' smsProcess(c("backup1.xml", "backup2.xml"), keepUnsent = TRUE,
  #' charCount = FALSE, noMMS = TRUE)
  #' @seealso \code{\link{smsProcess}} For the documentation on the underlying
  #' function called by smsBatch





  #"Files" can be atomic or a vector. Some nested ifs handle all cases:
  #1. Vector (length >1): "files" contains a list of files to process.
  #   Skip all if statements and process.
  #2. Atomic (length <=1): either the default "all" or a single specified file.
  #   If "all, we pull all csv files in wd. If there are none, throw an error.
  #   If not "all", user wants to process a single csv. Pass to next function.

  if(length(files <= 1)) {

    if(files == "all") {
      files <- list.files(pattern="*.xml")

      if (length(files) <1) {
        stop("No XML files in working directory!")
      }
    }
  }
  #Pull all requested files into a list

  allfiles <- lapply(files, function(x) smsProcess(x,
                                                   keepUnsent = keepUnsent,
                                                   charCount = charCount,
                                                   noMMS = noMMS))
  all <- do.call("rbind", allfiles) %>%
    arrange(date)

  if(removeDuplicates == TRUE) all <- unique(all)
  return(all)
}
