setMethod("addVariable","SimDatModel",
  function(object,variable,idx=NULL,env=parent.env(),...) {
    name <- deparse(substitute(object))
    if(!is(variable,"simdat-base::Variable")) stop("variable not valid")
    if(!is.null(idx) & idx > 0) {
      variables(object) <- VariableList(append(variables(object),variable,after=idx-1))
    } else {
      variables(object) <- VariableList(append(variables(object),variable))
    }
  assign(name,object,envir=env,...)
  return(invisible())
  }
)

setMethod("deleteVariable","SimDatModel",
  function(object,idx,env=parent.env(),...) {
    name <- deparse(substitute(object))
    if(idx > 0 & idx <= length(variables(object))) {
      variables(object) <- variables(object)[-idx]
      assign(name,object,envir=env,...)
    } else {
      stop("idx given not valid")
    }
  return(invisible())
  }
)

setMethod("replaceVariable","SimDatModel",
  function(object,variable,idx,env=parent.env(),...) {
    name <- deparse(substitute(object))
    if(!is(variable,"simdat-base::Variable")) stop("variable not valid")
    if(idx > 0 & idx <= length(variables(object))) {
      vars <- variables(object)
      vars[[idx]] <- variable
      variables(object) <- vars
      assign(name,object,envir=env,...)
    } else {
      stop("idx given not valid")
    }
  return(invisible())
  }
)

setMethod("setValueAt","SimDatModel",
  function(object,value,data_row,data_column,env=as.environment(1),...) {
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
