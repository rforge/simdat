setClass("SimDatModel",
    representation(
        name="character",
        variables="VariableList",
        models="ModelList",
        modelID="numeric", # vector with model indicators (0 is for fixed variables)
        structure="matrix"
    )
)

setValidity("SimDatModel",
  method=function(object) {
    nvar <- length(object@variables)
    if(ncol(object@structure)!=nvar | nrow(object@structure) != nvar) return(FALSE)
    if(length(object@models)!=length(unique(object@modelID[object@modelID > 0]))) return(FALSE)
    if(!all(object@structure %in% c(0,1))) return(FALSE)
    if(!isDAG(object@structure)) return(FALSE)
    # add more checks here
    # needs check that multivariate models have no interdependencies in graph!
  }
)


setMethod("simulate",signature(object="SimDatModel"),
    function(object,nsim=1,seed,...) {
        # order the models for simulation
        vorder <- topOrderGraph(object@structure)
        #nrep <- table(object@modelID)
        #multivar <- as.numeric(names(nrep[nrep>1]))
        
        #morder <- unique(object@modelID[vorder])
        
        #random <- (1:length(variables))[unlist(lapply(object@variables,isRandom))]
        #nrep <- table(object@modelID)
        #multivar <- as.numeric(names(nrep[nrep>1]))
        
        
        if(nsim > 1) {
            # use recursive programming
            out <- list()
            for(i in 1:nsim) {
                mod <- simulate(object,nsim=1,seed=seed,...)
                out[[i]] <- getData(mod,...)
            }
            return(out)
        } else {
            for(mod in morder) {
                 vars <- which(object@modelID == mod)
                 if(length(vars) > 1) DV <- object@variables[vars] else DV <- object@variables[[vars]]
                 IV <- which(rowSums(object@structure[,vars]) > 0)
                 if(length(IV) > 0) {
                    dat <- as.data.frame(object@variables)[,IV]
                    out <- simulateFromModel(DV,model=models[[mod]],nsim=nsim,seed=seed,data=dat,...)
                 } else {
                    out <- simulateFromModel(DV,model=models[[mod]],nsim=nsim,seed=seed,...)
                 }
                 
                 # now set the data in dat to the correct variables
                 if(is(out,"VariableList") | is(out,"Variable")) {
                    for(i in vars) object@variables[[i]] <- out[[i]]
                 } else {
                 # probably didn't get the correct format back; but let's try...
                     warning("simulate method in model ",mod," did not return an object of class Variable")
                     if(is.matrix(out) | is.data.frame(out)) {
                        if(ncol(out) > 1) {
                            # multivariate data
                            vnames <- colnames(out)
                            for(i in vnames) {
                                object@variables[[i]]@.Data <- out[,i]
                            }
                        }
                     } else {
                        object@variables[[vars]]@.Data <- out
                     }
                }
            }
        }
        object
    }
)

setMethod("getData","SimDatModel",
    function(object,...) {
        dat <- as.data.frame(object@variables)
        colnames(dat) <- names(object@variables)
        dat
    } 
)

setMethod("variableNames","SimDatModel",
    function(object,...) {
        names(object@variables)
    }
)

setReplaceMethod("variableNames","SimDatModel",
    function(object,value,...) {
        if(length(value) != length(object@variables)) {
            stop("need correct length to replace names")
        } else {
            names(object@variables) <- value
        }
        return(object)
    }
)

setMethod("models","SimDatModel",
  function(object,...) {
    object@models
  }
)

setReplaceMethod("models","SimDatModel",
  function(object,value,...) {
    if(!is(value,"ModelList")) {
      stop("cannot replace models; need a ModelList")
    } else {
      object@models <- value
    }
  }
)

