setClass("SimDatUnivariate",
  contains="SimDatSkeleton"
)


setMethod("simulate",signature(object="SimDatANOVA"),
  function(object,nsim=1,seed,exact=FALSE,...) {
    # check that object is actually univariate
    if(length(object@DVs)!=1) stop("invalid object")
    N <- object@N
    DV <- object@DVs[[1]]
    design <- as.data.frame(apply(object@design.frame,2,rep,times=N))
    if(isMetric(DV)) {
      if((DV@min != -Inf) | (DV@max != Inf)) {
        y <- rtnorm(sum(N),mean=rep(object@mu,times=N),sd=rep(sqrt(object@sigma),times=N),lower=DV@min,upper=DV@max)
      } else {
        y <- rnorm(sum(N),mean=rep(object@mu,times=N),sd=rep(sqrt(object@sigma),times=N))
      }
      y <- round(y,digits=DV@digits)
      if(exact) {
        if(DV@digits != 8) warning("exact simulation will not work with limited precision DV")
        if(DV@min > -Inf | DV@max < Inf) warning("exact simulation may not work with constrained range of DV")
        
        ok <- FALSE
        vars <- aggregate(y,by=design,var)
        vars <- vars[,ncol(vars)]
        b <- rep(sqrt(object@sigma/vars),times=N)
        means <- aggregate(y*b,by=design,mean)
        means <- means[,ncol(means)]
        a <- rep(object@mu-means,times=N)
        while(!ok) {
          y[y*b + a < DV@min] <- ((DV@min - a)/b)[y*b + a < DV@min]
          y[y*b + a > DV@max] <- ((DV@max - a)/b)[y*b + a > DV@max]
          
          vars <- aggregate(y,by=design,var)
          vars <- vars[,ncol(vars)]
        
          b <- rep(sqrt(object@sigma/vars),times=N)
          means <- aggregate(y*b,by=design,mean)
          means <- means[,ncol(means)]
          a <- rep(object@mu-means,times=N)
          
          if(length(y[y*b + a < DV@min | y*b + a > DV@max]) == 0) ok <- TRUE
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
      y <- round(y,digits=DV@digits)
    } else {
      stop("non metric DV not implemented yet")
    }
    #assign(object@DVs[[1]]@name,y)
    design[,object@DVs[[1]]@name] <- y
    #do.call("cbind",args=list(design,object@DVs[[1]]@name))
    return(design)
  }
)
