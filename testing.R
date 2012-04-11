# Test Anova wizard
source("~/Documents/RForge/simdat/sourcing.R")

tmp2 <- rmANOVA()

tmp <- ANOVA()


tmp <- addVariable(tmp,new("IntervalVariable",rep(NA,nrow(getData(tmp))),name="Z"))
tmp <- replaceVariable(tmp,new("RandomIntervalVariable",rep(NA,nrow(getData(tmp))),name="Z",min=-10,max=10),idx=4)
getData(simulate(tmp))
.ModVarsSimDatModelModel(tmp)
names(.ModVarsSimDatModelModel(tmp))
is(models(tmp)[[2]])[1]



simdat.gui.env <- new.env()
evalq(tmp <- ANOVA(),env=simdat.gui.env)
evalq(levels(variables(tmp)[[1]]) <- c("A11","A22","A33"),env=simdat.gui.env)
evalq(levels(variables(tmp)[[1]]),env=simdat.gui.env)


class(as(variables(tmp,"Y"),"NominalVariable"))

tmp <- simulate(tmp)

arglist <- list()
arglist[["dep"]] <- variables(tmp)[names(variables(tmp)) == "Y"][[1]]
arglist[["fac"]] <- VariableList(variables(tmp)[names(variables(tmp)) %in% c("A","B")])
arglist[["family"]] <- .SimDatGetDistributionFromName("normal")
df <- df.save <- do.call("GlmWizardDf",args=arglist)

getData(simulate(SimDatModelFromGlmWizardDf(df=df,model_name="tmp")))
getData(simulate(SimDatModelFromGlmWizardDf(df=df,model=tmp)))

df$sigma[1] <- .00001
getData(simulate(SimDatModelFromGlmWizardDf(df=df,model_name="tmp")))
df$mu[1] <- 1000
getData(simulate(SimDatModelFromGlmWizardDf(df=df,model_name="tmp")))
df$n <- rep(1,6)
getData(simulate(SimDatModelFromGlmWizardDf(df=df,model_name="tmp")))
tmp <- simulate(SimDatModelFromGlmWizardDf(df=df,model_name="tmp"))

simdat.gui.env$df <- df
evalq(tmp <- SimDatModelFromGlmWizardDf(df=df,model=tmp),env=simdat.gui.env)
evalq(getData(simulate(SimDatModelFromGlmWizardDf(df=df,model=tmp))),env=simdat.gui.env)

#getData(simulate(tmp))


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
