# Test Anova wizard
source("~/Documents/RForge/simdat/sourcing.R")
simdat.gui.env <- new.env()
evalq("tmp <- ANOVA()",env=simdat.gui.env)
as(variables(tmp,"Y"),"NominalVariable")

simulate(tmp)

arglist <- list()
arglist[["dep"]] <- variables(tmp)[names(variables(tmp)) == "Y"][[1]]
arglist[["fac"]] <- VariableList(variables(tmp)[names(variables(tmp)) %in% c("A","B")])
arglist[["family"]] <- .SimDatGetDistributionFromName("normal")
df <- do.call("GlmWizardDf",args=arglist)

tmp <- SimDatModelFromGlmWizardDf(df=df)
getData(simulate(tmp))


SDGE <- new.env()
evalq(tmp2 <- ANOVA(),envir = SDGE)
evalq(.getSimDatModels(),envir = SDGE)
evalq(!is.null(tmp2),envir = SDGE)
evalq(arglist <- list(),envir = SDGE)
evalq(arglist[["dep"]] <- variables(tmp)[names(variables(tmp)) == "Y"][[1]],envir=SDGE)
evalq(arglist[["fac"]] <- VariableList(variables(tmp)[names(variables(tmp)) %in% c("A","B")]),envir=SDGE)
evalq(arglist[["family"]] <- .SimDatGetDistributionFromName("normal"),envir=SDGE)
evalq(df <- do.call("GlmWizardDf",args=arglist),envir = SDGE)
evalq(!is.null(df),envir=SDGE)

df$mu <- rnorm(nrow(df))
gamlssmod <- GamlssModelFromGlmWizardDf(df)
mod <- new("SimDatModel")
vars <- list()
DV <- new("RandomIntervalVariable",
      rep(0.0,sum(df$n)),
      name = df@dependent,
      min = -Inf,
      max = Inf)
if(!is.null(df$mu)) DV@.Data <- rep(df$mu,times=df$n)
vars <- c(vars,list(DV))
if(length(df@factor)>0) {
  for(i in 1:length(df@factor)) {
    vars <- c(vars,list(new("NominalVariable",rep(df[,df@factor[i]],times=df$n),name=df@factor[i])))
  }
}
if(length(df@numeric)>0) {
  for(i in 1:length(df@numeric)) {
    vars <- c(vars,list(new("IntervalVariable",rep(0,times=sum(df$n)),name=df@numeric[i])))
  }
}
mod@variables <- VariableList(vars)
mod@models <- ModelList(list(gamlssmod))
mod@modelID <- rep(0,length(vars))
mod@modelID[which(names(mod@variables) == df@dependent)] <- 1
mod@structure <- matrix(0,ncol=length(mod@variables),nrow=length(mod@variables))
mod@structure[-which(mod@modelID == 1),which(mod@modelID == 1)] <- 1

getData(simulate(mod))

object <- mod@variables[[1]]
model <- mod@models[[1]]
data <- getData(mod)
for(i in 1:ncol(data)) {
    if(isMetric(data[,i])) data[,i] <- as.numeric(data[,i]) else data[,i] <- as.factor(data[,i])
}
predict(model@mu@formula,data=data)
