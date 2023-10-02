
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mario2

<!-- badges: start -->
<!-- badges: end -->

The goal of mario2 is to let users programmatically generate automated
videos from Google Slides or PowerPoint slides.

## Installation

You can install the development version of mario2 from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("FredHutch/mario2")
```

## Example

When you want to generate a video of your Google Slides, run
`mario_generate_from_gs(link)` and you should see the output file path
to your video mp4 file.

``` r
library(mario2)

mario_generate_from_gs(link = "https://docs.google.com/presentation/d/1Dw_rBb1hySN_76xh9-x5J2dWF_das9BAUjQigf2fN-E/edit#slide=id.p")
```
