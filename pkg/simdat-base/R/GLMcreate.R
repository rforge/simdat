GLM_create <- function(factors=NULL,covariates=NULL,covariateModels=NULL,N=NULL,mu=NULL,sigma=NULL,nu=NULL,tau=NULL,beta=NULL,DV=NULL,family=NULL) {

    design <- factors
    nfactor <- 0
    factor.names <- ""
    if(!is.null(design)) {
      # design can be a data.frame or VariableList
      if(is.data.frame(design)) {
        if(!all(unlist(lapply(design,is.factor)))) stop("factors should be a data.frame with factors")
        tdesign <- design
      } else if(is(design,"VariableList")) {
        if(!all(unlist(lapply(design,isMetric)) == FALSE)) stop("design should be a VariableList with Nominal or Ordinal variables")
        if(!all(unlist(lapply(design,isRandom)) == FALSE)) stop("design should be a VariableList with Fixed variables")
        tdesign <- getData(design)
        tdesign <- unique(tdesign)
        if(is.null(N)) {
          N <- rep(1,nrow(tdesign))
        }
        #colnames(tdesign) <- names(design)
      } else {
        stop("factors should be a data.frame or VariableList")
      }
      nfactor <- ncol(tdesign)
      factor.names <- colnames(tdesign)
      nCells <- NROW(tdesign)
      tdesign <- as.data.frame(lapply(tdesign,rep,length=sum(N)))
    } else {
      nCells <- 1
    }
    
    # covariates can be a data.frame (for fixed) or a VariableList
    ncovariate <- 0
    covariate.names <- ""
    if(!is.null(covariates)) {
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
        # generate values for random covariates
        #j <- 1
        #for(i in 1:length(covariates)) {
        #  if(!cfixed[i]) {
        #    covariates[[i]]@.Data
        #    covariates[[i]]@.Data <- simulateFromModel(covariates[[i]],covariateModels[[j]])
        #    j <- j + 1
        #  }
        #}
        tcovariates <- getData(covariates)
        #colnames(tdesign) <- names(design)
      } else {
        stop("covariates should be a data.frame or VariableList")
      }
      ncovariate <- ncol(tcovariates)
      covariate.names <- colnames(tcovariates)
      if(nrow(tcovariates) != sum(N)) {
        tcovariates <- as.data.frame(lapply(tcovariates,rep,length=sum(N)))
      }
    }
    
    # DV can be a list or (metric) Variable
    if(is.list(DV)) {
      if(is.null(DV$name)) DV$name <- "Y"
      if(is.null(DV$min)) DV$min <- -Inf
      if(is.null(DV$max)) DV$max <- Inf
      if(is.null(DV$digits)) DV$digits=8
      #if(is.null(DV$family)) DV$family <- gamlss.dist::NO()
      if(length(DV$name) != 1) stop("GLM can only have a single dependent variable")
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

    N <- matchArg(N,nCells,"N")
    
    if(npar > 0) mu <- matchArg(mu,nCells,"mu")
    if(npar > 1) sigma <- matchArg(sigma,nCells,"sigma")
    if(npar > 2) nu <- matchArg(nu,nCells,"nu")
    if(npar > 3) tau <- matchArg(tau,nCells,"tau")
    
    if(ncovariate > 0) {
      if(!is.matrix(beta)) {
        if(ncovariate == 1) {
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
    }
    
    #nIV <- NCOL(tdesign)
    #designMatrix <- tdesign
    #designMatrix <- data.frame(lapply(designMatrix,rep,times=N))
    #factor.names <- colnames(tdesign)

    fixed <- list()
    if(nfactor > 0) {
      if(is.data.frame(design)) {
        for(i in 1:nfactor) {
            fixed[[i]] <- new("NominalVariable",
              tdesign[,i],
              name = colnames(tdesign)[i]
            )
        }
      } else {
        fixed <- design  
        for(i in 1:nfactor) {
            fixed[[i]]@.Data <- tdesign[,i]@.Data
        }
      }
    }
    fixed <- VariableList(fixed)
    
    random <- list()
    cIVs <- vector("list",length=ncovariate)
    if(ncovariate > 0) {
      #ncIV <- NCOL(tcovariates)
      if(is.data.frame(covariates)) {
        for(i in 1:ncovariate) {
          cIVs[[i]] <- new("IntervalVariable",
              tcovariates[,i],
              name = colnames(tcovariates)[i]
            )
        }
        fixed <- VariableList(c(fixed,cIVs))
      } else {
        cIVs <- covariates
        #random <- list()
        j <- 1
        for(i in 1:ncovariate) {
          cIVs[[i]]@.Data <- tcovariates[,i]@.Data
          if(cfixed[i]) {
            fixed <- VariableList(c(fixed,list(cIVs[[i]])))
          } else {
            tdat <- getData(fixed)
            if(!is.null(tdat) & nrow(tdat) > 0) {
              cIVs[[i]] <- simulateFromModel(cIVs[[i]],covariateModels[[j]],data=tdat)
            } else {
              cIVs[[i]] <- simulateFromModel(cIVs[[i]],covariateModels[[j]])
            }
            random <- VariableList(c(random,list(cIVs[[i]])))
            j <- j+1
          }
        }
      }
    }
    
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
        DVs@.Data <- rep(DVs@.Data,length=sum(N)) # ensure dependent has the correct length!
    }

    cTerms <- paste(covariate.names,collapse="+")
    fTerms <- paste(factor.names,collapse="*")
    if(nchar(cTerms) > 0) {
      if(nchar(fTerms) > 0) mFterms <- paste("(",cTerms,")*",fTerms,sep="") else mFterms <- cTerms
    } else {
      if(nchar(fTerms) > 0) mFterms <- fTerms else mFterms <- 1
    }
    mFormula <- as.formula(paste(names(DVs),"~",mFterms))
    dat <- getData(VariableList(c(fixed,random)))
    # need to get the means of the covariates
    tmu <- rep(mu,N)
    if(ncovariate > 0) {
      tbeta <- apply(beta,2,rep,times=N)
      tmu <- tmu + rowSums(tbeta*tcovariates)
      #for(i in 1:ncovariate) {
      #  j <- 1
      #  if(isRandom(cIVs[[i]])) {
          #tcovariates[,i] <- mean(covariateModels[[j]],DV=cIVs[[i]])
          #tcovariates[,i] <- simulateFromModel(cIVs[[i]],covariateModels[[j]])
      #    j <- j + 1
      #  }
      #}
    }
    dat[,names(DVs)] <- family$mu.linkfun(tmu)
    mmod <- lm(mFormula,data=dat)
    mcoeff <- coefficients(mmod)
        
    if(npar > 1) {
      if(length(unique(sigma))!=1) {
        sFormula <- as.formula(paste(names(DVs),"~",mFterms))
      } else {
        sFormula <- as.formula(paste(names(DVs),"~",1))
      }
      dat <- getData(VariableList(c(fixed,random)))
      # TODO: this should only be done for models where sigma=sd!
      tsigma <- rep(sigma,N)
      if(ncovariate > 0) {
        for(i in 1:ncovariate) {
          j <- 1
          if(isRandom(cIVs[[i]])) {
            tcovariates[,i] <- sd(covariateModels[[j]],DV=cIVs[[i]])^2
            j <- j + 1
          } else {
            tcovariates[,i] <- rep(aggregate(tcovariates[,i],by=tdesign,FUN=var)$x,times=N)
          }
        }
        tsigma <- sqrt(tsigma^2 + rowSums(beta^2*tcovariates))
      }
      dat[,names(DVs)] <- family$sigma.linkfun(tsigma)
      smod <- lm(sFormula,data=dat)
      scoeff <- coefficients(smod)
      sFormula[[2]] <- NULL
    }
    
    if(npar > 2) {
      if(length(unique(nu))!=1) {
        nFormula <- as.formula(paste(names(DVs),"~",mFterms))
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
      family=family)
        
   if(npar > 1) mod@sigma  <- new("ParModel",formula=sFormula,coefficients=scoeff)
   if(npar > 2) mod@nu  <- new("ParModel",formula=nFormula,coefficients=ncoeff)
   if(npar > 3) mod@tau  <- new("ParModel",formula=tFormula,coefficients=tcoeff)
      
   DVs <- simulateFromModel(DVs,model=mod,data=dat)
   
   # TODO: allow more than 1 DV?
   structure <- matrix(0,ncol=(length(fixed) + length(random) + 1),nrow=(length(fixed) + length(random) + 1))
   structure[-nrow(structure),ncol(structure)] <- 1
     
   modelID <- c(rep(0,length(fixed)))
   if(length(random) > 0) modelID <- c(modelID,seq(1,length(random)))
   modelID <- c(modelID,1+length(random))
   
    sdmod <- new("GLM",
      variables=VariableList(c(fixed,random,list(DVs))),
      models=ModelList(c(covariateModels,list(mod))),
      modelID=modelID,
      structure=structure
    )
    
    return(sdmod)

}


