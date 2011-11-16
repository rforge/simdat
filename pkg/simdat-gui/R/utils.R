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
