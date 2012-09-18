setClass("rmANOVA",
  contains="SimDatModel",
  representation(
    DVwide="character", # names for within variables in wide format
    DVlong="character", # names for within variables in long format
    wvars="character", # names of within variables in long format
    wdesign="data.frame",
    direction="character", # display in wide or long format?
    IDvar="character" # name of subject ID variable
  )
)

setMethod("getData",
  signature(object="rmANOVA"),
    function(object,...,direction) {
      if(!missing(direction)) {
        if(!(direction %in% c("wide","long"))) {
        stop("argument direction given, but not equal to 'wide' or 'long'")
        }
      } else direction <- object@direction
      dat <- getData(object@variables,...)
      if(direction == "wide") {
        # should turn data into a wide format...
        mtimevar <- paste("timevar",sample(1:1000,size=1),sep="")
        while(mtimevar %in% names(dat)) {
          mtimevar <- paste("timevar",sample(1:1000,size=1),sep="")
        }
        dat[,mtimevar] <- interaction(dat[,object@wvars])
        dat <- reshape(dat,direction="wide",timevar=mtimevar,idvar=object@IDvar,v.names=object@DVlong,drop=object@wvars)
        if(length(object@DVwide) > 0) {
          colnames(dat) <- c(colnames(dat)[1:(ncol(dat) - length(object@DVwide))],object@DVwide)
        }
        rownames(dat) <- NULL
      }
      dat
    }
)

rmANOVA <- function(DV,family=NO(),between,within,N,mu,bsigma,wsigma,nu,tau,id.name="ID",display.direction=c("wide","long")) {

    display.direction <- match.arg(display.direction)

    if(is.data.frame(between)) {
        if(!all(unlist(lapply(between,is.factor)))) stop("between should be a data.frame with factors")
        tbetween <- between
    } else if(is(between,"VariableList")) {
        if(!all(unlist(lapply(between,isMetric)) == FALSE)) stop("between should be a VariableList with Nominal or Ordinal variables")
        tbetween <- getData(between)
        #colnames(tbetween) <- names(between)
    } else {
      stop("between should be a data.frame or VariableList")
    }
    if(is.data.frame(within)) {
        if(!all(unlist(lapply(within,is.factor)))) stop("within should be a data.frame with factors")
        twithin <- within
    } else if(is(within,"VariableList")) {
        if(!all(unlist(lapply(within,isMetric)) == FALSE)) stop("within should be a VariableList with Nominal or Ordinal variables")
        twithin <- getData(within)
        #colnames(twithin) <- names(within)
    } else {
      stop("within should be a data.frame or VariableList")
    }
    if(any(colnames(twithin) %in% colnames(tbetween))) stop("within factors cannot have same names as between factors")

    # DV can be a list or (metric) Variable
    if(is.list(DV)) {
      if(is.null(DV$name)) DV$name <- "Y"
      if(is.null(DV$min)) DV$min <- -Inf
      if(is.null(DV$max)) DV$max <- Inf
      if(is.null(DV$digits)) DV$digits=8
      if(length(DV$name) != 1) stop("rmANOVA can only have a single dependent variable")
    } else if(is(DV,"Variable")) {
      if(!isMetric(DV)) stop("DV is not a metric Variable")
    } else {
      stop("DV should be a list or Variable")
    }
    # family must be a gamlss.family object
    if(!is(family,"gamlss.family")) stop("family should be a gamlss.family object")
    
    if(id.name %in% colnames(within) | id.name %in% colnames(between)) stop("id.name cannot be in between or within arguments")
    
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

    nCellsB <- NROW(tbetween)
    nCellsW <- NROW(twithin)
    nWithin <- NCOL(twithin)
    nBetween <- NCOL(twithin)
    nCellsT <- NROW(tbetween)*NROW(twithin)
    
    if(!is.matrix(mu)) mu <- as.matrix(mu) 
    if(ncol(mu) != NROW(twithin) || nrow(mu) != NROW(tbetween)) {
      if(length(mu)!=1) warning("mu does not have correct size")
      mu <- matrix(rep(mu,length=nCellsT),ncol=nCellsW,nrow=nCellsB)
    }

    npar <- family$nopar
    
    #nBetween <- NROW(tbetween)
    #nWithin <- NROW(twithin)
    
    N <- matchArg(N,nCellsB,"N")
    #means <- matchArg(means[,1],nCells,"means")
    if(npar>1) {
      bsigma <- matchArg(bsigma,nCellsB,"bsigma")
      wsigma <- matchArg(wsigma,nCellsW,"wsigma")
    }
    
    if(npar>2) {
      nu <- matchArg(nu,nCellsT,"nu")
      if(!is.matrix(nu)) nu <- matrix(nu,nrow=nCellsB,ncol=nCellsW)
    }
    if(npar>3) {
      tau <- matchArg(tau,nCellsT,"tau")
      if(!is.matrix(tau)) tau <- matrix(nu,nrow=nCellsB,ncol=nCellsW)
    }
    
    nIV <- nBetween + nWithin
    tbetween <- data.frame(lapply(tbetween,rep,times=N))
    designMatrix <- cbind(as.data.frame(lapply(tbetween,rep,each=max(nCellsW,1))),twithin)
    #designMatrix <- between
    #designMatrix <- data.frame(lapply(designMatrix,rep,times=N))
    factor.names <- c(colnames(tbetween),colnames(twithin))
    
    IDvar <- new("NominalVariable",
        factor(rep(1:sum(N),each=nCellsW)),
        name = id.name
    )
    
        
    if(is.data.frame(between)) {
      bIVs <- vector("list",length=nBetween)
      if(nBetween > 0) {
        for(i in 1:nBetween) {
            bIVs[[i]] <- new("NominalVariable",
              designMatrix[,i],
              name = colnames(designMatrix)[i]
            )
        }
      }
    } else {
      bIVs <- between
      if(nBetween > 0) {
        for(i in 1:nBetween) {
            bIVs[[i]]@.Data <- designMatrix[,i]
        }
      }
   }
   
   if(is.data.frame(within)) {
      wIVs <- vector("list",length=nWithin)
      if(nWithin > 0) {
        for(i in 1:nWithin) {
            wIVs[[i]] <- new("NominalVariable",
              designMatrix[,nBetween + i],
              name = colnames(designMatrix)[nBetween + i]
            )
        }
      }
    } else {
      wIVs <- within
      if(nWithin > 0) {
        for(i in 1:nWithin) {
            wIVs[[i]]@.Data <- designMatrix[,nBetween + i]
        }
      }
   }
        
   IVs <- VariableList(c(list(IDvar),bIVs,wIVs))

    
    if(!is(DV,"Variable")) {
        wnames <- paste(DV$name,apply(twithin,1,paste,collapse="."),sep=".")
        DVs <- new("RandomIntervalVariable",
            rep(NA,sum(N)*length(wnames)), # TODO: change computation of N
            name = DV$name,
            min=DV$min,
            max=DV$max,
            digits=as.integer(DV$digits)
        )
    } else {
        wnames <- paste(DV@name,apply(twithin,1,paste,collapse="."),sep=".")
        DVs <- DV
        DVs@.Data <- rep(DVs@.Data,length=sum(N)*length(wnames)) # TODO: change computation of N
    }
    
    mFormula <- as.formula(paste(DVs@name,"~",paste(factor.names,collapse="*")))
    dat <- getData(IVs)
    dat <- cbind(dat,family$mu.linkfun(as.vector(t(apply(mu,2,rep,times=N)))))
    colnames(dat) <- c(names(IVs),names(DVs))
    mmod <- lm(mFormula,data=dat)
    mcoeff <- coefficients(mmod)
    
    # random intercept model
    rFormula <- as.formula(paste(DVs@name,"~ 1"))
    rcoeff <- matrix(rnorm(length(unique(IDvar)),mean=0,sd=rep(bsigma,N)),ncol=1)
    grouping <- as.numeric(IDvar)
    if(length(unique(bsigma))>1) {
      rsigma <- array(rep(bsigma^2,N),dim=c(1,1,sum(N)))
    } else {
      rsigma <- array(bsigma^2,dim=c(1,1,1))
    }
    
    # sigma
    # TODO: correct computation!
    if(npar > 1) {
      if(length(unique(wsigma))!=1) {
        sFormula <- as.formula(paste(DVs@name,"~",paste(factor.names,collapse="*")))
      } else {
        sFormula <- as.formula(paste(DVs@name,"~",1))
      }
      dat <- getData(IVs)
      #colnames(dat) <- names(fixed)
      #dat <- cbind(dat,as.vector(t(apply(wsds,2,rep,times=N))))
      
      # assumes (a variant of) compound symmetry:
      #dat <- cbind(dat,rep(bsds,N) + wsds)
      dat <- cbind(dat, family$sigma.linkfun(wsigma))
      
      colnames(dat) <- c(names(IVs),names(DVs))
      #dat[,DV$name] <- DV$family$sigma.linkfun(rep(wsds,N))
      #dat[,] <- 
      smod <- lm(sFormula,data=dat)
      scoeff <- coefficients(smod)
      sFormula[[2]] <- NULL
          
    }
    
    if(npar > 2) {
      nFormula <- as.formula(paste(DVs@name,"~",paste(factor.names,collapse="*")))
      dat <- getData(IVs)
      dat <- cbind(dat,family$nu.linkfun(as.vector(t(apply(nu,2,rep,times=N)))))
      colnames(dat) <- c(names(IVs),names(DVs))
      nmod <- lm(nFormula,data=dat)
      ncoeff <- coefficients(nmod)
    }
    
    if(npar > 3) {
      tFormula <- as.formula(paste(DVs@name,"~",paste(factor.names,collapse="*")))
      dat <- getData(IVs)
      dat <- cbind(dat,family$tau.linkfun(as.vector(t(apply(tau,2,rep,times=N)))))
      colnames(dat) <- c(names(IVs),names(DVs))
      tmod <- lm(tFormula,data=dat)
      tcoeff <- coefficients(tmod)
    }
    # now make the DV model
    mod <- new("GammlssModel",
      mu=new("MixedParModel",
        #fixed=new("ParModel",
          formula=mFormula,
          coefficients=mcoeff,#),
        random=new("RandomParModel",
          formula=rFormula,
          coefficients=rcoeff,
          grouping = grouping,
          sigma = rsigma)),
          family=family)
    if(npar > 1) {      
      mod@sigma=new("ParModel",
        formula=sFormula,
        coefficients=scoeff)
    }
    if(npar > 2) {      
      mod@nu=new("ParModel",
        formula=nFormula,
        coefficients=ncoeff)
    }
    if(npar > 3) {      
      mod@tau=new("ParModel",
        formula=tFormula,
        coefficients=tcoeff)
    }
      
    DVs <- simulateFromModel(object=DVs,model=mod,data=dat)
    
    structure <- matrix(0,ncol=(length(IVs) + 1),nrow=(length(IVs) + 1))
    structure[-nrow(structure),ncol(structure)] <- 1
    
    sdmod <- new("rmANOVA",
      variables=VariableList(c(IVs,list(DVs))),
      models=ModelList(list(mod)),
      modelID=c(rep(0,length(IVs)),1),
      structure=structure,
      DVwide=wnames,
      DVlong=DVs@name,
      wvars=names(within),
      wdesign=twithin,
      direction=display.direction,
      IDvar = names(IDvar)
    )
    
    return(sdmod)
    
}

setMethod("summary",signature(object="rmANOVA"),
    function(object,...,type=c("aov","lm","glm"),SStype=3) {
        type <- match.arg(type)
        vars <- variables(object,...)
        fixed <- VariableList(vars[!isRandom(vars)])
        fixed <- VariableList(fixed[!variableNames(fixed) == object@IDvar])
        random <- VariableList(vars[isRandom(vars)])
        for(i in 1:length(random)) {
            n <- aggregate(random[i],by=fixed,FUN=length)
            means <- aggregate(random[i],by=fixed,FUN=mean)
            vars <- aggregate(random[i],by=fixed,FUN=var)
            out <- cbind(n,means[,ncol(means)],sqrt(vars[,ncol(vars)]))
            colnames(out) <- c(variableNames(fixed),"n","mean","sd")
            cat("Variable ",variableNames(random)[[i]],": \n",sep="")
            print(out)
            cat("\n")
        }
        models <- ModelList(models(object))
        for(i in 1:length(models)) {
            if(i == object@modelID[variableNames(object) == object@DVlong]) {
                # need a special summary here
                bfacs <- variableNames(fixed)
                bfacs <- bfacs[!(bfacs %in% object@wvars)]
                form <- as.formula(paste("cbind(",paste(object@DVwide,collapse=","),") ~ ",paste(bfacs,collapse="*")))
                iform <- as.formula(paste("~",paste(object@wvars,collapse="*")))
                mod <- lm(form,data=getData(object))
                summary(Anova(mod, idata=object@wdesign, idesign=iform,type=SStype),multivariate=FALSE,singular.ok=TRUE) # already prints
                #print(summ)
            } else {
                summ <- summary(models[[i]],data=getData(object),type=type,SStype=SStype,...)
                if(!is.null(summ)) {
                    cat("Variable ",variableNames(object)[which(object@modelID == i)],": \n",sep="")
                    print(summ)
                }
            }
        }
    }
)
