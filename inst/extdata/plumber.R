# Packages ----
library(plumber)
library(future)
plan(multisession, workers = 25)

#* @apiTitle Loqui API
#* @apiDescription A plumber API that generates automated videos from Google Slides or PowerPoint slides.

#* Health Check - Is the API running?
#* @get /health_check
function() {
  list(
    status = "Health Check: All Good",
    time = Sys.time()
  )
}

#* Generate Automated Video from Google Slides
#* @param link
#* @param service
#* @param model_name
#* @param vocoder_name
#* @serializer contentType list(type="video/mp4")
#* @post /generate_from_gs
function(link, service, model_name, vocoder_name){

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
