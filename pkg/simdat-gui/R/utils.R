.getSimDatModels <- function() {
    objects <- ls(pos=1)
    result <- c();
    if (length(objects) > 0) for (i in 1:length(objects)) {
    	d <- get(objects[i])
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
                nList[paste(id)] <- c(nList,list(names(vars)[sdModel@modelID == id]))
            }
            tmp <- which((sdModel@modelID == 0) & isRandom(vars))
            if(length(tmp)>0) {
                for(id in tmp) nList <- c(nList,list(variableNames(vars)[id]))
            }
        }
    }
    return(nList)
}

.SimDatDistributions <- function() {
  dist <- list(
    "normal" = list(name="NO",parameters=c("mu","sigma")),
    "normal family" = list(name="NOF",parameters=c("mu","sigma","nu"))
  )
  return(dist)
}

.SimDatDistributionNames <- function() {
  names(.SimDatDistributions())
}

.SimDatGetDistributionFromName <- function(name) {
  do.call(eval(.SimDatDistributions()[[name]]$name),args=list())
} 
