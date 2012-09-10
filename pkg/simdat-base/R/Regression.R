setClass("Regression",
  contains="GLM")

Regression <- function(predictors=VariableList(list(RandomIntervalVariable(numeric(sum(N)),digits=8,min=-Inf,max=Inf,name="X"))),predictorModels=ModelList(list(NormalModel(mean=0,sd=1))),N=10,mu=0,sigma=1,nu=NULL,tau=NULL,beta=1,DV=list(name="Y",min=-Inf,max=Inf,digits=8),family=NO()) {
  tmp <- GLM_create(covariates=predictors,covariateModels=predictorModels,N=N,mu=mu,sigma=sigma,nu=nu,tau=tau,beta=beta,DV=DV,family=family)
  return(as(tmp,"Regression"))
}


setMethod("summary",signature(object="Regression"),
    function(object,...,type=c("lm","aov","glm"),SStype=3) {
        type <- match.arg(type)
        vars <- variables(object,...)
        fixed <- VariableList(vars[!isRandom(vars)])
        random <- VariableList(vars[isRandom(vars)])
        for(i in 1:length(random)) {
            n <- aggregate(random[i],by=fixed,FUN=length)
            means <- aggregate(random[i],by=fixed,FUN=mean)
            vars <- aggregate(random[i],by=fixed,FUN=var)
            out <- cbind(n,means[,ncol(means)],sqrt(vars[,ncol(vars)]))
            colnames(out) <- c(variableNames(fixed),"n","mean","sd")
            cat("Variable ",variableNames(random)[[i]],": \n",sep="")
            print(out)
            cat("\n")
        }
        models <- ModelList(models(object))
        for(i in 1:length(models)) {
            summ <- summary(models[[i]],data=getData(object),type=type,SStype=SStype,...)
            if(!is.null(summ)) {
                cat("Variable ",variableNames(object)[which(object@modelID == i)],": \n",sep="")
                print(summ)
            }
        }
    }
)

