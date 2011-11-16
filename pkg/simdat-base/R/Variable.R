setClass("NominalVariable",
  contains="factor",
  representation(
    name="character"
  )
)

setClass("RandomNominalVariable",
    contains="NominalVariable"
)
as
setClass("OrdinalVariable",
  contains="ordered",
  representation(
    name="character"
  )
)

setClass("RandomOrdinalVariable",
    contains="OrdinalVariable"
)

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

setClass("RatioVariable",
  contains="IntervalVariable"
)

setClass("RandomRatioVariable",
    contains="RandomIntervalVariable"
)

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

setAs("NominalVariable","RandomNominalVariable",
  function(from) {
      new("RandomNominalVariable",
        .Data = from@.Data,
        levels = from@levels,
        name = names(from))
  }
)

setAs("NominalVariable","OrdinalVariable",
  function(from) {
      new("OrdinalVariable",
        ordered(from@.Data,labels=levels(from)),
        name = names(from))
  }
)

setAs("NominalVariable","IntervalVariable",
  function(from) {
      new("IntervalVariable",
        as.numeric(from),
        name = names(from),
        digits=getOption("digits"))
  }
)

setAs("NominalVariable","RatioVariable",
  function(from) {
      new("RatioVariable",
        as.numeric(from),
        name = names(from),
        digits=getOption("digits"))
  }
)

setAs("OrdinalVariable","RandomOrdinalVariable",
  function(from) {
      new("RandomOrdinalVariable",
        .Data = from@.Data,
        levels = from@levels,
        name = names(from))
  }
)

setAs("OrdinalVariable","NominalVariable",
  function(from) {
      new("NominalVariable",
        factor(from@.Data,labels=levels(from)),
        name = names(from))
  }
)

setAs("OrdinalVariable","IntervalVariable",
  function(from) {
      new("IntervalVariable",
        as.numeric(from),
        name = names(from),
        getOption("digits"))
  }
)

setAs("OrdinalVariable","RatioVariable",
  function(from) {
      new("RatioVariable",
        as.numeric(from),
        name = names(from),
        getOption("digits"))
  }
)

setAs("IntervalVariable","RandomIntervalVariable",
  function(from) {
      new("RandomIntervalVariable",
        from@.Data,
        name = names(from),
        digits=digits(from),
        min=-Inf,
        max=Inf)
  }
)

setAs("IntervalVariable","NominalVariable",
  function(from) {
      new("NominalVariable",
        factor(from@.Data),
        name = names(from))
  }
)

setAs("IntervalVariable","OrdinalVariable",
  function(from) {
      new("OrdinalVariable",
        ordered(from),
        name = names(from))
  }
)

setAs("IntervalVariable","RatioVariable",
  function(from) {
      new("RatioVariable",
        from@.Data,
        name = names(from),
        digits=digits(from))
  }
)

setAs("RatioVariable","RandomRatioVariable",
  function(from) {
      new("RandomRatioVariable",
        from@.Data,
        name = names(from),
        digits=digits(from),
        min=-Inf,
        max=Inf)
  }
)

setAs("RatioVariable","NominalVariable",
  function(from) {
      new("NominalVariable",
        factor(from@.Data),
        name = names(from))
  }
)

setAs("RatioVariable","OrdinalVariable",
  function(from) {
      new("OrdinalVariable",
        ordered(from),
        name = names(from))
  }
)

setAs("RatioVariable","IntervalVariable",
  function(from) {
      new("IntervalVariable",
        from@.Data,
        name = names(from),
        digits=digits(from))
  }
)

##TODO: setAs("RandomNominalVariable","NominalVariable",

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
  function(object) if(is(object,"IntervalVariable") | is(object,"RatioVariable")) NULL else labels(object)
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

setMethod("simulate",signature(object="Variable"),
  function(object,nsim=1,seed,model,...) {
    call <- match.call()
    args <- as.list(call[2:length(call)])
    if(!missing(model)) object <- do.call("simulateFromModel",args)
    object
  }
)

setReplaceMethod("digits","IntervalVariable",
  function(object,value,...) {
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
  function(object,value,...) {
    if(is.numeric(value)) {
      object@min <- value
    } else {
      stop("cannot set minimum; need a numeric value")
    }
    object
  }
)

setReplaceMethod("max","RandomIntervalVariable",
  function(object,value,...) {
    if(is.numeric(value)) {
      object@max <- value
    } else {
      stop("cannot set maximum; need a numeric value")
    }
    object
  }
)
