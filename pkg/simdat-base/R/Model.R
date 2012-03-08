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

setClass("ParModel",
   representation(
        formula="formula",
        coefficients="vector" # vector or (column) matrix
    )
)

setMethod("isRandom","ParModel",
    function(object,...) {
        FALSE
    }
)

setClass("RandomParModel",
   contains="ParModel",
   representation(
        #random.formula="formula", # formula specifying random effects models
        #random.coefficients = "matrix", # matrix with random coefficients
        grouping="numeric", # index variable for grouping levels (repetitions) of random coefficients
        sigma="array" # ncol(coeff) * ncol(coeff) * (1 | unique(grouping)) array with covariance matrices for random coefficients
    )
)

setMethod("isRandom","RandomParModel",
    function(object,...) {
        TRUE
    }
)

#setMethod("simulate",signature(object="Variable",model="RandomParModel"),
#  function(object,nsim=1,seed,model,...) {
#    object
#  }
#)

setMethod("simulate",signature(object="RandomParModel"),
  function(object,nsim=1,seed,...) {
    ns <- dim(object@sigma)[3]
    nc <- dim(object@sigma)[1]
    if(!is.matrix(object@coefficients)) {
      if(length(object@coefficients == nc)) {
        ng <- 1
        coeff <- as.numeric(rmvnorm(ng,mean=rep(0,nc),sigma=object@sigma[,,1]))
      } else {
        if(nc == 1) {
          ng <- length(object@coefficients)
          coeff <- rnorm(ng,mean=0,sd=as.numeric(sqrt(object@sigma[1,1,])))
        } else {
          stop("coefficients doesn't seem to have the correct size")
        }
      }
      
    } else {
      coeff <- object@coefficients
      ng <- nrow(coeff)
      if(nc > 1) {
        if(ns > 1) {
          if(ns == ng) {
            for(i in 1:ng) {
              coeff[i,] <-  rmvnorm(1,mean=rep(0,nc),sigma=object@sigma[,,i])
            }
          } else {
            stop("size of sigma doesn't match grouping")
          }
        } else {
          coeff <- rmvnorm(ng,mean=rep(0,nc),sigma=object@sigma[,,1])
        }
      } else {
        if(ncol(coeff) == 1) {
          coeff <- matrix(rnorm(ng,mean=0,sd=sqrt(object@sigma[1,1,])),ncol=1)
        } else {
          stop("sigma is a 1 by 1 matrix, but coefficients has more than 1 column")
        }
      }
    }
  object@coefficients <- coeff
  object
  }
)

setClass("MixedParModel",
  contains="ParModel",
  representation(
    random="RandomParModel"
  )
)

setMethod("simulate",signature(object="MixedParModel"),
  function(object,nsim=1,seed,...) {
    call <- match.call()
    args <- as.list(call[2:length(call)])
    args[["object"]] <- object@random
    object@random <- do.call("simulate",args=args)
    object
  }
)

setMethod("isRandom","MixedParModel",
    function(object,...) {
        TRUE
    }
)

setClass("RandomParModelList",
  contains="list"
)

setMethod("isRandom","RandomParModelList",
    function(object,...) {
         any(unlist(lapply(object,isRandom)))
    }
)

RandomParModelList <- function(list) {
  if(!is.list(list)) stop("argument is not a list")
  else {
    out <- new("RandomParModelList",
      .Data <- list)
  }
  out
}

setValidity("RandomParModelList",
  method=function(object) {
    any(unlist(lapply(object,function(x) is(x,"RandomParModel"))==TRUE))
  }
)

setClass("MultilevelParModel",
  contains="ParModel",
  representation(
    random="RandomParModelList"
  )
)

setMethod("isRandom","MultilevelParModel",
    function(object,...) {
         isRandom(object@random,...)
    }
)

setClass("VecParModel",
    contains="ParModel"
)

setClass("MatParModel",
    contains="ParModel"
)

setMethod("predict",signature(object="ParModel"),
    function(object,...,data,na.action = c("exclude","pass")) {
        na.action <- match.arg(na.action)
        if(!missing(data)) {
            m <- model.matrix(object@formula,...,data=data)
        } else {
            m <- model.matrix(object@formula,...)
        }
        #TODO: don't know if this is general enough!
        coeff <- object@coefficients
        excl <- is.na(coeff)
        if(sum(excl) > 0 & na.action=="exclude") {
            m <- m[,!excl]
            coeff <- coeff[!excl]
        }
        as.numeric(m%*%coeff)
    }
)

setMethod("predict",signature(object="RandomParModel"),
    function(object,...,data) {
        if(!missing(data)) {
            m <- model.matrix(object@formula,data=data)
        } else {
            m <- model.matrix(object@formula)
        }
        if(is.matrix(object@coefficients)) out <- rowSums(m*object@coefficients[object@grouping,]) else out <- rowSums(m*object@coefficients[object@grouping])
        out
    }
)

setMethod("predict",signature(object="MixedParModel"),
   function(object,...,data) {
        #call <- match.call()
        #args[[1]] <- NULL
        #args <- as.list(args)
        #args <- as.list(call[2:length(call)])
        #fp <- do.call("callNextMethod",args=args)
        if(!missing(data)) {
          fp <- callNextMethod(object=object,data=data,...)
          rp <- predict(object@random,data=data,...)
        } else {
          fp <- callNextMethod(object=object,...)
          rp <- predict(object@random,...)
        }
        #rp
        rp + fp
        #call
    }
)

setMethod("predict",signature(object="VecParModel"),
    function(object,...,data) {
        if(!missing(data)) {
            m <- model.matrix(object@formula,data=data)
        } else {
            m <- model.matrix(object@formula)
        }
        m%*%(object@coefficients)
    }
)

setOldClass("gamlss.family")

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

setMethod("simulateFromModel",signature(object="Variable",model="MixedParModel"),
  function(object,model,nsim=1,seed,...,data) {
    call <- match.call()
    args <- as.list(call[2:length(call)])
    DV <- do.call("simulate",args=args)
    DV
  }
)


# TODO: for consistency, should really simulate a DV, with a model as argument
setMethod("simulateFromModel",signature(object="Variable",model="GamlssModel"),
    function(object,model,nsim=1,seed,...,data) {
        npar <- model@family$nopar
        args <- list()
        if(!missing(data)) {
            if(npar > 3) args[["tau"]] <- model@family$tau.linkinv(predict(model@tau,data=data))
            if(npar > 2) args[["nu"]] <- model@family$nu.linkinv(predict(model@nu,data=data))
            if(npar > 1) args[["sigma"]] <- model@family$sigma.linkinv(predict(model@sigma,data=data))
            args[["mu"]] <- model@family$mu.linkinv(predict(model@mu,data=data))
        } else {
            if(npar > 3) args[["tau"]] <- model@family$tau.linkinv(predict(model@tau))
            if(npar > 2) args[["nu"]] <- model@family$nu.linkinv(predict(model@nu))
            if(npar > 1) args[["sigma"]] <- model@family$sigma.linkinv(predict(model@sigma))
            args[["mu"]] <- model@family$mu.linkinv(predict(model@mu))
        }
        args[["n"]] <- length(object) #else args[["n"]] <- length(args$mu)
        #if(!missing(DV)) {
            if(isMetric(object)) {
                min <- min(object)
                max <- max(object)
                w <- which(abs(c(min,max)) < Inf)
                if(length(w) > 0) {
                    # have to truncate
                    if(length(w) == 2) {
                        type <- "both"
                        range <- c(min,max)
                    } else {
                        if(w == 1) {
                            type <- "left"
                            range <- min
                        } else {
                            type <- "right"
                            range <- max
                        }
                    }
                    rfun <- trun.r(range,family=model@family$family[1],type=type)
                    out <- do.call(rfun,args=args)
                } else {
                    # no truncation
                    out <- do.call(paste("r",model@family$family[1],sep=""),args=args)
                }
                if(length(object@digits) > 0) out <- round(out,digits=object@digits)
            } else {
                # no truncation for non-metric variables
                out <- do.call(paste("r",model@family$family[1],sep=""),args=args)
            }
            object@.Data <- out
        #} else {
        #    DV <- do.call(paste("r",object@family$family[1],sep=""),args=args)
        #}
        return(object)
    }
)

setClass("GammlssModel",
    contains="GamlssModel"#,
    #representation(
    #    mu="ParModel",
    #    sigma="ParModel",
    #    nu="ParModel",
        #nu.random="ParModel",
    #    tau="ParModel",
    #    family="gamlss.family"
    #)
)

setMethod("simulate",signature(object="GammlssModel"),
  function(object,nsim=1,seed,...) {
    # simulate random coefficients
    call <- match.call()
    args <- as.list(call[2:length(call)])
    #targs <- args
    #targs[["object"]] <- NULL
    if(isRandom(object@mu)) object@mu <- do.call("simulate",args=c(object=object@mu,args))
    if(isRandom(object@sigma)) object@sigma <- do.call("simulate",args=c(object=object@sigma,args))
    if(isRandom(object@nu)) object@nu <-  do.call("simulate",args=c(object=object@nu,args))
    if(isRandom(object@tau)) object@tau <-  do.call("simulate",args=c(object=object@tau,args))
    object
    #DV <- do.call("callNextMethod",args=args)
    #DV
  }
)


setClass("MvnormModel",
    contains="Model",
    representation(
        mu="VecParModel",
        sigma="array",
        sigmaID="numeric"
    )
)

setMethod("simulateFromModel",signature(object="Variable",model="MvnormModel"),
    function(object,model,nsim=1,seed,...,DV,data) {
      if(!missing(data)) mu <- predict(object@mu,data=data,...) else mu <- predict(object@mu,...)
      if(is(DV,"VariableList")) {
        nDV <- length(DV)
        # check for truncation
        #trunc <- FALSE
        trunc.points <- matrix(NA,ncol=2,nrow=length(DV))
        for(i in 1:nDV) {
          trunc.points[i,] <- c(min(DV[[i]]),max(DV[[i]]))
        }
        if(any(abs(trunc.points) < Inf)) {
          # need a truncated MV normal
          for(i in unique(object@sigmaID)) out[object@sigmaID==i,] <- rtmvnorm(nrow(mu),mean=rep(0,ncol(mean)),sigma=object@sigma[,,i])
        } else {
          for(i in unique(object@sigmaID)) out[object@sigmaID==i,] <- rmvnorm(nrow(mu),mean=rep(0,ncol(mean)),sigma=object@sigma[,,i])
        }
      } else {
        if(is(DV,"Variable")) {
        
        } else {
          stop("DV should be a VariableList or Variable")
        }
      }
    }
)



setClass("ModelList",
  contains="list"
)

ModelList <- function(list) {
  if(!is.list(list)) stop("argument is not a list")
  else {
    out <- new("ModelList",
      .Data <- list)
  }
  out
}

setValidity("ModelList",
  method=function(object) {
    all(lapply(object,function(x) is(x,"Model"))==TRUE)
  }
)
