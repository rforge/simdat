.onLoad <- function(libname, pkgname) {

}

.onAttach <- function(libname, pkgname) {

  .sde <<- new.env()
  
  .sde$MODELS <- list()
  .sde$CURRENT_MODEL <- new("SimDatModel")

}
