setClass("WizardDf",
  contains="data.frame")
  
setClass("GlmWizardDf",
  contains="WizardDf",
  representation(
    dependent="character",
    factor="character",
    numeric="character",
    family="gamlss.family")
)
    
GlmWizardDf<- function(dep=NULL,fac=NULL,num=NULL,family=NULL,n=15,mu=0,sigma=1,nu=0,tau=0,beta=0) {
  if(!is(dep,"RandomVariable")) warning("dependent variable is not a random variable")
  if(!is.null(fac) & !(is(fac,"VariableList") | is(fac,"Variable"))) stop("factors need to be a VariableList or a single Variable")
  if(!is.null(num) & !(is(num,"VariableList") | is(num,"Variable"))) stop("numerics need to be a VariableList or a single Variable")
  if(!is.null(family) & !is(family,"gamlss.family")) stop("family needs to be a gamlss.family")
  
  if(!is.null(fac)) {
    faclevs <- list()
    
    if(!is(fac,"VariableList")) fac <- VariableList(list(fac))
    fnames <- names(fac)
    
    for(i in 1:length(fac)) {
      faclevs[[i]] <- as.factor(levels(fac[[i]]))
    }
    
    dat <- as.data.frame(expand.grid(faclevs))
    colnames(dat) <- names(fac)
    
    dat <- cbind(dat,n=as.integer(rep(n,nrow(dat))))
    
    if(!is.null(family)) {
      dat <- switch(family$nopar,
        cbind(dat,mu=rep(mu,nrow(dat))),
        cbind(dat,mu=rep(mu,nrow(dat)),sigma=rep(sigma,nrow(dat))),
        cbind(dat,mu=rep(mu,nrow(dat)),sigma=rep(sigma,nrow(dat)),nu=rep(nu,nrow(dat))),
        cbind(dat,mu=rep(mu,nrow(dat)),sigma=rep(sigma,nrow(dat)),nu=rep(nu,nrow(dat)),tau=rep(tau,nrow(dat))))    
    } else {
      dat <- cbind(dat,mu=rep(mu,nrow(dat))) # always have 
    }
  } else {
    fnames <- character(0)
    # don't need to expand factors
    dat <- switch(family$nopar,
        data.frame(mu=mu),
        data.frame(mu=mu,sigma=sigma),
        data.frame(mu=mu,sigma=sigma,nu=nu),
        data.frame(mu=mu,sigma=sigma,nu=nu,tau=tau))
  }
  if(!is.null(num)) {
  
    if(!is(num,"VariableList")) num <- VariableList(list(num))
    nnames <- names(num)
    # add a beta for each numeric
    betas <- as.data.frame(rep(0,length=length(num)))
    colnames(betas) <- paste("beta(",names(num),")",sep="")
    dat <- cbind(dat,betas)
  } else {
    nnames <- character(0)
  }
  dat <- new("GlmWizardDf",
    .Data <- dat,
    dependent=names(dep),
    factor=fnames,
    numeric=nnames,
    family=family)
  #attr(dat,"dependentNames") <- names(dep)
  #attr(dat,"factorNames") <- names(fac)
  #attr(dat,"numericNames") <- names(num)
  #attr(dat,"distribution") <- dist
  return(dat)
}

GamlssModelFromGlmWizardDf <- function(df) {
  
  if(!is(df,"GlmWizardDf")) stop("df must be of class GlmWizardDf")
  
  dist <- df@family
  nopar <- dist$nopar
  DVname <- df@dependent
  DVname <- DVname[nchar(DVname)>0]
  facNames <- df@factor
  facNames <- facNames[nchar(facNames)>0]
  numNames <- df@numeric
  numNames <- numNames[nchar(numNames)>0]
  
  tdf <- df
  if(nopar > 0) {
    if(length(unique(df$mu))!=1) {
      # assume identical slopes for now...
      terms <- paste(facNames,collapse="*")
      if(length(numNames) > 0) terms <- paste(terms,"+",paste(numNames,collapse = "+")) 
      mformula <- as.formula(paste(DVname,"~",terms))
    } else {
      mformula <- as.formula(paste(DVname,"~",1))
    }
    tdf$mu <- dist$mu.linkfun(df$mu)
    tform <- mformula
    tform[[2]] <- as.name("mu")
    mmod <- lm(tform,data=data.frame(tdf))
    mcoeff <- coefficients(mmod)
  }
  if(nopar > 1) {
    if(length(unique(df$sigma))!=1) {
      # assume identical slopes for now...
      terms <- paste(facNames,collapse="*")
      if(length(numNames)>0) terms <- paste(terms,"+",paste(numNames,collapse = "+")) 
      sformula <- as.formula(paste(DVname,"~",terms))
    } else {
      sformula <- as.formula(paste(DVname,"~",1))
    }
    tdf$sigma <- dist$sigma.linkfun(df$sigma)
    tform <- sformula
    tform[[2]] <- as.name("sigma")
    smod <- lm(tform,data=data.frame(tdf))
    scoeff <- coefficients(smod)
    sformula[[2]] <- NULL
  }
  if(nopar > 2) {
    if(length(unique(df$nu))!=1) {
      # assume identical slopes for now...
      terms <- paste(facNames,collapse="*")
      if(length(numNames)>0) terms <- paste(terms,"+",paste(numNames,collapse = "+")) 
      nformula <- as.formula(paste(DVname,"~",terms))
    } else {
      nformula <- as.formula(paste(DVname,"~",1))
    }
    tdf$nu <- dist$nu.linkfun(df$nu)
    tform <- nformula
    tform[[2]] <- as.name("nu")
    nmod <- lm(tform,data=data.frame(tdf))
    ncoeff <- coefficients(nmod)
    nformula[[2]] <- NULL
  }
  if(nopar > 3) {
    if(length(unique(df$tau))!=1) {
      # assume identical slopes for now...
      terms <- paste(facNames,collapse="*")
      if(length(numNames)>0) terms <- paste(terms,"+",paste(numNames,collapse = "+"))
      tformula <- as.formula(paste(DVname,"~",terms))
    } else {
      tformula <- as.formula(paste(DVname,"~",1))
    }
    tdf$tau <- dist$tau.linkfun(df$tau)
    tform <- tformula
    tform[[2]] <- as.name("tau")
    tmod <- lm(tform,data=data.frame(tdf))
    tcoeff <- coefficients(tmod)
    tformula[[2]] <- NULL
  }
  
  mod <- new("GamlssModel",family=dist)
  
  if(nopar > 0) {
    mod@mu <- new("ParModel",
      formula=mformula,
      coefficients=mcoeff)
  }
  if(nopar > 1) {
    mod@sigma <- new("ParModel",
      formula=sformula,
      coefficients=scoeff)
  }
  if(nopar > 2) {
    mod@nu <- new("ParModel",
      formula=nformula,
      coefficients=ncoeff)
  }
  if(nopar > 3) {
    mod@tau <- new("ParModel",
      formula=tformula,
      coefficients=tcoeff)
  }
  return(mod)
}

SimDatModelFromGlmWizardDf <- function(df,mod=NULL) {

  if(!is(df,"GlmWizardDf")) stop("df must be of class GlmWizardDf")
  
  if(is.null(mod)) {
    mod <- new("SimDatModel")
    # this will need n's in the df
    if(is.null(df$n)) stop("df needs a column named n")
    gamlssmod <- GamlssModelFromGlmWizardDf(df)
    DV <- new("RandomIntervalVariable",
      name = df@dependent,
      min = -Inf,
      max = Inf)
    
    
  } else {
    if(!is(mod,"SimDatModel")) stop("model must be of class SimDatModel")
    
    
  }
  return(mod)
}

#arglist <- list()
#arglist["dep"] <- variables(tmp)[names(variables(tmp)) == "Y"]
#dat <- do.call("GlmWizardDf",args=arglist)
