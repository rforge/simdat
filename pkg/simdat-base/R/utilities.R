cor2cov <- function(cor,sd) {
  outer(sd, sd) * cor
}


