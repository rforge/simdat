setClass("Regression",
  contains="GLM")

Regression <- function(DV,family=NO(),predictors,predictorModels,N,mu,sigma,nu,tau,beta) {
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

