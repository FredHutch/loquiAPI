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
#' @param keep_checking Keep checking the status of the video and download immediately. Alternatively, don't check and the user will check and download themselves using
#' @param ... Other parameters passed to \code{httr::POST()}
#' @return Path to video output
#' @export
# TODO: Probably rename this function something like "Post video creation request"
generate_from_gs = function(link,
                            service = "coqui",
                            model_name = "jenny",
                            vocoder_name = "jenny",
                            api_url = loqui_api_url(),
                            output = "video.mp4",
                            keep_checking = FALSE,
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
    # TODO: figure out how to change this so the id is returned
    httr::write_disk(output))

  # Tell user whether POST request has been completed.
  response_status <- httr::stop_for_status(response)
  if (response_status$status_code == 200) {
    message(paste0("Video creation request posted", output))
  } else {
    message(paste0("HTTP Error ", response_status$status_code))
  }

  # TODO: SEND BACK ID HERE (IF it isn't)
  invisible(output)

  # TODO: the alternative is we return the id but we need to figure out how to grab that
  id <- response$id

  # Two options we either keep checking if the video is ready, or just return the id
  if (keep_checking) {

    while (request_status(id) == "running") {
      # Wait for 15 seconds
      Sys.sleep(15)
      message("Video not commplete yet. Will check back in 15 seconds")
    }

    video_file_path <- download_video(id)

    return(video_file_path)
  } else {
    # If someone didn't want to wait around, we just give them the id
    return(response$id)
  }
}

#' Check on status of video POST request
#'
#' @param id the ID returned from running generate_from_gs
#' @param service Speech synthesis service
#' @param model_name The voice used to synthesize the audio
#' @param vocoder_name Voice coder used for speech coding and transmission
#' @param api_url URL that contains API
#' @param output Path video output
#' @param ... Other parameters passed to \code{httr::GET()}
#' @return Path to video output
#' @export
request_status <- function(id) {

  # TODO: Howard makes this idea tested and work
  response <- httr::GET(
    url = paste0(api_url, "/status"),
    # TODO: What you need for returning the status
    )

  # TODO: More httr handling here
}

#' Download the video
#'
#' @param id the ID returned from running generate_from_gs
#' @param path a file path to download the video to
#' @param ... Other parameters passed to \code{httr::GET()}
#' @return Download video to
#' @export
download_video <- function(id, path) {

  # TODO: Howard makes this idea tested and work
  response <- httr::GET(
    url = paste0(api_url, "/result"),
    # TODO: What you need for getting the video
  )
  # TODO: I suspect httr::write_disk(output) needs to be involved here
  # TODO: END goal of this function is to download the video based on the id given
  # TODO: More httr handling here
}

