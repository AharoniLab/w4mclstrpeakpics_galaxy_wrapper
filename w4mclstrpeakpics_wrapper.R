#!/usr/bin/env Rscript

library(batch) ## parseCommandArgs

########
# MAIN #
########

argVc <- unlist(parseCommandArgs(evaluate=FALSE))

##------------------------------
## Initializing
##------------------------------

## options
##--------

strAsFacL <- options()$stringsAsFactors
options(stringsAsFactors = FALSE)

## libraries
##----------

# begin HACK - suppress " Can't find a usable init.tcl ...  probably means that Tcl wasn't installed properly" issue
library("gsubfn")
options(gsubfn.engine = "R")
# end HACK

#r_package_archive <- as.character(argVc["r_package_archive"])
#install.packages(r_package_archive, repos = NULL, type = "source")
suppressMessages( library("w4mclstrpeakpics") )

## constants
##----------

modNamC <- "w4mclsltrpeakpics" ## module name

topEnvC <- environment()
flgC <- "\n"

## functions
##----------


## log file
##---------

my_print <- function(x, ...) { cat(c(x, ...))}

my_print("\nStart of the '", modNamC, "' Galaxy module call: ",
    format(Sys.time(), "%a %d %b %Y %X"), "\n", sep="")

## arguments
##----------

# files

output_pdf                  <- as.character(argVc["output_pdf"])
output_tsv                  <- as.character(argVc["output_tsv"])
output_rdata                <- as.character(argVc["output_rdata"])
data_matrix_path            <- as.character(argVc["data_matrix_path"])
variable_metadata_path      <- as.character(argVc["variable_metadata_path"])
sample_metadata_path        <- as.character(argVc["sample_metadata_path"])
  
# other parameters

sample_selector_column_name <- as.character(argVc["sample_selector_column_name"])
sample_selector_value       <- as.character(argVc["sample_selector_value"])
  
##------------------------------
## Computation
##------------------------------

# from 'demo(error.catching)'
tryCatch.W.E <- function(expr) {
  W <- NULL
  w.handler <- function(w){
    # warning handler
    W <<- w
    invokeRestart("muffleWarning")
  }
  list(
    value = withCallingHandlers(
      tryCatch(expr, error = function(e) e)
    , warning = w.handler
    )
  , warning = W
  )
}

result <- cluster_peak_assessment(
  sample_selector_column_name = sample_selector_column_name
, sample_selector_value       = sample_selector_value      
, sample_metadata_path        = sample_metadata_path  
, variable_metadata_path      = variable_metadata_path
, data_matrix_path            = data_matrix_path      
, output_pdf                  = output_pdf            
, output_tsv                  = output_tsv            
, output_rdata                = output_rdata                 
, failure_action              = my_print
)


my_print("\nResult of '", modNamC, "' Galaxy module call to 'w4mclassfilter::w4m_filter_by_sample_class' R function: ",
    as.character(result), "\n", sep = "")

##--------
## Closing
##--------

my_print("\nEnd of '", modNamC, "' Galaxy module call: ",
    as.character(Sys.time()), "\n", sep = "")

#sink()

if (!file.exists(output_pdf)) {
  print(sprintf("ERROR %s::w4m_filter_by_sample_class - file '%s' was not created", modNamC, output_pdf))
}

if (!file.exists(output_tsv)) {
  print(sprintf("ERROR %s::w4m_filter_by_sample_class - file '%s' was not created", modNamC, output_tsv))
}

if (!file.exists(output_rdata)) {
  print(sprintf("ERROR %s::w4m_filter_by_sample_class - file '%s' was not created", modNamC, output_rdata))
}

# 'stop' causes Rscript to return a non-zero exit code
if( !result ) {
  stop(sprintf("ERROR %s::w4m_filter_by_sample_class - method failed", modNamC))
}

# exit with status code zero
q(save = "no", status = 0, runLast = FALSE)
