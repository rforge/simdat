setClass("WizardModel")

setClass("AnovaWizardModel",
  contains="WizardModel",
  representation(
    dependent="Variable",
    factor="VariableList",
    family="gamlss.family")
)

AnovaWizardModel <- function(dep,fac,fam) {
    if(!is(dep,"Variable")) stop("dependent needs to be a Variable")
    if(!is(fac,"VariableList")) stop("factor needs to be a VariableList")
    if(!is(fam,"gamlss.family")) stop("family needs to be a gamlss.family")
    out <- new("AnovaWizardModel",
        dependent = dep,
        factor = fac,
        family = fam)
    return(out)
}

makeFactorialDesign <- function(varList) {
  if(!is(varList,"VariableList")) stop("need a VariableList")
  if(any(unlist(lapply(varList,isMetric)))) stop("can only work with nonMetric variables")
  dat <- expand.grid(lapply(varList,levels))
  for(i in 1:length(varList)) {
    varList[[i]]@.Data <- dat[,i]
  }
  return(varList)
}

setMethod("getWizardDf","AnovaWizardModel", 
  function(object) {
    nopar <- object@family$nopar
      dat <- getData(object@factor)
      if(NROW(dat) < 1 || NCOL(dat) < 1) {
        dat <- data.frame(NA)
      }
      # need to get unique rows in dat
      dat <- unique(dat)
      dat[,"N"] <- as.integer(rep(10,nrow(dat)))
      if(nopar > 0) {
        dat[,"mu"] <- 0
      }
      if(nopar > 1) {
        dat[,"sigma"] <- 1
      }
      if(nopar > 2) {
        dat[,"nu"] <- 0
      }
      if(nopar > 3) {
        dat[,"tau"] <- 0
      }
      return(dat)
  }
)

setMethod("makeSimDatModel","AnovaWizardModel",
    function(object,df,...) {
        
        factor <- object@factor
        for(i in 1:length(factor)) {
            factor[[i]]@.Data <- df[,names(factor)[i]]@.Data
        }
        
        family <- object@family
        
        N <- df[,"N"]
        
        mu <- df[,"mu"]
        
        sigma <- df[,"sigma"]
        
        nu <- df[,"nu"]
        
        tau <- df[,"tau"]
        
        DV <- object@dependent
        
        family <- object@family
        
        out <- ANOVA(design=factor,N=N,mu=mu,sigma=sigma,nu=nu,tau=tau,DV=DV,family=family)
        
        return(out)
    }
)


setClass("RmAnovaWizardModel",
  contains="WizardModel",
  representation(
    dependent="Variable",
    bdesign="VariableList",
    wdesign="VariableList",
    #numeric="VariableList",
    family="gamlss.family",
    ID.name="character")
)

RmAnovaWizardModel <- function(dep,bfac,wfac,fam,ID.name="ID") {
    if(!is(dep,"Variable")) stop("dependent needs to be a Variable")
    if(!is(bfac,"VariableList")) stop("between factor needs to be a VariableList")
    if(!is(wfac,"VariableList")) stop("within factor needs to be a VariableList")
    if(!is(fam,"gamlss.family")) stop("family needs to be a gamlss.family")
    out <- new("RmAnovaWizardModel",
        dependent = dep,
        bdesign = bfac,
        wdesign = wfac,
        family = fam,
        ID.name=ID.name)
    return(out)
}

setMethod("getWizardDf","RmAnovaWizardModel", 
  function(object,which=c("between","within")) {
    which=match.arg(which)
    nopar <- object@family$nopar
    if(which == "between") {
      bdat <- getData(object@bdesign)
      if(NROW(bdat) < 1 || NCOL(bdat) < 1) {
        bdat <- data.frame(NA)
      }
      bdat <- unique(bdat)
      wdat <- getData(object@wdesign)
      wdat <- unique(wdat)
      #if(NROW(wdat) < 1 || NCOL(wdat) < 1) {
      #  wdat <- data.frame(NA)
      #}
      wnames <- apply(wdat,1,function(x) paste(x,collapse="."))
      bdat[,"N"] <- as.integer(rep(10,nrow(bdat)))
      if(nopar > 0) {
        munames <- paste("mu",wnames,sep=".")
        bdat[,munames] <- 0
      }
      if(nopar > 1) {
        bdat[,"sigma.between"] <- 1
      }
      if(nopar > 2) {
        bdat[,"nu.between"] <- 0
      }
      if(nopar > 3) {
        bdat[,"tau.between"] <- 0
      }
      return(bdat)
    }
    if(which=="within") {
      wdat <- getData(object@wdesign)
      wdat <- unique(wdat)
      out <- as.data.frame(matrix(,nrow=nopar - 1,ncol=NROW(wdat)))
      wnames <- apply(wdat,1,function(x) paste(x,collapse="."))
      colnames(out) <- wnames
      
      if(nopar < 2) return(data.frame()) else rownames(out) <- c("sigma","nu","tau")[1:(nopar - 1)]
      if(nopar > 1) out[1,] <- 1
      if(nopar > 2) out[2,] <- 0
      if(nopar > 3) out[3,] <- 0
      return(out)
    }
  }
)

setMethod("makeSimDatModel","RmAnovaWizardModel",
    function(object,bdf,wdf,...) {
        
        between <- object@bdesign
        for(i in 1:length(between)) {
            between[[i]]@.Data <- bdf[,names(between)[i]]@.Data
        }
        
        within <- object@wdesign
        twithin <- unique(getData(within))
        for(i in 1:length(within)) {
            within[[i]]@.Data <- twithin[,names(within)[i]]@.Data
        }
        
        family <- object@family
        
        N <- bdf[,"N"]
        
        wdat <- getData(within)
        wnames <- apply(wdat,1,function(x) paste(x,collapse="."))
      
        means <- bdf[,paste("mu",wnames,sep=".")]
        
        bsds <- bdf[,"sigma.between"]
        
        wsds <- wdf[1,]
        
        DV <- object@dependent
        
        family <- object@family
        
        out <- rmANOVA(between=between,within=within,N=N,means=means,bsds=bsds,wsds=wsds,DV=DV,family=family,id.name=object@ID.name,display.direction="wide")
        
        return(out)
    }
)

setClass("GlmWizardModel",
  contains="WizardModel",
  representation(
    dependent="Variable",
    factor="VariableList",
    numeric="VariableList",
    family="gamlss.family")
)

GlmWizardModel <- function(dep,fac,num,fam) {
    if(!is(dep,"Variable")) stop("dependent needs to be a Variable")
    if(!is(fac,"VariableList")) stop("factor needs to be a VariableList")
    if(!is(num,"VariableList")) stop("numeric needs to be a VariableList")
    if(!is(fam,"gamlss.family")) stop("family needs to be a gamlss.family")
    out <- new("GlmWizardModel",
        dependent = dep,
        factor = fac,
        numeric=num,
        family = fam)
    return(out)
}

setMethod("getWizardDf","GlmWizardModel", 
  function(object,which=c("between","nummodel")) {
      which=match.arg(which)
      nopar <- object@family$nopar
      if(which == "between") {
        dat <- getData(object@factor)
        if(NROW(dat) < 1 || NCOL(dat) < 1) {
          dat <- data.frame(NA)
        }
        # need to get unique rows in dat
        dat <- unique(dat)
        dat[,"N"] <- as.integer(rep(10,nrow(dat)))
        if(nopar > 0) {
          dat[,"mu"] <- 0
        }
        if(nopar > 1) {
          dat[,"sigma"] <- 1
        }
        if(nopar > 2) {
          dat[,"nu"] <- 0
        }
        if(nopar > 3) {
          dat[,"tau"] <- 0
        }
        numnames <- names(object@numeric)
        numnames <- numnames[nchar(names) > 0]
        if(length(numnames) > 0) {
          for(i in 1:length(numnames)) {
            dat[,paste("beta.",numnames[i],sep="")] <- 0
          }
        }
        return(dat)
      }
      if(which=="nummodel") {
        numnames <- names(object@numeric)
        numnames <- numnames[nchar(names) > 0]
        if(length(numnames) > 0) {
          dat <- data.frame(name=numnames)
          dat[,"model"] <- factor(rep(1,nrow(dat)),labels=c("UniformModel","NormalModel"))
          dat[,"mean"] <- 0
          dat[,"sd"] <- 1
          return(dat)
        } else {
          return(data.frame())
        }
        
      }
  }
)

setMethod("makeSimDatModel","GlmWizardModel",
    function(object,df,...) {
        
        factor <- object@factor
        numeric <- object@numeric
        for(i in 1:length(factor)) {
            factor[[i]]@.Data <- df[,names(factor)[i]]@.Data
        }
        
        family <- object@family
        
        N <- df[,"N"]
        
        mu <- df[,"mu"]
        
        sigma <- df[,"sigma"]
        
        nu <- df[,"nu"]
        
        tau <- df[,"tau"]
        
        beta <- df[,agrep("beta.",colnames(df))]
        
        DV <- object@dependent
        
        family <- object@family
        
        out <- GLM(factors=factor,covariates=numeric,N=N,means=means,sds=sds,DV=DV,family=family)
        
        return(out)
    }
)

