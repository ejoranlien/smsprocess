% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/smsProcess.R
\name{smsProcess}
\alias{smsProcess}
\title{smsProcess}
\usage{
smsProcess(file = NULL, keepUnsent = FALSE, charCount = TRUE,
  noMMS = FALSE)
}
\arguments{
\item{file}{name of a backup file, such as "sms1.xml"}

\item{keepUnsent}{Keeps unsent Draft and Failed messages when TRUE.
Defaults to FALSE}

\item{charCount}{When TRUE, adds a column counting the characters in
each text.}

\item{noMMS}{A flag to specify when no MMS data is present.
If no MMS data exists, MMS munging code will throw errors. When TRUE,
MMS munging code is skipped.}
}
\value{
A data.frame of text message data, sorted by date.
}
\description{
Imports and cleans Android text message backup XML files.
}
\details{
smsProcess imports and cleans raw XML text message backups
produced by the Android app "SMS Backup & Restore"
}
\examples{
#Import one backup file with default options
smsProcess("backup.xml")
#Import with non-default options
smsProcess("backup.xml", keepUnsent = TRUE, charCount = FALSE,
noMMS = TRUE)
}
\seealso{
\code{\link{smsBatch}} For conveniently processing and combining
multiple backup files.
}
\keyword{android}
\keyword{messages,}
\keyword{mms,}
\keyword{sms,}
\keyword{text}

