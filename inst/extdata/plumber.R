# Packages ----
library(plumber)
library(future)
plan(multisession, workers = 25)

#* @apiTitle Loqui API
#* @apiDescription A plumber API that generates automated videos from Google Slides.

#* Health Check - Is the API running?
#* @get /health_check
function() {
  list(
    status = "Health Check: All Good",
    time = Sys.time()
  )
}

#* Generate Automated Video from Google Slides
#* @param link URL of Google Slide
#* @param service Text-to-speech Engine.
#* @param model_name Model for Text-to-Speech Conversion.
#* @param vocoder_name Voice Coder used for speech coding and transmission.
#* @serializer contentType list(type="video/mp4")
#* @post /generate_from_gs
function(link, service = "coqui", model_name = "jenny", vocoder_name = "jenny"){

  future::future({
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

    # Get file download
    plumber::as_attachment(readBin(tmp_video, "raw", n = file.info(tmp_video)$size), "video.mp4")
  })
}
