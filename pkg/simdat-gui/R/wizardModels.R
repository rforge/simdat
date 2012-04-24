setClass("WizardModel")

setClass("RmAnovaWizardModel",
  contains="WizardDf",
  representation(
    dependent="Variable",
    bdesign="VariableList",
    wdesign="VariableList",
    numeric="VariableList",
    family="gamlss.family")
)

getWizardDf <- function(object) {
  bdat <- getData(object@bdesign)
  if(NROW(bdat) < 1 || NCOL(bdat) < 1) {
    bdat <- data.frame(NA)
  }
  wdat <- getData(object@wdesign)
  if(NROW(wdat) < 1 || NCOL(wdat) < 1) {
    wdat <- data.frame(NA)
  }
  wnames <- apply(wdat,1,function(x) paste(x,collapse="."))
  nopar <- object@family$nopar 
  if(nopar > 0) {
    munames <- paste("mu",wnames,sep=".")
    bdat[,munames] <- 0
  }
  if(nopar > 1) {
    bdat[,"sigma.between"] <- 1
  }
}

getWithinWizardDf <- function(x) {

}

setWizardDf <- function(model,df) {

}




