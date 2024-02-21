
library(plumber)
library(loquiAPI)

port <- plumber:::findPort()


# Start up API locally
system(paste("Rscript", system.file("runAPI.R", package = "loquiAPI"), port), wait = FALSE)

# Check that API on Hutch servers is running
testthat::test_that("Check Default URL", {

  res <- httr::HEAD(loqui_api_url())

  testthat::expect_equal(httr::status_code(res), 404)
})


test_slides <- "https://docs.google.com/presentation/d/1sFsRXfK7LKxFm-ydib5dxyQU9fYujb95katPRu0WVZk/edit?usp=sharing"

# Test with local API
api_url <- paste0("http://0.0.0.0:", port)

testthat::test_that("Posting video", {
  request_id <- post_video_creation(link = test_slides,
                    service = "coqui",
                    model_name = "jenny",
                    vocoder_name = "jenny",
                    api_url = api_url)

  testthat::expect_type(request_id, "character")

})

testthat::test_that("Checking status", {

  request_id <- post_video_creation(link = test_slides,
                                    service = "coqui",
                                    model_name = "jenny",
                                    vocoder_name = "jenny",
                                    api_url = api_url)

  status <- request_status(request_id, api_url)

  Sys.sleep(2)

  testthat::expect_equal(status, "Complete")
})

testthat::test_that("Checking status", {
  request_id <- post_video_creation(link = test_slides,
                                    service = "coqui",
                                    model_name = "jenny",
                                    vocoder_name = "jenny",
                                    api_url = api_url)
  # Give it a second to complete
  Sys.sleep(5)

  download_video(request_id, api_url, "test.mp4")

  # We expect the file will exist!
  testthat::expect_condition(file.exist("test.mp4"))
})
