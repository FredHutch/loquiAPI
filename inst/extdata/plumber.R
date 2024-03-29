# Packages ----
library(plumber)
library(future)
library(promises)
library(jsonlite)
plan(multisession, workers = 25)
options(future.rng.onMisuse = "ignore")

# Initialize an environment to store the promises
promise_env <- new.env()

# Generate a unique ID for each task
generate_id <- function() {
  length_env <- length(ls(envir = promise_env))
  id <- as.character(length_env + 1)
  return(id)
}

#* @apiTitle Loqui API
#* @apiDescription A plumber API that generates automated videos from Google Slides. R package can be found here: https://github.com/FredHutch/loquiAPI

#* Generate Automated Video from Google Slides.
#* @param link URL of Google Slide
#* @param service Text-to-speech Engine.
#* @param model_name Model for Text-to-Speech Conversion.
#* @param vocoder_name Voice Coder used for speech coding and transmission.
#* @post /generate_from_gs
function(link, service = "coqui", model_name = "jenny", vocoder_name = "jenny"){
  # Generate unique id for task
  id <- generate_id()

  assign(id, future({
    # Temporary file
    tmp_video <- tempfile(fileext = ".mp4")

    # Speaker Notes
    pptx_path <- gsplyr::download(link, type = "pptx")
    pptx_notes_vector <- ptplyr::extract_notes(pptx_path)
    # Images
    pdf_path <- gsplyr::download(link, type = "pdf")
    image_path <- ptplyr::convert_pdf_png(pdf_path)

    ari::ari_spin(images = image_path,
                  paragraphs = pptx_notes_vector,
                  output = tmp_video,
                  tts_engine_args =
                    list(service = service,
                         model_name = model_name,
                         vocoder_name = vocoder_name))
  }), envir = promise_env)

  return(list(id = id))
}

#* Check on the status of POST request.
#* @param id The ID of the task
#* @get /status
function(id) {
  if (!exists(id, envir = promise_env)) {
    return("Invalid ID")
  }

  promise <- get(id, envir = promise_env)

  if (resolved(promise)) {
    return("Complete")
  } else {
    return("Running")
  }
}

#* Output the result of the POST request.
#* @param id The ID of the task
#* @post /result
function(id) {

  promise <- get(id, envir = promise_env)
  result <- value(promise)

  result
}

