#' URL for the Plumber API hosted on Fred Hutch's servers
#'
#' https://loquiapi.fredhutch.org
#'
#' @export
api_url <- function() {
  "https://loquiapi.fredhutch.org"
}

#' Health Check
#'
#' Check if the API is running
#'
#' @param api_url URL for API
#' @export
health_check <- function(api_url = api_url()) {
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
#' @return Response from the API
#' @export
generate_from_gs = function(link,
                                  service = "coqui",
                                  model_name = "jenny",
                                  vocoder_name = "jenny",
                                  api_url = api_url(),
                                  ...) {
  # Collect user input
  body = list(
    link = link,
    service = service,
    model_name = model_name,
    vocoder_name = vocoder_name
  )
  # GET
  response <- httr::GET(
    url = paste0(api_url, "/generate_from_gs"),
    query = body,
    ...)

  # Originally from mario::mario_write_video()
  httr::stop_for_status(response)
  bin_data = httr::content(response)
  output = tempfile(fileext = ".mp4")
  writeBin(bin_data, output)

  output
}

