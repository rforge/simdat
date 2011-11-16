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
    vars <- variables(object,...)
    if(length(vars)>0) {
        modelIDs <- object@modelID[isRandom(vars)]
        if(!is.null(modelIDs)) {
            tmp <- unique(modelIDs)
            tmp <- tmp[tmp != 0]
            tmp <- tmp[order(tmp)]
            for(id in tmp) {
                nList[paste(id)] <- c(nList,list(names(vars)[object@modelID == id]))
            }
            tmp <- which((object@modelID == 0) & isRandom(vars))
            if(length(tmp)>0) {
                for(id in tmp) nList <- c(nList,list(variableNames(vars)[id]))
            }
        }
    }
    return(nList)
}
