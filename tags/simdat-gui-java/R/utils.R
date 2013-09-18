.getSimDatModels <- function() {
    #objects <- ls(pos=1)
    objects <- ls(envir=parent.frame())
    result <- c();
    if (length(objects) > 0) for (i in 1:length(objects)) {
    	d <- get(objects[i],envir=parent.frame())
    	if(is(d,"SimDatModel"))
        	result <- c(result,objects[i])
    }
    result
}

.ModVarsSimDatModelModel <- function(sdModel,...) {
    if(!is(sdModel,"SimDatModel")) stop("argument is not a SimDatModel")
    nList <- list()
    # check number of random variables
    vars <- variables(sdModel,...)
    if(length(vars)>0) {
        modelIDs <- sdModel@modelID[isRandom(vars)]
        if(!is.null(modelIDs)) {
            tmp <- unique(modelIDs)
            tmp <- tmp[tmp != 0]
            tmp <- tmp[order(tmp)]
            for(id in tmp) {
                nList[paste(id)] <- list(names(vars)[sdModel@modelID == id])
            }
            tmp <- which((sdModel@modelID == 0) & isRandom(vars))
            if(length(tmp)>0) {
                for(id in tmp) nList <- c(nList,list(names(vars)[id]))
            }
        }
    }
    return(nList)
}

.SimDatDistributions <- function() {
  dist <- list(
    "normal" = list(name="NO",parameters=c("mu","sigma")),
    #"normal family" = list(name="NOF",parameters=c("mu","sigma","nu")),
    "beta" = list(name = "BE",parameters=c("mu","sigma")),
    "Box-Cox Cole and Green" = list(name="BCCG",parameters=c("mu","sigma","nu")),
    "Box-Cox power exponential" = list(name="BCPE",parameters=c("mu","sigma","nu","tau")),
    "Box-Cox t" = list(name="BCT",parameters=c("mu","sigma","nu","tau")),
    "exponential" = list(name="EXP",parameters=c("mu")),
    "exponential Gaussian" = list(name="exGAUS",parameters=c("mu","sigma","nu")),
    "exponential gen. beta type 2" = list(name="EGB2",parameters=c("mu","sigma","nu","tau")),
    "gamma" = list(name="GA",parameters=c("mu","sigma")),
    "generalized beta type 1" = list(name="GB1",parameters=c("mu","sigma","nu","tau")),
    "generalized beta type 2"  = list(name="GB2",parameters=c("mu","sigma","nu","tau")),
    "generalized gamma" = list(name="GG",parameters=c("mu","sigma","nu")),
    "generalized inverse Gaussian" = list(name="GIG",parameters=c("mu","sigma","nu")),
    "generalized t" = list(name="GT",parameters=c("mu","sigma","nu","tau")),
    "Gumbel" = list(name="GB1",parameters=c("mu","sigma")),
    "inverse Gamma" = list(name="IGAMMA",parameters=c("mu","sigma")),
    "inverse Gaussian" = list(name="IG",parameters=c("mu","sigma")),
    "Johnson's SU (mu = mean)" = list(name="JSU",parameters=c("mu","sigma","nu","tau")),
    "Johnson's original SU" = list(name="JSUo",parameters=c("mu","sigma","nu","tau")),
    "logistic" = list(name="LO",parameters=c("mu","sigma")),
    "log normal" = list(name="LOGNO",parameters=c("mu","sigma")),
    "log normal (Box-Cox)" = list(name="LNO",parameters=c("mu","sigma","nu")),
    "NET" = list(name="GB1",parameters=c("NET","sigma","nu","tau")),
    "normal" = list(name="NO",parameters=c("mu","sigma")),
    "normal family" = list(name="NOF",parameters=c("mu","sigma","nu")),
    "Pareto 2 original" = list(name="PARETO2o",parameters=c("mu","sigma")),
    "Pareto 2" = list(name="PARETO2",parameters=c("mu","sigma")),
    "power exponential" = list(name="PE",parameters=c("mu","sigma","nu")),
    "reverse Gumbel" = list(name="RG",parameters=c("mu","sigma")),
    "skew power exponential type 1" = list(name="SEP1",parameters=c("mu","sigma","nu","tau")),
    "skew power exponential type 2" = list(name="SEP2",parameters=c("mu","sigma","nu","tau")),
    "skew power exponential type 3" = list(name="SEP3",parameters=c("mu","sigma","nu","tau")),
    "skew power exponential type 4" = list(name="SEP4",parameters=c("mu","sigma","nu","tau")),
    "sinh-arcsinh original" = list(name="SHASHo",parameters=c("mu","sigma","nu","tau")),
    "sinh-arcsinh original 2" = list(name="SHASHo2",parameters=c("mu","sigma","nu","tau")),
    "sinh-arcsinh" = list(name="SHASH",parameters=c("mu","sigma","nu","tau")),
    "skew t type 1" = list(name="ST1",parameters=c("mu","sigma","nu","tau")),
    "skew t type 2" = list(name="ST2",parameters=c("mu","sigma","nu","tau")),
    "skew t type 3" = list(name="ST3",parameters=c("mu","sigma","nu","tau")),
    "skew t type 4" = list(name="ST4",parameters=c("mu","sigma","nu","tau")),
    "skew t type 5" = list(name="ST5",parameters=c("mu","sigma","nu","tau")),
    "t Family" = list(name="TF",parameters=c("mu","sigma","nu")),
    "uniform" = list(name="UN",parameters=character()),
    "Weibull" = list(name="WEI",parameters=c("mu","sigma")),
    "Weibull (PH)" = list(name="WEI2",parameters=c("mu","sigma")),
    "Weibull (mu = mean)" = list(name="WEI3",parameters=c("mu","sigma"))
  )
  return(dist)
}

.SimDatDistributionNames <- function() {
  names(.SimDatDistributions())
}

.SimDatGetDistributionFromName <- function(name) {
  do.call(eval(.SimDatDistributions()[[name]]$name),args=list())
} 
