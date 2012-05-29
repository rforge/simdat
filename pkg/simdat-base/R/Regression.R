setClass("Regression",
  contains="SimDatModel")

Regression <- function(predictors=VariableList(list(RandomIntervalVariable(numeric(sum(N)),digits=8,min=-Inf,max=Inf,name="X"))),predictorModels=ModelList(list(NormalModel(mean=0,sd=1))),N=10,mu=0,sigma=1,nu=NULL,tau=NULL,beta=1,DV=list(name="Y",min=-Inf,max=Inf,digits=8),family=NO()) {
  tmp <- GLM_create(covariates=predictors,covariateModels=predictorModels,N=N,mu=mu,sigma=sigma,nu=nu,tau=tau,beta=beta,DV=DV,family=family)
  return(as(tmp,"GLM"))
}
