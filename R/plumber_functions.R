# URL that contains API
#' @export
mario_api_url <- function() {
  "https://mario2.fredhutch.org"
}

#' Health Check
#'
#' Check if the API is running
#'
#' @export
mario_health_check <- function(api_url = mario_api_url()) {
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
#' @return Response from the API
#' @export
mario_generate_from_gs = function(link,
                                  service = "coqui",
                                  model_name = "jenny",
                                  vocoder_name = "jenny",
                                  api_url = mario_api_url(),
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

