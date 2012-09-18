setClass("GLM",
  contains="SimDatModel")

GLM <- function(DV,family=NO(),factors,covariates,covariateModels,N,mu,sigma,nu,tau,beta) {
  if(missing(factors) & missing(covariates)) stop("please supply either factors or covariates")
  tmp <- GLM_create(factors=factors,covariates=covariates,covariateModels=covariateModels,N=N,mu=mu,sigma=sigma,nu=nu,tau=tau,beta=beta,DV=DV,family=family)
  return(as(tmp,"GLM"))
}

setMethod("summary",signature(object="GLM"),
    function(object,...,type=c("aov","lm","glm"),SStype=3) {
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

