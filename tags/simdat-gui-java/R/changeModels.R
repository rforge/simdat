setMethod("addModel","SimDatModel",
  function(object,model,idx=NULL,env=parent.env(),...) {
    name <- deparse(substitute(object))
    if(!is(model,"simdat-base::Model")) stop("model not valid")
    if(!is.null(idx) & idx > 0) {
      models(object) <- ModelList(append(models(object),model,after=idx-1))
    } else {
      models(object) <- ModelList(append(models(object),model))
    }
  assign(name,object,envir=env,...)
  return(invisible())
  }
)

setMethod("deleteModel","SimDatModel",
  function(object,idx,env=parent.env(),...) {
    name <- deparse(substitute(object))
    if(idx > 0 & idx <= length(models(object))) {
      models(object) <- models(object)[-idx]
      assign(name,object,envir=env,...)
    } else {
      stop("idx given not valid")
    }

    #assign(name,object,envir=env,...)
    return(invisible())
  }
)

setMethod("replaceModel","SimDatModel",
  function(object,model,idx,env=parent.env(),...) {
    name <- deparse(substitute(object))
    if(!is(model,"simdat-base::Model")) stop("model not valid")
    if(idx > 0 & idx <= length(models(object))) {
      mods <- models(object)
      mods[[idx]] <- model
      models(object) <- mods
      assign(name,object,envir=env,...)
    } else {
      stop("idx given not valid")
    }
    #assign(name,object,envir=env,...)
    return(invisible())
  }
)
