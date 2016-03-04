smsProcess <- function(file = NULL, keepUnsent = FALSE,
                       charCount = TRUE, noMMS = FALSE) {
  #' smsProcess
  #'
  #' Imports and cleans Android text message backup XML files.
  #' @details smsProcess imports and cleans raw XML text message backups
  #' produced by the Android app "SMS Backup & Restore"
  #' @param file name of a backup file, such as "sms1.xml"
  #' @param keepUnsent Keeps unsent Draft and Failed messages when TRUE.
  #' Defaults to FALSE
  #' @param charCount When TRUE, adds a column counting the characters in
  #' each text.
  #' @param noMMS A flag to specify when no MMS data is present.
  #' If no MMS data exists, MMS munging code will throw errors. When TRUE,
  #' MMS munging code is skipped.
  #' @return A data.frame of text message data, sorted by date.
  #' @keywords sms, mms, text messages, android
  #' @export
  #' @import dplyr
  #' @examples
  #' #Import one backup file with default options
  #' smsProcess("backup.xml")
  #' #Import with non-default options
  #' smsProcess("backup.xml", keepUnsent = TRUE, charCount = FALSE,
  #' noMMS = TRUE)
  #' @seealso \code{\link{smsBatch}} For conveniently processing and combining
  #' multiple backup files.

  #Load and parse XML data
  xml <- XML::xmlParse(file)
  data <- XML::xmlToList(xml)

  #Pull apart SMS and MMS list elements
  sms <- data[grepl("sms", names(data))]
  mms <- data[grepl("mms", names(data))]

  #Check whether MMS data exists. If not, set flag to TRUE to skip MMS munging
  #code and avoid errors. Note that it is possible for MMS messages to
  #exist, but have no text bodies. In this case an error will still be thrown,
  #and noMMS should be set to TRUE manually in the function call.
  if(length(mms)==0) noMMS <- TRUE

  #Pull necessary elements from sms lists, combine into a data.frame
  sms <- do.call(rbind, lapply(sms, '[', c("type", "body", "readable_date",
                                           "contact_name")))
  sms <- suppressWarnings(data.frame(sms, stringsAsFactors = FALSE))
  #Reorder, rename, and recode
  sms <- select(sms, date = readable_date, contact_name, type, body)
  sms$date <- lubridate::mdy_hms(sms$date)
  sms$type[sms$type == 1] <- "received"
  sms$type[sms$type == 2] <- "sent"
  sms$type[sms$type == 3] <- "draft"
  sms$type[sms$type == 5] <- "failed"
  sms$type <- as.factor(sms$type)


  #If there are no MMS messages, the following code will throw various errors.
  #To avoid this, we skip the whole block, and only output SMS messages.
  if (noMMS == FALSE) {

    #MMS texts and their metadata will be pulled separately, so we need to
    #give each text a unique name for matching later
    names(mms) <- paste0("mms", seq_along(mms))

    #A function to flatten deeply nested lists
    flatlist <- function(mylist){
      lapply(rapply(mylist, enquote, how="unlist"), eval)
    }

    #Flatten nested list structure for easier addressing
    mms <- flatlist(mms)

    #Pull out text bodies, bind them into a data.frame, with a rowname column
    #for matching to metadata
    mmstexts <- mms[grepl("text/plain", mms)]
    mmstexts <- do.call(rbind, lapply(mmstexts, '[', "text"))
    #Truncate the overlong row names
    row.names(mmstexts) <- sub("\\..*", "", row.names(mmstexts))
    mmstexts <- suppressWarnings(data.frame(mmstexts, stringsAsFactors = FALSE))
    mmstexts$match <- row.names(mmstexts)

    #Pull meta data, bind them into a data.frame, with a rowname column for
    #matching to text bodies
    meta <- mms[grepl("attrs", names(mms))]
    meta <- do.call(rbind, lapply(meta, '[', c("readable_date", "m_type",
                                               "contact_name")))
    #Truncate the overlong row names
    row.names(meta) <- sub("\\..*", "", row.names(meta) )
    meta <- suppressWarnings(data.frame(meta, stringsAsFactors = FALSE))
    meta$match <- row.names(meta)

    #Combine text bodies with metadata, rename and arrange columns, recode type
    #Note that any messages that contained only images and no text will be NA.
    #Could replace with an [image] tag, but this would confuse word counting,
    #and an indicator variable seems like overkill
    mms <- left_join(meta, mmstexts, by = "match") %>%
      select(date = readable_date, contact_name, type = m_type, body = text)
    mms$type[mms$type == 132] <- "received"
    mms$type[mms$type == 128] <- "sent"
    mms$type <- as.factor(mms$type)
    mms$date <- lubridate::mdy_hms(mms$date)


    #Combine sms and mms messages, arrange by date
    all <- rbind(sms, mms) %>%
      arrange(date)
  }

  #When there is no MMS data, assign sms to all so the subsequent code works
  if (noMMS == TRUE) all <- sms


  #When keepUnsent == FALSE, we remove failed messages and unsent drafts
  if (keepUnsent == "FALSE") {
    all <- filter(all, type == "sent" | type == "received")
  }


  #When charCount == TRUE, we add a column counting the characters in each text
  if (charCount == TRUE) {
    all <- all %>%
      mutate(length = nchar(all$body))
  }

  return(all)
}


