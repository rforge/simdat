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
        
        args <- list()
        
        factor  <- object@factor
        for(i in 1:length(factor)) {
            factor[[i]]@.Data <- df[,names(factor)[i]]@.Data
        }
        
        args[["design"]] <- factor
        
        family <- object@family
        
        args[["family"]] <- family
        
        args[["N"]] <- df[,"N"]
        
        if(family$nopar > 0) args[["mu"]] <- df[,"mu"]
        
        if(family$nopar > 1) args[["sigma"]] <- df[,"sigma"]
        
        if(family$nopar > 2) args[["nu"]] <- df[,"nu"]
        
        if(family$nopar > 3) args[["tau"]] <- df[,"tau"]
        
        args[["DV"]] <- object@dependent
        
        #family <- object@family
        
        out <- do.call("ANOVA",args=args)
        
        #(design=factor,N=N,mu=mu,sigma=sigma,nu=nu,tau=tau,DV=DV,family=family)
        
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
        
        args <- list()
        
        between <- object@bdesign
        for(i in 1:length(between)) {
            between[[i]]@.Data <- bdf[,names(between)[i]]@.Data
        }
        
        args[["between"]] <- between
        
        within <- object@wdesign
        twithin <- unique(getData(within))
        for(i in 1:length(within)) {
            within[[i]]@.Data <- twithin[,names(within)[i]]@.Data
        }
        
        args[["within"]] <- within
        
        family <- object@family
        
        args[["family"]] <- family
        args[["N"]] <- bdf[,"N"]
        
        wdat <- getData(within)
        wnames <- apply(wdat,1,function(x) paste(x,collapse="."))
      
        if(family$nopar > 0) {
          mu <- bdf[,paste("mu",wnames,sep=".")]
          args[["mu"]] <- mu
          print(mu)
        }
        
        if(family$nopar > 1) {
          args[["bsigma"]] <- bdf[,"sigma.between"]
          args[["wsigma"]] <- wdf["sigma",]
        }
        
        if(family$nopar > 2) {
          bnu <- bdf[,"nu.between"]
          wnu <- wdf["nu",]
          nu <- matrix(bnu,nrow=length(bnu),ncol=length(wnu))
          
          #print(nu)
          
          #print(wnu)
          
          nu <- t(t(nu) + as.numeric(wnu))
          
          #print(nu)
          
          args[["nu"]] <- nu
        }
        
        if(family$nopar > 3) {
          btau <- bdf[,"tau.between"]
          wtau <- wdf["tau",]
          tau <- matrix(btau,nrow=length(btau),ncol=length(wtau))
          tau <- t(t(tau) + as.numeric(wtau))
          args[["tau"]] <- tau
        }
        
        #wsds <- wdf["sigma",]
        
        args[["DV"]] <- object@dependent
        
        #family <- object@family
        
        out <- do.call("rmANOVA",args=args)
        #(between=between,within=within,N=N,means=means,bsds=bsds,wsds=wsds,DV=DV,family=family,id.name=object@ID.name,display.direction="wide")
        
        return(out)
    }
)

setClass("GlmWizardModel",
  contains="WizardModel",
  representation(
    dependent="Variable",
    factor="VariableList",
    numeric="VariableList",
    models="ModelList",
    family="gamlss.family")
)

GlmWizardModel <- function(dep,fac=NULL,num=NULL,mod=NULL,fam) {
    if(!is(dep,"Variable")) stop("dependent needs to be a Variable")
    if(!is.null(fac) & !is(fac,"VariableList")) stop("factor needs to be a VariableList")
    if(!is.null(num) & !is(num,"VariableList")) stop("numeric needs to be a VariableList")
    if(!is.null(mod) & !is(mod,"ModelList")) stop("model needs to be a ModelList")
    if(!is(fam,"gamlss.family")) stop("family needs to be a gamlss.family")
    if(is.null(fac)) fac <- VariableList(list())
    if(is.null(num)) num <- VariableList(list())
    if(is.null(mod)) mod <- ModelList(list())
    out <- new("GlmWizardModel",
        dependent = dep,
        factor = fac,
        numeric=num,
        models=mod,
        family = fam)
    return(out)
}

setMethod("getWizardDf","GlmWizardModel", 
  function(object,which=c("between","nummodel")) {
      which <- match.arg(which)
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
        numnames <- numnames[nchar(numnames) > 0]
        if(length(numnames) > 0) {
          for(i in 1:length(numnames)) {
            dat[,paste("beta.",numnames[i],sep="")] <- 0
          }
        }
        return(dat)
      }
      if(which=="nummodel") {
        numnames <- names(object@numeric)
        numnames <- numnames[nchar(numnames) > 0]
        if(length(numnames) > 0) {
          dat <- data.frame(name=numnames)
          dat[,"model"] <- factor(rep("normal",nrow(dat)),levels=unique(.SimDatDistributionNames()))
          dat[,"mu"] <- 0
          dat[,"sigma"] <- 1
          dat[,"nu"] <- 0
          dat[,"tau"] <- 0
          return(dat)
        } else {
          return(data.frame())
        }
        
      }
  }
)

setMethod("makeSimDatModel","GlmWizardModel",
    function(object,df,nummodels,...) {
        
        args <- list()
        
        factor  <- object@factor
        numeric <- object@numeric
        
        for(i in 1:length(factor)) {
            factor[[i]]@.Data <- df[,names(factor)[i]]@.Data
        }
        
        args[["factors"]] <- factor
        
        #args[["covariates"]] <- numeric
        
        family <- object@family
        
        args[["family"]] <- family
        
        args[["N"]] <- df[,"N"]
        
        if(family$nopar > 0) args[["mu"]] <- df[,"mu"]
        
        if(family$nopar > 1) args[["sigma"]] <- df[,"sigma"]
        
        if(family$nopar > 2) args[["nu"]] <- df[,"nu"]
        
        if(family$nopar > 3) args[["tau"]] <- df[,"tau"]
        
        args[["beta"]] <- as.matrix(df[,agrep("beta.",colnames(df))])
        
        args[["DV"]] <- object@dependent
        
        #family <- object@family
        
        random <- VariableList(numeric[isRandom(numeric)])
        if(length(random) > 0) {
            covariateModels <- vector("list",length=length(random))
            for(i in 1:length(random)) {
                fam <- .SimDatGetDistributionFromName(nummodels$model[i])
                mod <- new("GamlssModel",
                    mu=new("ParModel",formula=~1,coefficients=fam$mu.linkfun(nummodels$mu[i])),
                    family=fam)
                if(fam$nopar > 1) mod@sigma  <- new("ParModel",formula=~1,coefficients=fam$sigma.linkfun(nummodels$sigma[i]))
                if(fam$nopar > 2) mod@nu  <- new("ParModel",formula=~1,fam$nu.linkfun(nummodels$nu[i]))
                if(fam$nopar > 3) mod@tau  <- new("ParModel",formula=~1,fam$tau.linkfun(nummodels$tau[i]))
                covariateModels[[i]] <- mod
                random[[i]]@.Data <- rep(nummodels$mu[i],sum(N))
            }
            
            args[["covariateModels"]] <- covariateModels
        }
        
        
        # give covariates some good values
        numeric[isRandom(numeric)] <- random
        
        args[["covariates"]] <- numeric
        
        out <- do.call("GLM",args=args)
        
        #out <- GLM(factors=factor,covariates=numeric,N=N,means=means,sds=sds,DV=DV,family=family)
        
        #(design=factor,N=N,mu=mu,sigma=sigma,nu=nu,tau=tau,DV=DV,family=family)
        
        return(out)
    }
)



