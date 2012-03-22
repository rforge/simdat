setMethod("addVariable",signature(object="SimDatModel",variable="Variable"),
  function(object,variable,idx=NULL,env=parent.frame(),...) {
  #function(object,variable,idx=NULL,env=parent.frame(),...) {
    #name <- deparse(substitute(object))
    #if(!is(variable,"simdat-base::Variable")) stop("variable not valid")
    #if(!is(variable,"Variable")) stop("variable not valid")
    if(!is.null(idx) && idx > 0) {
      if(isRandom(variable)) {
        object@modelID <- append(object@modelID,length(object@models) + 1,after=idx-1)
        object@models <- ModelList(c(object@models,list(new("UniformModel"))))
      } else {
        object@modelID <- append(object@modelID,0,after=idx-1)
      }
      if(idx==1) {
       tstruc <- cbind(0,object@structure)
       tstruc <- rbind(0,tstruc)
       object@structure <- tstruc
      } else if(idx > ncol(object@structure)) {
        tstruc <- cbind(object@structure,0)
        tstruc <- rbind(tstruc,0)
        object@structure <- tstruc
      } else {
        tstruc <- cbind(object@structure[,1:(idx-1)],0,object@structure[,idx:ncol(object@structure)])
        tstruc <- rbind(tstruc[1:(idx-1),],0,tstruc[idx:nrow(tstruc),])
        object@structure <- tstruc
      }
      variables(object) <- VariableList(append(variables(object),variable,after=idx-1))
    } else {
      # append at the end
      if(isRandom(variable)) {
        object@modelID <- append(object@modelID,length(object@models) + 1)
        object@models <- ModelList(c(object@models,list(new("UniformModel"))))
      } else {
        object@modelID <- append(object@modelID,0)
      }
      tstruc <- cbind(object@structure,0)
      tstruc <- rbind(tstruc,0)
      object@structure <- tstruc
      variables(object) <- VariableList(append(variables(object),list(variable)))
    }
  #assign(name,object,envir=env,...)
  #return(invisible())
  return(object)
  }
)

setMethod("deleteVariable","SimDatModel",
  function(object,idx,...) {
  #function(object,idx,env=parent.frame(),...) {
    name <- deparse(substitute(object))
    if(idx > 0 & idx <= length(variables(object))) {
      if(object@modelID[idx] != 0) warning("deleting a variable with an assigned model; will delete model too")
      if(sum(object@structure[,idx]) != 0) warning("deleting a variable which occurs in model(s); will delete model(s) too")
      object@modelID <- object@modelID[-idx]
      variables(object) <- variables(object)[-idx]
      assign(name,object,envir=env,...)
    } else {
      stop("idx given not valid")
    }
    return(object)
    #return(invisible())
  }
)

setMethod("replaceVariable","SimDatModel",
  function(object,variable,idx,...) {
  #function(object,variable,idx,env=parent.frame(),...) {
    #name <- deparse(substitute(object))
    #if(!is(variable,"simdat-base::Variable")) stop("variable not valid")
    if(!is(variable,"Variable")) stop("variable not valid")
    if(idx > 0 & idx <= length(variables(object))) {
      vars <- variables(object)
      if(isRandom(vars[[idx]])) wasRandom <- TRUE else wasRandom <- FALSE
      if(isRandom(variable)) nowRandom <- TRUE else nowRandom <- FALSE
      vars[[idx]] <- variable
      if(wasRandom & !nowRandom) {
        object@models[[model@modelID[idx]]] <- NULL
        object@modelID[idx] <- 0
        object@structure[,idx] <- rep(0,nrow(object@structure))
      }
      if(!wasRandom & nowRandom) {
        object@modelID[idx] <- length(object@models) + 1
        object@models <- ModelList(c(object@models,list(new("UniformModel"))))
      }
      variables(object) <- vars
      #assign(name,object,envir=env,...)
      return(object)
    } else {
      stop("idx given not valid")
    }
  #return(invisible())
  }
)

setMethod("setValueAt","SimDatModel",
  #function(object,value,data_row,data_column,env=as.environment(1),...) {
  function(object,value,data_row,data_column,env=parent.frame(),...) {
    name <- deparse(substitute(object))
    # add value 
    dat <- getData(object,...)
    nrow <- nrow(dat)
    ncol <- ncol(dat)
    vname <- colnames(dat)[data_column]
    vid <- which(variableNames(object) == vname)
    var <- variables(object)[[vid]]
    if(data_row >= 1 & data_row <= nrow) {
      if(!isMetric(var)) {
        if(!(value %in% levels(var)) & !is.na(value)) {
          # need to add a level
          cvar <- as.character(var)
          cvar[data_row] <- value
          cvar <- factor(cvar)
          var@levels <- levels(cvar)
          var@.Data <- factor(cvar)
        } else {
          var@.Data[data_row] <- as.integer(which(levels(var) == value))
        }
      } else {
        if(!is.numeric(value) & !is.na(value)) stop("need a numeric value or NA")
        var@.Data[data_row] <- value
      }
    } else {
      stop("need to add a row to data first")
    }
    variables(object)[[vid]] <- var
    assign(name,object,envir=env,...)
    return(invisible())
  }
)

setMethod("removeRow","SimDatModel",
  function(object,idx=NULL,env=parent.env(),...) {
    if(!is.null(idx)) {
        ns <-  unlist(lapply(variables(object),"length"))
        if(!all(ns == ns[1])) stop("variables have unequal length")
        ns <- ns[1]
        #dat <- getData(object,...)
        vars <- variables(object,...)
        if(idx > 0 & idx <= ns) {
            #dat <- dat[,-idx]
            for(i in 1:length(vars)) {
                vars[[i]]@.Data <- (vars[[i]])@.Data[-idx]
            }
            variables(object) <- vars
        }
    } else {
        # do nothing
    }
    return(object)
  }
)

setMethod("insertRow","SimDatModel",
  function(object,idx=NULL,env=parent.env(),...) {
    if(!is.null(idx)) {
        ns <-  unlist(lapply(variables(object),"length"))
        if(!all(ns == ns[1])) stop("variables have unequal length")
        ns <- ns[1]
        #dat <- getData(object,...)
        vars <- variables(object,...)
        if(idx == 1) {
            for(i in 1:length(vars)) {
                vars[[i]]@.Data <- c(NA,vars[[i]]@.Data)
            }
            variables(object) <- vars
        } else if(idx > 1 & idx <= ns) {
            #dat <- dat[,-idx]
            for(i in 1:length(vars)) {
                vars[[i]]@.Data <- c(vars[[i]]@.Data[1:(idx-1)],NA,vars[[i]]@.Data[idx:ns])
            }
            variables(object) <- vars
        }
    } else {
        # do nothing
    }
    return(object)
  }
)
