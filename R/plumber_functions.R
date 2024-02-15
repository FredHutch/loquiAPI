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
#' @param output Path video output
#' @param ... Other parameters passed to \code{httr::GET()}
#' @return Path to video output
#' @export
post_video_creation = function(link,
                               service = "coqui",
                               model_name = "jenny",
                               vocoder_name = "jenny",
                               api_url = loqui_api_url(),
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
    ...
  )

  # Tell user whether POST request has been completed.
  response_status <- httr::stop_for_status(response)
  if (response_status$status_code == 200) {
    message("Video creation request posted")
  } else {
    message(paste0("HTTP Error ", response_status$status_code))
  }

  # Return id
  response_content <- httr::content(response)
  response_content$id[[1]]
}

#' Check on status of video POST request
#'
#' @param id the ID returned from running generate_from_gs
#' @param ... Other parameters passed to \code{httr::GET()}
#' @return Path to video output
#' @export
request_status <- function(id, api_url) {
  # GET
  response <- httr::GET(
    url = paste0(api_url, "/status"),
    query = list(id = id)
  )

  httr::stop_for_status(response)
  response_content <- httr::content(response)
  response_content[[1]]
}

#' Download the video
#'
#' @param id the ID returned from running generate_from_gs
#' @param output_path a file path to download the video to
#' @param ... Other parameters passed to \code{httr::GET()}
#' @return Download video to
#' @export
download_video <- function(id, api_url, output_path) {
  response <- httr::POST(
    url = paste0(api_url, "/result"),
    query = list(id = id)
  )

  response_status <- httr::stop_for_status(response)
  if (response_status$status_code == 200) {
    message(paste0("Video downloaded to ", output_path))
  } else {
    message(paste0("HTTP Error ", response_status$status_code))
  }

  response_content <- httr::content(response)
  tmp_video <- response_content[[1]]

  # Read binary data from tmp_video as raw mode
  binary_data <- readBin(tmp_video, "raw", n = file.info(tmp_video)$size)
  # Write binary data to output_path
  writeBin(binary_data, output_path)
}











