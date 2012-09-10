UN <- function() {
  fam <- list(
    family=c("U","Uniform"),
    parameters=list(),
    nopar = 0,
    type="Continuous")
  class(fam) <- c("gamlss.family","family")
  return(fam)
}
