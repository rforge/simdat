# Test Anova wizard
source("~/Documents/RForge/simdat/sourcing.R")

tmp <- ANOVA()

facList <- variables(tmp,c("A","B"))
depList <- variables(tmp,"Y")
fam <- NO()
awm <- AnovaWizardModel(dep=depList,fac=facList,fam=fam)
gmlssdf <- getWizardDf(awm)
tmp2 <- makeSimDatModel(awm,gmlssdf)

bfacList <- VariableList(list(variables(tmp,c("A"))))
wfacList <- VariableList(list(variables(tmp,c("B"))))
depList <- variables(tmp,"Y")
fam <- NO()
awm <- RmAnovaWizardModel(dep=depList,bfac=bfacList,wfac=wfacList,fam=fam)
gmlssdf <- getWizardDf(awm,which="between")
withinDf <- getWizardDf(awm,which="within")
tmp2 <- makeSimDatModel(awm,gmlssdf,withinDf)






tmp2 <- ANOVA(DV=tmp@variables[[3]])

arglist <- list()
arglist[["dep"]] <- variables(tmp,c("Y"))
arglist[["bfac"]] <-  variables(tmp,c("A"))
arglist[["wfac"]] <-  variables(tmp,c("B"))
arglist[["family"]] <- .SimDatGetDistributionFromName("normal")
df <- df.save <- do.call("RmAnovaWizardDf",args=arglist)

tmp2 <- rmANOVA(N=rep(1000,4))
cov(getData(simulate(tmp2))[,4:7])

tmp <- RmAnovaWizardDf(dep=new("RandomIntervalVariable",name="Y"),wfac=VariableList(list(new("NominalVariable",factor(c(1,2),labels=c("V1","V2")),name="V"),new("NominalVariable",factor(c(1,2),labels=c("W1","W2")),name="W"))),bfac=VariableList(list(new("NominalVariable",factor(c(1,2),labels=c("A1","B2")),name="A"),new("NominalVariable",factor(c(1,2),labels=c("A1","B2")),name="B"))),mu=1,sigma=3)
SimDatModelFromRmAnovaWizardDf(tmp,model=tmp2)





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
