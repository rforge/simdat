setClass("NominalVariable",
  contains="factor",
  representation(
    name="character"
  )
)

setClass("RandomNominalVariable",
    contains="NominalVariable"
)

NominalVariable <- function(data=factor(),name) {
  if(!is.factor(data)) data <- as.factor(data)
  if(missing(name)) stop("need to supply a name")
  return(new("NominalVariable",data,name=name))
}

RandomNominalVariable <- function(data=factor(),name) {
  if(!is.factor(data)) data <- as.factor(data)
  if(missing(name)) stop("need to supply a name")
  return(new("RandomNominalVariable",data,name=name)) 
}

setClass("OrdinalVariable",
  contains="ordered",
  representation(
    name="character"
  )
)

setClass("RandomOrdinalVariable",
    contains="OrdinalVariable"
)

OrdinalVariable <- function(data=ordered(),name) {
  if(!is.ordered(data)) data <- as.ordered(data)
  if(missing(name)) stop("need to supply a name")
  return(new("OrdinalVariable",data,name=name))
}

RandomOrdinalVariable <- function(data=ordered(),name) {
  if(!is.ordered(data)) data <- as.ordered(data)
  if(missing(name)) stop("need to supply a name")
  return(new("RandomOrdinalVariable",data,name=name)) 
}

setClass("IntervalVariable",
  contains="numeric",
  representation(
    name="character",
    digits="integer"#,
    #min="numeric",
    #max="numeric"
  )
)

setClass("RandomIntervalVariable",
    contains="IntervalVariable",
    representation(
        min="numeric",
        max="numeric"
    )
)

IntervalVariable <- function(data=numeric(),name,digits=getOption('digits')) {
  if(!is.numeric(data)) data <- as.numeric(data)
  if(missing(name)) stop("need to supply a name")
  if(!is.integer(digits)) digits <- as.integer(digits)
  return(new("IntervalVariable",data,name=name,digits=digits))
}

RandomIntervalVariable <- function(data=numeric(),name,digits=getOption('digits'),min=-Inf,max=Inf) {
  if(!is.numeric(data)) data <- as.numeric(data)
  if(missing(name)) stop("need to supply a name")
  if(!is.integer(digits)) digits <- as.integer(digits)
  return(new("RandomIntervalVariable",data,name=name,digits=digits,min=min,max=max))
}

setClass("RatioVariable",
  contains="IntervalVariable"
)

setClass("RandomRatioVariable",
    contains="RandomIntervalVariable"
)


RatioVariable <- function(data=numeric(),name,digits=getOption('digits')) {
  if(!is.numeric(data)) data <- as.numeric(data)
  if(missing(name)) stop("need to supply a name")
  if(!is.integer(digits)) digits <- as.integer(digits)
  if(!is.numeric(min)) stop("need a numerical minimum")
  if(!is.numeric(max)) stop("need a numerical maximum")
  return(new("RatioVariable",data,name=name,digits=digits))
}

RandomRatioVariable <- function(data=numeric(),name,digits=getOption('digits'),min=-Inf,max=Inf) {
  if(!is.numeric(data)) data <- as.numeric(data)
  if(missing(name)) stop("need to supply a name")
  if(!is.integer(digits)) digits <- as.integer(digits)
  return(new("RandomRatioVariable",data,name=name,digits=digits,min=min,max=max))
}

setClassUnion("Variable",c("NominalVariable","OrdinalVariable","IntervalVariable","RatioVariable"))
setClassUnion("RandomVariable",c("RandomNominalVariable","RandomOrdinalVariable","RandomIntervalVariable","RandomRatioVariable"))

setMethod("asRandom","Variable",
    function(object,...) {
        if(!is(object,"RandomVariable")) {
            if(is(object,"NominalVariable")) object <- as(object,"RandomNominalVariable")
            if(is(object,"OrdinalVariable")) object <- as(object,"RandomOrdinalVariable")
            if(is(object,"IntervalVariable")) object <- as(object,"RandomIntervalVariable")
            if(is(object,"RatioVariable")) object <- as(object,"RandomRatioVariable")
        } 
        return(object)
    }
)

setMethod("asFixed","Variable",
    function(object,...) {
        if(is(object,"RandomVariable")) {
            if(is(object,"RandomNominalVariable")) object <- as(object,"NominalVariable")
            if(is(object,"RandomOrdinalVariable")) object <- as(object,"OrdinalVariable")
            if(is(object,"RandomIntervalVariable")) object <- as(object,"IntervalVariable")
            if(is(object,"RandomRatioVariable")) object <- as(object,"RatioVariable")
        }
        return(object)
    }
)

setAs("Variable","NominalVariable",
    function(from,to) {
        return(new(to,as.factor(asS3(from)),name = names(from)))
    }
)

setAs("Variable","RandomNominalVariable",
    function(from,to) {
        return(new(to,as.factor(asS3(from)),name = names(from)))
    }
)
         
                 
setAs("Variable","OrdinalVariable",
    function(from,to) {
        return(new(to,as.ordered(asS3(from)),name = names(from)))
    }
)

setAs("Variable","RandomOrdinalVariable",
    function(from,to) {
        return(new(to,as.ordered(asS3(from)),name = names(from)))
    }
)

setAs("Variable","IntervalVariable",
    function(from,to) {
        if(isMetric(from)) {
            return(new(to,as.numeric(asS3(from)),name = names(from),digits=digits(from)))
        } else {
            return(new(to,as.numeric(asS3(from)),name = names(from),digits=getOption("digits")))
        }
    }
)

setAs("Variable","RandomIntervalVariable",
    function(from,to) {
        if(isMetric(from)) {
            return(new(to,as.numeric(asS3(from)),name = names(from),digits=digits(from)))
        } else {
            return(new(to,as.numeric(asS3(from)),name = names(from),digits=getOption("digits")))
        }
    }
)

setAs("Variable","RatioVariable",
    function(from,to) {
        if(isMetric(from)) {
            return(new(to,as.numeric(asS3(from)),name = names(from),digits=digits(from)))
        } else {
            return(new(to,as.numeric(asS3(from)),name = names(from),digits=getOption("digits")))
        }
    }
)


setAs("Variable","RandomRatioVariable",
    function(from,to) {
        if(isMetric(from)) {
            return(new(to,as.numeric(asS3(from)),name = names(from),digits=digits(from)))
        } else {
            return(new(to,as.numeric(asS3(from)),name = names(from),digits=getOption("digits")))
        }
    }
)

setClass("VariableList",
  contains="list"
)

VariableList <- function(list) {
  if(!is.list(list)) stop("argument is not a list")
  else {
    out <- new("VariableList",
      .Data <- list)
  }
  out
}

setValidity("VariableList",
  method=function(object) {
    all(lapply(object,function(x) is(x,"Variable"))==TRUE)
  }
)

setMethod("Summary","Variable",
  function(x,...,na.rm = FALSE) {
    callNextMethod()
  }
)


setMethod("Summary","RandomIntervalVariable",
  function(x,...,na.rm = FALSE) {
    switch(.Generic,
      min = x@min,
      max = x@max,
      range = c(x@min,x@max),
      all = NA,
      any = NA,
      sum = NA,
      prod = NA)
    }
)

setMethod("isMetric","Variable",
  function(object,...) {
    return(is(object,"IntervalVariable") | is(object,"RatioVariable"))
  }
)

setMethod("isRandom","Variable",
    function(object,...) {
        return(is(object,"RandomVariable"))
    }
)

setMethod("digits","Variable",
    function(object,...) {
        if(isMetric(object)) return(object@digits)
    }
)

setMethod("names",signature("Variable"),
  function(x) x@name
)

setReplaceMethod("names",signature("Variable"),
  function(x,value) {
    if(is.character(value)) {
      x@name <- value
    } else {
      x@name <- as.character(value)
    }
    return(x)
  }
)

setMethod("labels","Variable",
  function(object) if(is(object,"IntervalVariable") | is(object,"RatioVariable")) NULL else labels(asS3(object))
)

setReplaceMethod("levels",signature("NominalVariable"),
  function(x,value) {
    if(is.character(value)) {
      x@levels <- value
    } else {
      x@levels <- as.character(value)
    }
    return(x)
  }
)

setMethod("isMetric","VariableList",
  function(object,...) unlist(lapply(object,isMetric,...))
)

setMethod("isRandom","VariableList",
    function(object,...) unlist(lapply(object,isRandom,...))
)


setMethod("names",signature("VariableList"),
  function(x) unlist(lapply(x,names))
)

setReplaceMethod("names","VariableList",
  function(x,value) {
    if(length(value) != length(x)) {
        stop("need the correct length to replace names")
    } else {
        #names(x) <- value
        for(i in 1:length(x)) {
            names(x[[i]]) <- value[i]
        }
    }
    return(x)
  }
)



#setMethod("simulate",signature(object="Variable"),
#    function(object,nsim,seed,distribution,...) {
#        if(!is(distribution,"Distribution")) stop("distribution should be a Distribution object")
#        if(isMetric(object)) {
#            object@.Data <- simulate(distribution,nsim=length(object),seed,min=min(object),max=max(object),digits=digits(object),...)
#        } else {
#            object@.Data <- simulate(distribution,nsim=length(object),seed,...)
#        }
#        object
#    }
#)
#setMethod("labels",signature("SimDatVariableList"),
#  function(x) labels(x@scale)
#)

setMethod("simulate",signature(object="RandomVariable"),
  function(object,nsim=1,seed,model,...) {
    call <- match.call()
    args <- as.list(call[2:length(call)])
    if(!missing(model)) object <- do.call("simulateFromModel",args)
    object
  }
)

setReplaceMethod("digits","IntervalVariable",
  function(object,value) {
    if(is.numeric(value) & value >= 0) {
      if(!is.integer(value)) value <- as.integer(value)
      object@digits <- value
    } else {
      stop("cannot set digits; need a numeric value greater than 0")
    }
    object
  }
)

setReplaceMethod("min","RandomIntervalVariable",
  function(object,value) {
    if(is.numeric(value)) {
      object@min <- value
    } else {
      stop("cannot set minimum; need a numeric value")
    }
    object
  }
)

setReplaceMethod("max","RandomIntervalVariable",
  function(object,value) {
    if(is.numeric(value)) {
      object@max <- value
    } else {
      stop("cannot set maximum; need a numeric value")
    }
    object
  }
)

setMethod("getData","VariableList",
    function(object,...) {
        if(length(object) > 0) {
            dat <- as.data.frame(object)
            colnames(dat) <- names(object)
            for(i in 1:length(dat)) {
                dat[,i] <- asS3(dat[,i])
                # TODO: why is this necessary?
                attr(dat[,i],"name") <- names(object)[i]
            }
        } else {
            dat <- data.frame()
        }
        dat
    }
)

setMethod("variableNames","VariableList",
  function(object,...) {
    names(object,...)
  }
)

setMethod("variables",signature(object="VariableList",names="ANY"),
  function(object) {
    return(object)
  }
)

setMethod("variables",signature(object="VariableList",names="character"),
  function(object,names,...) {
      if(length(names) == 1) {
        id <- which(variableNames(object,...) == names)
        if(length(id) > 0) {
          return(object[[id]])
        } else {
          return(NULL)
        }
      } else if(length(names) > 1) {
        return(VariableList(object[variableNames(object,...) %in% names]))
      } else {
        return(NULL)
      }
    }
)

setReplaceMethod("variables","VariableList",
  function(object,value) {
    if(!is(value,"VariableList")) {
      stop("cannot replace variables; need a VariableList")
    } else {
      object <- value
    }
    return(object)
  }
)
