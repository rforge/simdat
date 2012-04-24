setClass("ANOVA",
  contains="SimDatModel")

ANOVA <- function(design=data.frame(A=factor(c(1,1,2,2),labels=c("A1","A2")),B=factor(c(1,2,1,3),labels=c("B1","B2","B3"))),N=c(15,15,15,15),means=c(0,1,2,3),sds=c(2,2,2,2),DV=list(name="Y",min=-Inf,max=Inf,digits=8),family=NO()) {

    # design can be a data.frame or VariableList
    if(is.data.frame(design)) {
      if(!all(unlist(lapply(design,is.factor)))) stop("design should be a data.frame with factors")
      tdesign <- design
    } else if(is(design,"VariableList")) {
      if(!all(unlist(lapply(design,isMetric)) == FALSE)) stop("design should be a VariableList with Nominal or Ordinal variables")
      tdesign <- getData(design)
      #colnames(tdesign) <- names(design)
    } else {
      stop("design should be a data.frame or VariableList")
    }
    # DV can be a list or (metric) Variable
    if(is.list(DV)) {
      if(is.null(DV$name)) DV$name <- "Y"
      if(is.null(DV$min)) DV$min <- -Inf
      if(is.null(DV$max)) DV$max <- Inf
      if(is.null(DV$digits)) DV$digits=8
      #if(is.null(DV$family)) DV$family <- gamlss.dist::NO()
      if(length(DV$name) != 1) stop("ANOVA can only have a single dependent variable")
    } else if(is(DV,"Variable")) {
      if(!isMetric(DV)) stop("DV is not a metric Variable")
    } else {
      stop("DV should be a list or Variable")
    }
    # family must be a gamlss.family object
    if(!is(family,"gamlss.family")) stop("family should be a gamlss.family object")
    
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

    nCells <- NROW(tdesign) 
    N <- matchArg(N,nCells,"N")
    means <- matchArg(means,nCells,"means")
    sds <- matchArg(sds,nCells,"sds")
    
    nIV <- NCOL(tdesign)
    designMatrix <- tdesign
    designMatrix <- data.frame(lapply(designMatrix,rep,times=N))
    factor.names <- colnames(tdesign)

     
    if(is.data.frame(design)) {
      IVs <- list()   
      for(i in 1:nIV) {
          IVs[[i]] <- new("NominalVariable",
            designMatrix[,i],
            name = colnames(designMatrix)[i]
          )
      }
    } else {
      IVs <- design  
      for(i in 1:nIV) {
          IVs[[i]]@.Data <- designMatrix[,i]@.Data
      }
    }
    fixed <- new("VariableList",IVs)
    
    if(!is(DV,"Variable")) {
      DVs <- new("RandomIntervalVariable",
          rep(NA,sum(N)),
          name = DV$name,
          min=DV$min,
          max=DV$max,
          digits=as.integer(DV$digits)
      )
    } else {
        DVs <- DV
        DVs@.Data <- rep(DVs@.Data,length=nrow(designMatrix)) # ensure dependent has the correct length!
    }
    #DVs <- list(DVs)
    mFormula <- as.formula(paste(names(DVs),"~",paste(factor.names,collapse="*")))
    dat <- getData(fixed)
    #colnames(dat) <- names(fixed)
    dat[,names(DVs)] <- family$mu.linkfun(rep(means,N))
    mmod <- lm(mFormula,data=dat)
    mcoeff <- coefficients(mmod)
    
    if(length(unique(sds))!=1) {
      sFormula <- as.formula(paste(names(DVs),"~",paste(factor.names,collapse="*")))
    } else {
      sFormula <- as.formula(paste(names(DVs),"~",1))
    }
    dat <- getData(fixed)
    #colnames(dat) <- names(fixed)
    dat[,names(DVs)] <- family$sigma.linkfun(rep(sds,N))
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
      family=family)
      
    DVs <- simulateFromModel(DVs,model=mod,data=dat)
    
    structure <- matrix(0,ncol=(length(IVs) + 1),nrow=(length(IVs) + 1))
    structure[-nrow(structure),ncol(structure)] <- 1
    
    sdmod <- new("ANOVA",
      variables=VariableList(c(IVs,list(DVs))),
      models=ModelList(list(mod)),
      modelID=c(rep(0,length(IVs)),1),
      structure=structure
    )
    
    return(sdmod)

}


