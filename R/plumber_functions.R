#' URL for the Plumber API hosted on Fred Hutch's servers
#'
#' https://loquiapi.fredhutch.org
#'
#' @export
loqui_api_url <- function() {
  "https://loquiapi.fredhutch.org"
}

#' Health Check
#'
#' Check if the API is running
#'
#' @param api_url URL for API
#' @export
health_check <- function(api_url = loqui_api_url()) {
  # GET url
  response <- httr::GET(paste0(api_url, "/health_check"))
  httr::stop_for_status(response)

  # response
  jsonlite::fromJSON(httr::content(response, as = "text"), flatten = TRUE)
}


#' Generate video from Google Slides
#'
#' @param link Full URL to Google Slides with public access enabled
#' @param service Speech synthesis service
#' @param model_name The voice used to synthesize the audio
#' @param vocoder_name Voice coder used for speech coding and transmission
#' @param api_url URL that contains API
#' @param ... Other parameters passed to \code{httr::GET()}
#' @return Path to video output
#' @export
generate_from_gs = function(link,
                            service = "coqui",
                            model_name = "jenny",
                            vocoder_name = "jenny",
                            api_url = loqui_api_url(),
                            output = "video.mp4",
                            ...) {
  # Collect user input
  body = list(
    link = link,
    service = service,
    model_name = model_name,
    vocoder_name = vocoder_name
  )
  # POST
  response <- httr::POST(
    url = paste0(api_url, "/generate_from_gs"),
    query = body,
    httr::write_disk(output))

  # Tell user whether POST request has been completed.
  response_status <- httr::stop_for_status(response)
  if (response_status$status_code == 200) {
    message(paste0("Rendered video is available in your working directory as ", output))
  } else {
    message(paste0("HTTP Error ", response_status$status_code))
  }
}

