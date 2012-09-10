setClass("ANOVA",
  contains="GLM")

ANOVA <- function(design=data.frame(A=factor(c(1,1,2,2),labels=c("A1","A2")),B=factor(c(1,2,1,3),labels=c("B1","B2","B3"))),N=c(15,15,15,15),mu=c(0,1,2,3),sigma=c(2,2,2,2),nu=NULL,tau=NULL,DV=list(name="Y",min=-Inf,max=Inf,digits=8),family=NO()) {
  tmp <- GLM_create(factors=design,N=N,mu=mu,sigma=sigma,nu=nu,tau=tau,beta=beta,DV=DV,family=family)
  return(as(tmp,"ANOVA"))
}


ANOVA_deprecated <- function(design=data.frame(A=factor(c(1,1,2,2),labels=c("A1","A2")),B=factor(c(1,2,1,3),labels=c("B1","B2","B3"))),N=c(15,15,15,15),mu=c(0,1,2,3),sigma=c(2,2,2,2),nu=NULL,tau=NULL,DV=list(name="Y",min=-Inf,max=Inf,digits=8),family=NO()) {

    #TODO: should use GLM_create!

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
    dat[,names(DVs)] <- family$mu.linkfun(rep(mu,N))
    mmod <- lm(mFormula,data=dat)
    mcoeff <- coefficients(mmod)
    
    if(npar > 1) {
      if(length(unique(sigma))!=1) {
        sFormula <- as.formula(paste(names(DVs),"~",paste(factor.names,collapse="*")))
      } else {
        sFormula <- as.formula(paste(names(DVs),"~",1))
      }
      dat <- getData(fixed)
      dat[,names(DVs)] <- family$sigma.linkfun(rep(sigma,N))
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


