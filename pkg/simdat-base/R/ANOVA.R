ANOVA <- function(design=data.frame(A=factor(c(1,1,2,2),labels=c("A1","A2")),B=factor(c(1,2,1,3),labels=c("B1","B2","B3"))),N=c(15,15,15,15),means=c(0,1,2,3),sds=c(2,2,2,2),DV=list(name="Y",min=-Inf,max=Inf,digits=8,family=NO())) {

    if(!all(unlist(lapply(design,is.factor)))) stop("design should be a data.frame with factors")

    if(is.null(DV$name)) DV$name <- "Y"
    if(is.null(DV$min)) DV$min <- -Inf
    if(is.null(DV$max)) DV$max <- Inf
    if(is.null(DV$digits)) DV$digits=8
    if(is.null(DV$family)) DV$family <- gamlss.dist::NO()

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


    nCells <- NROW(design) 
    N <- matchArg(N,nCells,"N")
    means <- matchArg(means,nCells,"means")
    sds <- matchArg(sds,nCells,"sds")
    
    nIV <- NCOL(design)
    designMatrix <- design
    designMatrix <- data.frame(lapply(designMatrix,rep,times=N))
    factor.names <- colnames(design)
    
    IVs <- list()
    for(i in 1:nIV) {
        IVs[[i]] <- new("NominalVariable",
          designMatrix[,i],
          name = colnames(designMatrix)[i]
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
    #DVs <- list(DVs)
    mFormula <- as.formula(paste(DV$name,"~",paste(factor.names,collapse="*")))
    dat <- as.data.frame(fixed)
    colnames(dat) <- names(fixed)
    dat[,DV$name] <- rep(means,N)
    mmod <- lm(mFormula,data=dat)
    mcoeff <- coefficients(mmod)
    
    if(length(unique(sds))!=1) {
      sFormula <- as.formula(paste(DV$name,"~",paste(factor.names,collapse="*")))
    } else {
      sFormula <- as.formula(paste(DV$name,"~",1))
    }
    dat <- as.data.frame(fixed)
    colnames(dat) <- names(fixed)
    dat[,DV$name] <- DV$family$sigma.linkfun(rep(sds,N))
    smod <- lm(sFormula,data=dat)
    scoeff <- coefficients(smod)
    sFormula[[2]] <- NULL
    #DVdistr <- new(DV$distribution)
    #mean(DVdistr) <- predict(mod)
    #sd(DVdistr) <- rep(sds,times=N)
    
    # now make the DV model
    
    mod <- new("GamlssModel",
      mu=new("ParModel",
        formula=mFormula,
        coefficients=mcoeff),
      sigma=new("ParModel",
        formula=sFormula,
        coefficients=scoeff),
      family=DV$family)
      
    DVs <- simulateFromModel(DVs,model=mod,data=dat)
    
    structure <- matrix(0,ncol=(length(IVs) + 1),nrow=(length(IVs) + 1))
    structure[-nrow(structure),ncol(structure)] <- 1
    
    sdmod <- new("SimDatModel",
      variables=VariableList(c(IVs,list(DVs))),
      models=ModelList(list(mod)),
      modelID=c(rep(0,length(IVs)),1),
      structure=structure
    )
    
    return(sdmod)

}


