factorialANOVA <- function(factor.names = c("A","B"),factor.levels=list(c("A1","A2"),c("B1","B2")),N=c(15,15,15,15),means=c(0,1,2,3),sds=c(2,2,2,2),DV=list(name="Y",min=-Inf,max=Inf,digits=8,family=NO())) {
    
    if(!is.list(factor.levels)) {
      if(is.numeric(factor.levels)) {
        tmp <- list()
        for(i in 1:length(factor.levels)) {
          tmp[[i]] <- paste(factor.names[i],1:factor.levels[i],sep=".")
        }
      factor.names <- tmp
      } else {
        stop("factor.levels should be a list or vector with integers")
      }
    }
    tmp <- list()
    nIV <- length(factor.names)
    #for(i in 1:nIV) tmp[[i]] <- factor.levels[[i]]
    designMatrix <- expand.grid(factor.levels)
    colnames(designMatrix) <- factor.names
    #designMatrix <- as.data.frame(lapply(designMatrix,rep,times=N))
    
    sdmod <- ANOVA(design=designMatrix,N=N,means=means,sds=sds,DV=DV)
    
    return(sdmod)

}


