setClass("SimDatLM",
  contains="SimDatSkeleton",
  representation(
    formula="formula",
    #designFixed
    coefficients="numeric"
  )
)

setClass("SimDatUnivariateLM",
  contains="SimDatLM"
)

setMethod("designData",signature(object="SimDatLM"),
  function(object,...) {
    designData <- list()
    for(i in 1:ncol(object@designFixed)) {
      designData[[i]] <- factor(rep(object@designFixed[,i],object@N),labels=labels(object@designVarsFixed)[[i]])
    }
    designData <- as.data.frame(designData)
    colnames(designData) <- names(object@designVarsFixed)
    return(designData) 
  }
)

setMethod("model.matrix",signature(object="SimDatLM"),
  function(object,...) {
    designData <- designData(object,...)
    tForm <- object@formula
    tForm[[2]] <- NULL # don't need dependent just now
    
    if(length(object@designVarsRandom) > 0) {
      # TODO: need to simulate this data now!
    }
    mat <- model.matrix(tForm,designData)
    return(mat)
  }
)


setMethod("simulate",signature(object="SimDatUnivariateLM"),
  function(object,nsim=1,seed,exact=FALSE,...) {
    # check that object is actually univariate
    #if(length(object@dependentVars)!=1) stop("invalid object")
    
    # simulate random variables
    outData <- vector("list",length=nsim)
    gen <- unique(object@distributionGeneration)
    gen <- gen[order(gen)]
    for(i in 1:nsim) {
        for(g in 1:length(gen)) {
            ids <- which(object@distributionGeneration==gen[g])
            for(d in ids) {
                object@random[[d]] <- simulate(object@random[[d]],distribution=object@distribution[[object@distributionID[d]]])
            }
        }
        #outData[[i]] <- getData(object)
    }
    #TODO:exact replication
  return(object)
  }
)

exact <- function() {
      if(exact) {
        if(digits(DV) != 8) warning("exact simulation will not work with limited precision DV")
        if(min(DV) > -Inf | max(DV) < Inf) warning("exact simulation may not work with constrained range of DV")
        
        ok <- FALSE
        vars <- aggregate(y,by=design,var)
        vars <- vars[,ncol(vars)]
        b <- rep(sqrt(object@sigma/vars),times=N)
        means <- aggregate(y*b,by=design,mean)
        means <- means[,ncol(means)]
        a <- rep(object@mu-means,times=N)
        while(!ok) {
          y[y*b + a < min(DV)] <- ((min(DV) - a)/b)[y*b + a < min(DV)]
          y[y*b + a > max(DV)] <- ((max(DV) - a)/b)[y*b + a > max(DV)]
          
          vars <- aggregate(y,by=design,var)
          vars <- vars[,ncol(vars)]
        
          b <- rep(sqrt(object@sigma/vars),times=N)
          means <- aggregate(y*b,by=design,mean)
          means <- means[,ncol(means)]
          a <- rep(object@mu-means,times=N)
          
          if(length(y[y*b + a < min(DV) | y*b + a > max(DV)]) == 0) ok <- TRUE
        }
        
        # transform sds
        vars <- aggregate(y,by=design,var)
        vars <- vars[,ncol(vars)]
        y <- y*rep(sqrt(object@sigma/vars),times=N)
        # transform means
        means <- aggregate(y,by=design,mean)
        means <- means[,ncol(means)]
        y <- y + rep(object@mu-means,times=N)
      }
}

#setMethd

