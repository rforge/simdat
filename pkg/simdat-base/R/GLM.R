setClass("GLM",
  contains="SimDatModel")

GLM <- function(factors=data.frame(A=factor(c(1,1,2,2),labels=c("A1","A2")),B=factor(c(1,2,1,3),labels=c("B1","B2","B3"))),covariates=VariableList(list(RandomIntervalVariable(numeric(sum(N)),digits=8,min=-Inf,max=Inf,name="X"))),covariateModels=ModelList(list(NormalModel(mean=0,sd=1))),N=c(15,15,15,15),mu=c(0,1,2,3),sigma=c(2,2,2,2),nu=NULL,tau=NULL,beta=c(1,1,1,1),DV=list(name="Y",min=-Inf,max=Inf,digits=8),family=NO()) {
  tmp <- GLM_create(factors=factors,covariates=covariates,covariateModels=covariateModels,N=N,mu=mu,sigma=sigma,nu=nu,tau=tau,beta=beta,DV=DV,family=family)
  return(as(tmp,"GLM"))
}


