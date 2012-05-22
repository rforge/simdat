setClass("GLM",
  contains="SimDatModel")

GLM <- function(factors=data.frame(A=factor(c(1,1,2,2),labels=c("A1","A2")),B=factor(c(1,2,1,3),labels=c("B1","B2","B3"))),covariates=VariableList(list(RandomIntervalVariable(numeric(sum(N)),digits=8,min=-Inf,max=Inf,name="X"))),covariateModels=ModelList(list(NormalModel(mean=0,sd=1))),N=c(15,15,15,15),mu=c(0,1,2,3),sigma=c(2,2,2,2),nu=NULL,tau=NULL,beta=c(1,1,1,1),DV=list(name="Y",min=-Inf,max=Inf,digits=8),family=NO()) {

    design <- factors
    # design can be a data.frame or VariableList
    if(is.data.frame(design)) {
      if(!all(unlist(lapply(design,is.factor)))) stop("factors should be a data.frame with factors")
      tdesign <- design
    } else if(is(design,"VariableList")) {
      if(!all(unlist(lapply(design,isMetric)) == FALSE)) stop("design should be a VariableList with Nominal or Ordinal variables")
      if(!all(unlist(lapply(design,isFixed)) == TRUE)) stop("design should be a VariableList with Fixed variables")
      tdesign <- getData(design)
      #colnames(tdesign) <- names(design)
    } else {
      stop("design should be a data.frame or VariableList")
    }
    # covariates can be a data.frame (for fixed) or a VariableList
    if(is.data.frame(covariates)) {
      if(!all(unlist(lapply(covariates,is.numeric)))) stop("covariates should be a data.frame with numerics")
      tcovariates <- covariates
    } else if(is(covariates,"VariableList")) {
      if(!all(unlist(lapply(covariates,isMetric)) == TRUE)) stop("covariates should be a VariableList with Interval or Ratio variables")
      cfixed <- !unlist(lapply(covariates,isRandom))
      if(!all(cfixed == TRUE)) {
        # check that we have models for the non-fixed covariates
        if(length(covariateModels) != sum(!cfixed)) stop("need to supply Models for all random covariates")
      }
      tcovariates <- getData(covariates)
      #colnames(tdesign) <- names(design)
    } else {
      stop("covariates should be a data.frame or VariableList")
    }
    if(nrow(tcovariates) != sum(N)) {
      tcovariates <- as.data.frame(lapply(tcovariates,rep,length=sum(N)))
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
    
    npar <- family$nopar
    
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
    mu <- matchArg(mu,nCells,"mu")
    
    if(npar > 1) sigma <- matchArg(sigma,nCells,"sigma")
    if(npar > 2) nu <- matchArg(nu,nCells,"nu")
    if(npar > 3) tau <- matchArg(tau,nCells,"tau")
    
    if(!is.matrix(beta)) {
      if(length(covariates) == 1) {
        if(length(beta) > 1 & length(beta)!=nCells) stop("beta should have length ",nCells)
        beta <- matrix(beta,nrow=nCells,ncol=1)
      } else {
        if(length(beta)!=length(covariates)) stop("beta should have length=length(covariates)")
        beta <- matrix(beta,nrow=nCells,ncol=ncol(tcovariates),byrow=TRUE)
      }
    } else {
      if(ncol(beta)!=length(covariates)) stop("beta should have ncol=length(covariates)")
      if(nrow(beta)!=nCells) {
        beta <- apply(beta,2,matchArg,nCells=nCells,name="mu")
      }
    }
    
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
    fixed <- VariableList(IVs)
    
    ncIV <- NCOL(tcovariates)
    if(is.data.frame(covariates)) {
      cIVs <- list()   
      for(i in 1:ncIV) {
          cIVs[[i]] <- new("IntervalVariable",
            tcovariates[,i],
            name = colnames(tcovariates)[i]
          )
      }
      fixed <- VariableList(c(fixed,cIVs))
    } else {
      cIVs <- covariates
      random <- list()
      for(i in 1:ncIV) {
          cIVs[[i]]@.Data <- tcovariates[,i]@.Data
      }
      if(cfixed[i]) {
        fixed <- VariableList(c(fixed,list(cIVs[[i]])))
      } else {
        random <- VariableList(c(random,list(cIVs[[i]])))
      }
    }
    covariate.names <- colnames(tcovariates)
    
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

    mFormula <- as.formula(paste(names(DVs),"~",paste(factor.names,collapse="*")))
    dat <- getData(fixed)
    # need to get the means of the covariates
    tmu <- rep(mu,N)
    tbeta <- apply(beta,2,rep,times=N)
    for(i in 1:length(cIVs)) {
      j <- 1
      if(isRandom(cIVs[[i]])) {
        tcovariates[,i] <- mean(covariateModels[[j]],DV=cIVs[[i]])
        j <- j + 1
      }
    }
    
    tmu <- tmu - rowSums(tbeta*tcovariates)
    dat[,names(DVs)] <- family$mu.linkfun(tmu)
    mmod <- lm(mFormula,data=dat)
    tmcoeff <- coefficients(mmod)
    
    # now plug in the covariates
    mFormula <- as.formula(paste(names(DVs),"~",paste(factor.names,collapse="*"),"+",paste(covariate.names,collapse="+")))
    
    if(npar > 1) {
      if(length(unique(sigma))!=1) {
        sFormula <- as.formula(paste(names(DVs),"~",paste(factor.names,collapse="*")))
      } else {
        sFormula <- as.formula(paste(names(DVs),"~",1))
      }
      dat <- getData(fixed)
      # TODO: this should only be done for models where sigma=sd!
      tsigma <- rep(sigma,N)
      for(i in 1:length(cIVs)) {
        j <- 1
        if(isRandom(cIVs[[i]])) {
          tcovariates[,i] <- sd(covariateModels[[j]],DV=cIVs[[i]])^2
          j <- j + 1
        } else {
          tcovariates[,i] <- 0
        }
      }
      tsigma <- sqrt(tsigma^2 - rowSums(beta^2*tcovariates))
      dat[,names(DVs)] <- family$sigma.linkfun(tsigma)
      smod <- lm(sFormula,data=dat)
      scoeff <- coefficients(smod)
      sFormula[[2]] <- NULL
    }
    
    if(npar > 2) {
      if(length(unique(nu))!=1) {
        nFormula <- as.formula(paste(names(DVs),"~",paste(factor.names,collapse="*")))
      } else {
        nFormula <- as.formula(paste(names(DVs),"~",1))
      }
      dat <- getData(fixed)
      dat[,names(DVs)] <- family$nu.linkfun(rep(nu,N))
      nmod <- lm(nFormula,data=dat)
      ncoeff <- coefficients(nmod)
      nFormula[[2]] <- NULL
    }
    
    if(npar > 3) {
      if(length(unique(tau))!=1) {
        tFormula <- as.formula(paste(names(DVs),"~",paste(factor.names,collapse="*")))
      } else {
        tFormula <- as.formula(paste(names(DVs),"~",1))
      }
      dat <- getData(fixed)
      dat[,names(DVs)] <- family$tau.linkfun(rep(tau,N))
      tmod <- lm(tFormula,data=dat)
      tcoeff <- coefficients(tmod)
      tFormula[[2]] <- NULL
    }
    
    #DVdistr <- new(DV$distribution)
    #mean(DVdistr) <- predict(mod)
    #sd(DVdistr) <- rep(sds,times=N)
    
    # now make the DV model
    
    mod <- new("GamlssModel",
      mu=new("ParModel",formula=mFormula,coefficients=mcoeff),
        family=family
    )
        
   if(npar > 1) mod@sigma  <- new("ParModel",formula=sFormula,coefficients=scoeff)
   if(npar > 2) mod@nu  <- new("ParModel",formula=nFormula,coefficients=ncoeff)
   if(npar > 3) mod@tau  <- new("ParModel",formula=tFormula,coefficients=tcoeff)
      
   DVs <- simulateFromModel(DVs,model=mod,data=dat)
   
   # TODO: allow more than 1 DV?
   structure <- matrix(0,ncol=(length(fixed) + length(random) + 1),nrow=(length(fixed) + length(random) + 1))
   structure[-nrow(structure),ncol(structure)] <- 1
    
    sdmod <- new("GLM",
      variables=VariableList(c(IVs,cIVs,list(DVs))),
      models=ModelList(c(covariateModels,list(mod))),
      modelID=c(rep(0,length(fixed)),seq(1,length(random)),1+length(random)),
      structure=structure
    )
    
    return(sdmod)

}


