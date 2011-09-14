setClass("NominalVariable",
  contains="factor",
  representation(
    name="character"
  )
)

setClass("RandomNominalVariable",
    contains="NominalVariable"
)

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
    digits="integer",
    min="numeric",
    max="numeric"
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

setClass("VariableList",
  contains="list"
)

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

setMethod("labels",signature("Variable"),
  function(object) if(is(object,"IntervalVariable") | is(object,"RatioVariable")) NULL else labels(object)
)

setMethod("names",signature("VariableList"),
  function(x) unlist(lapply(x,names))
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
