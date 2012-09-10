simdat.gui.env <- new.env()

setwd("~/Documents/RForge/simdat/pkg/simdat-base/R")
require("gamlss.dist")
require("mvtnorm")
require("gamlss.tr")
source("allGenerics.R")
source("Variable.R")
source("Model.R")
source("SimDatModel.R")
source("GLMcreate.R")
source("GLM.R")
source("ANOVA.R")
#source("factorialANOVA.R")
source("repeatedMeasuresANOVA.R")
source("Regression.R")
#source("rtnorm.R")
source("utilities.R")
source("zzz.R")
#tmp <- ANOVA()
#tmp <- factorialANOVA()
#tmp <- rmANOVA()

require(JGR)
#require(rJava)
setwd("~/Documents/RForge/simdat/pkg/simdat-gui/R")
source("allGenerics.R")
source("utils.R")
source("changeVariables.R")
source("changeModels.R")
#source("wizardDataModels.R")
source("wizardModels.R")
source("zzz.R")

#arglist <- list()
#arglist[["dep"]] <- variables(tmp)[names(variables(tmp)) == "Y"][[1]]
#arglist[["fac"]] <- VariableList(variables(tmp)[names(variables(tmp)) %in% c("A","B")])
#arglist[["family"]] <- .SimDatGetDistributionFromName("normal")
#dat <- do.call("GlmWizardDf",args=arglist)
#mod <- GamlssModelFromGlmWizardDf(dat)




#.jpackage("simdat-gui", lib.loc="/home/maarten/Dropbox/simdat-gui/simdat/dist/simdat.jar")
#.jaddClassPath("/home/maarten/Dropbox/simdat-gui/simdat/dist/simdat.jar")

#.simdat<-.jnew("simdat.SimDat",TRUE)

#.deducer<-.jnew("deducer.Deducer",TRUE)


