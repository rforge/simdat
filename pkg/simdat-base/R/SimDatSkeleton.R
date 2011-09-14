# to be obsolete:
setClass("SimDatSkeleton",
  representation(
    fixed="VariableList", # list with SimDatVariables
    random="VariableList", # list with scales
    distribution="DistributionList",
    distributionID="integer", # indicators linking elements of random to distributions
    distributionGeneration="integer", # indicators reflecting order of simulation for distributions
    N="numeric" # vector with n for each cell in the design
    #mu="array", # location array
    #sigma="array" # scale array  
  )
)

# to generate data:
# 1. expand designFixed to a data.frame (design fixed contains the combinations of the levels of the design that occur)
#   if(nrow(designFixed) == length(n)) design <- apply(designFixed,2,rep,n)
#   if(nrow(designFixed) == sum(n)) design <- designFixed # fine already
#   TODO: what about fixed metric design variables?
#  transform design into data.frame using information from designVarsFixed 
# 2. append designVarsRandom to design
# using formula, compute predicted values for dependent (location)
# generate random dependent according to method
# add error

setMethod("getData","SimDatSkeleton",
    function(object,...) {
        fixed <- as.data.frame(object@fixed)
        colnames(fixed) <- names(object@fixed)
        random <- as.data.frame(object@random)
        colnames(random) <- names(object@random)
        cbind(fixed,random)
    }
)

setMethod("N",signature(object="SimDatSkeleton"),
  function(object) {
    object@N
  }
)

setReplaceMethod("N",signature=signature("SimDatSkeleton", "numeric"),
  function(object,value) {
    object@N <- value
    object
  }
)
