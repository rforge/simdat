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
    # don't need to expand factors
    dat <- switch(family$nopar,
        data.frame(mu=mu),
        data.frame(mu=mu,sigma=sigma),
        data.frame(mu=mu,sigma=sigma,nu=nu),
        data.frame(mu=mu,sigma=sigma,nu=nu,tau=tau))
  }
  if(!is.null(num)) {
  
    if(!is(num,"VariableList")) num <- VariableList(list(num))
    
    # add a beta for each numeric
    betas <- as.data.frame(rep(0,length=length(num)))
    colnames(betas) <- paste("beta(",names(num),")",sep="")
    dat <- cbind(dat,betas)
  }
  dat <- new("GlmWizardDf",
    @.Data <- dat,
    dependent=names(dep),
    factor=names(fac),
    numeric=names(num),
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
  facNames <- df@factor 
  numNames <- df@numeric
  
  tdf <- df
  if(nopar > 0) {
    if(length(unique(df$mu))!=1) {
      # assume identical slopes for now...
      terms <- paste(facNames,collapse="*")
      if(!is.null(numNames)) terms <- paste(terms,"+",paste(numNames,collapse = "+")) 
      mformula <- as.formula(paste(DVname,"~",terms))
    } else {
      mFormula <- as.formula(paste(DVname,"~",1))
    }
    tdf$mu <- dist$mu.linkfun(df$mu)
    tform <- mformula
    tform[[2]] <- "mu"
    mmod <- lm(tform,data=tdf)
    mcoeff <- coefficients(mmod)
  }
  if(nopar > 1) {
    if(length(unique(df$sigma))!=1) {
      # assume identical slopes for now...
      terms <- paste(facNames,collapse="*")
      if(!is.null(numNames)) terms <- paste(terms,"+",paste(numNames,collapse = "+")) 
      sformula <- as.formula(paste(DVname,"~",terms))
    } else {
      sFormula <- as.formula(paste(DVname,"~",1))
    }
    tdf$sigma <- dist$sigma.linkfun(df$sigma)
    tform <- sformula
    tform[[2]] <- "sigma"
    smod <- lm(tform,data=tdf)
    scoeff <- coefficients(smod)
  }
  if(nopar > 2) {
    if(length(unique(df$nu))!=1) {
      # assume identical slopes for now...
      terms <- paste(facNames,collapse="*")
      if(!is.null(numNames)) terms <- paste(terms,"+",paste(numNames,collapse = "+")) 
      nformula <- as.formula(paste(DVname,"~",terms))
    } else {
      nFormula <- as.formula(paste(DVname,"~",1))
    }
    tdf$nu <- dist$nu.linkfun(df$nu)
    tform <- nformula
    tform[[2]] <- "nu"
    nmod <- lm(tform,data=tdf)
    ncoeff <- coefficients(nmod)
  }
  if(nopar > 3) {
    if(length(unique(df$tau))!=1) {
      # assume identical slopes for now...
      terms <- paste(facNames,collapse="*")
      if(!is.null(numNames)) terms <- paste(terms,"+",paste(numNames,collapse = "+"))
      tformula <- as.formula(paste(DVname,"~",terms))
    } else {
      tFormula <- as.formula(paste(DVname,"~",1))
    }
    tdf$tau <- dist$tau.linkfun(df$tau)
    tform <- tformula
    tform[[2]] <- "tau"
    tmod <- lm(tform,data=tdf)
    tcoeff <- coefficients(tmod)
  }
  
  mod <- new("GamlssModel",family=dist)
  
  if(nopar > 0) {
    mod@mu <- new("ParModel",
      formula=mFormula,
      coefficients=mcoeff)
  }
  if(nopar > 1) {
    mod@sigma <- new("ParModel",
      formula=sFormula,
      coefficients=scoeff)
  }
  if(nopar > 2) {
    mod@nu <- new("ParModel",
      formula=nFormula,
      coefficients=ncoeff)
  }
  if(nopar > 3) {
    mod@tau <- new("ParModel",
      formula=tFormula,
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
    
  } else {
    if(!is(mod,"SimDatModel")) stop("model must be of class SimDatModel")
    
    
  }
  return(mod)
}

#arglist <- list()
#arglist["dep"] <- variables(tmp)[names(variables(tmp)) == "Y"]
#dat <- do.call("GlmWizardDf",args=arglist)
