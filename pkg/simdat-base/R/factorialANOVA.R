factorialANOVA <- function(factor.names = c("A","B"),factor.levels=c(2,2),N=c(15,15,15,15),means=c(0,1,2,3),sds=c(2,2,2,2),DV=list(name="Y",min=-Inf,max=Inf,digits=8,distribution="NormalDistribution")) {

    if(is.null(DV$name)) DV$name <- "Y"
    if(is.null(DV$min)) DV$min <- -Inf
    if(is.null(DV$max)) DV$max <- Inf
    if(is.null(DV$digits)) DV$digits=8
    if(is.null(DV$distribution)) DV$distribution <- "NormalDistribution"

    matchArg <- function(x,nCells,name) {
      if(length(x) > nCells) {
        warning("design has ",nCells,"but ",name," has length ",length(x),". Will not use superfluous values.")
        x <- x[1:nCells]
      }
      if(length(x) < nCells ) {
        if(length(x) != 1) warning("design has ",nCells,"but ",name," has length ",length(x),". Will fill up values by repetition")
        x <- rep(x,length=nCells)
      }
      return(x)
    }
    if(length(DV$name) != 1) stop("ANOVA can only have a single dependent variable")


    nCells <- prod(factor.levels)    
    N <- matchArg(N,nCells,"N")
    means <- matchArg(means,nCells,"means")
    sds <- matchArg(sds,nCells,"sds")
    
    tmp <- list()
    nIV <- length(factor.names)
    for(i in 1:nIV) tmp[[i]] <- seq(1,factor.levels[i])
    designMatrix <- expand.grid(tmp)
    colnames(designMatrix) <- factor.names
    designMatrix <- apply(designMatrix,2,rep,times=N)
    
    IVs <- list()
    for(i in 1:nIV) {
        IVs[[i]] <- new("NominalVariable",
          factor(designMatrix[,i],labels=paste(factor.names[i],1:(factor.levels[i]),sep="")),
          name = factor.names[i]
        )
    }
    fixed <- new("VariableList",IVs)
    
    DVs <- new("RandomIntervalVariable",
        rep(NA,sum(N)),
        name = DV$name,
        min=DV$min,
        max=DV$max,
        digits=as.integer(DV$digits)
    )
    
    designFormula <- as.formula(paste(DV$name,"~",paste(factor.names,collapse="*")))
    
    dat <- as.data.frame(fixed)
    colnames(dat) <- names(fixed)
    dat[,DV$name] <- rep(means,N)
    mod <- lm(designFormula,data=dat)
    coeff <- coefficients(mod)
    
    DVdistr <- new(DV$distribution)
    mean(DVdistr) <- predict(mod)
    sd(DVdistr) <- rep(sds,times=N)
    
    # now simulate the DV
    DVs <- simulate(DVs,distribution=DVdistr)
    
    skel <- new("SimDatUnivariateLM",
      formula=designFormula,
      coefficients=coeff,
      fixed = fixed,
      random = new("VariableList",list(DVs)),
      distribution = new("DistributionList",list(DVdistr)),
      distributionID = as.integer(1),
      distributionGeneration = as.integer(1),
      N=N
    )
    
    return(skel)

}


