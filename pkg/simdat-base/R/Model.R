## SimDat models
## used for simulation of random variables

setClass("Model")

#setClass("GlmModel",
#    contains="Model",
#    representation(
#        formula="formula",
#        family="family",
#        coefficients="numeric",
#        parameters=list() # nuisance parameters (e.g., sd)
#    )
#)
setOldClass("gamlss.family")

setClass("ParModel",
   representation(
        formula="formula",
        coefficients="numeric",
    )
)

setClass("VecParModel",
    contains="ParModel"
)

setClass("MatParModel",
    contains="ParModel"
)

setMethod("predict",signature(object="ParModel"),
    function(object,...,data) {
        if(!missing(data)) {
            m <- model.matrix(object@formula,data=data)
        } else {
            m <- model.matrix(object@formula,
        }
        as.numeric(m%*%(object@coefficients))
    }
)

setMethod("predict",signature(object="VecParModel"),
    function(object,...,data) {
        if(!missing(data)) {
            m <- model.matrix(object@formula,data=data)
        } else {
            m <- model.matrix(object@formula,
        }
        m%*%(object@coefficients)
    }
)

setClass("GamlssModel",
    contains="Model",
    representation(
        mu="ParModel",
        sigma="ParModel",
        nu="ParModel",
        tau="ParModel",
        family="gamlss.family"
    )
)

setMethod("simulate",signature(object="GamlssModel"),
    function(object,nsim=1,seed,...,DV,data) {
        npar <- object@family$nopar
        args <- list()
        if(!missing(data)) {
            if(npar > 3) args[["tau"]] <- object@family$tau.linkinv(predict(object@tau),data=data)
            if(npar > 2) args[["nu"]] <- object@family$nu.linkinv(predict(object@nu),data=data)
            if(npar > 1) args[["sigma"]] <- object@family$sigma.linkinv(predict(object@sigma),data=data)
            args[["mu"]] <- object@family$mu.linkinv(predict(object@mu),data=data)
        } else {
            if(npar > 3) args[["tau"]] <- object@family$tau.linkinv(predict(object@tau))
            if(npar > 2) args[["nu"]] <- object@family$nu.linkinv(predict(object@nu))
            if(npar > 1) args[["sigma"]] <- object@family$sigma.linkinv(predict(object@sigma))
            args[["mu"]] <- object@family$mu.linkinv(predict(object@mu))
        }
        args[["n"]] <- length(args$mu)
        if(!missing(DV)) {
            if(isMetric(DV)) {
                min <- min(DV)
                max <- max(DV)
                w <- which(abs(c(min,max)) < Inf)
                if(length(w) > 0) {
                    # have to truncate
                    if(length(w) == 2) {
                        type <- "both"
                        range <- c(min,max)
                    } else {
                        if(w == 1) {
                            type <- "left
                            range <- min
                        } else {
                            type <- "right"
                            range <- max
                        }
                    }
                    rfun <- trun.r(range,family=object@family[1],type=type)
                    out <- do.call(rfun,args=args)
                } else {
                    # no truncation
                    out <- do.call(paste("r",object@family[1],sep=""),args=args)
                }
                out <- round(out,digits=object@digits)
            } else {
                # no truncation for non-metric variables
                out <- do.call(paste("r",object@family[1],sep=""),args=args)
            }
            DV@.Data <- out
        } else {
            DV <- do.call(paste("r",object@family[1],sep=""),args=args)
        }
        return(DV)
    }
)

setClass("MvnormModel",
    contains="Model",
    representation(
        mu="VecParModel",
        sigma="MatParModel"
    )
)

setClass("ModelList",
  contains="list"
)

setValidity("ModelList",
  method=function(object) {
    all(lapply(object,function(x) is(x,"Model"))==TRUE)
  }
)

