library(plumber)
library(loquiAPI)

args <- commandArgs(trailingOnly=TRUE)
port <- as.numeric(args[1])

if (is.na(port)) port <- plumber:::findPort()

root <- pr("inst/extdata/plumber.R")
root

root %>% pr_run(host = "0.0.0.0", port = port)
