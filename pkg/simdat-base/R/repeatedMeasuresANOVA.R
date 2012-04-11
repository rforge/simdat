setClass("rmANOVA",
  contains="SimDatModel",
  representation(
    DVwide="character", # names for within variables in wide format
    DVlong="character", # names for within variables in long format
    wvars="character", # names of within variables in long format
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

rmANOVA <- function(between=data.frame(A=factor(c(1,1,2,2),labels=c("A1","A2")),B=factor(c(1,2,1,3),labels=c("B1","B2","B3"))),within=data.frame(V=factor(c(1,1,2,2),labels=c("V1","V2")),W=factor(c(1,2,1,3),labels=c("W1","W2","W3"))),N=rep(20,4),means=cbind(c(0,1,2,3),c(1,2,3,4),c(3,4,5,6),c(6,7,8,9)),bsds=c(2,2,2,2),wsds=matrix(2,ncol=4,nrow=4),DV=list(name="Y",min=-Inf,max=Inf,digits=8,family=NO()),id.name="ID",display.direction=c("wide","long")) {

    display.direction <- match.arg(display.direction)

    if(!all(unlist(lapply(between,is.factor)))) stop("between should be a data.frame with factors")
    if(!all(unlist(lapply(within,is.factor)))) stop("within should be a data.frame with factors")

    if(any(colnames(within) %in% colnames(between))) stop("within factors cannot have same names as between factors")

    if(is.null(DV$name)) DV$name <- "Y"
    if(is.null(DV$min)) DV$min <- -Inf
    if(is.null(DV$max)) DV$max <- Inf
    if(is.null(DV$digits)) DV$digits <- getOption("digits")
    #if(is.null(DV$family)) DV$family <- gamlss.dist::NO()
    if(length(DV$name) != 1) stop("Repeated Measures ANOVA can only have a single dependent variable")
    
    if(id.name %in% colnames(within) | id.name %in% colnames(between)) stop("is.name cannot be in between or within arguments")
    
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

    if(!is.matrix(means)) means <- as.matrix(means) 

    nCells <- NROW(between) 
    N <- matchArg(N,nCells,"N")
    #means <- matchArg(means[,1],nCells,"means")
    bsds <- matchArg(bsds,nCells,"sds")
    
    nIV <- sum(NCOL(between),NCOL(within))
    tbetween <- data.frame(lapply(between,rep,times=N))
    designMatrix <- cbind(as.data.frame(lapply(tbetween,rep,each=max(NROW(within),1))),within)
    #designMatrix <- between
    #designMatrix <- data.frame(lapply(designMatrix,rep,times=N))
    factor.names <- c(colnames(between),colnames(within))
    
    IDvar <- new("NominalVariable",
          factor(rep(1:sum(N),each=NROW(within))),
          name = id.name
    )
    
    IVs <- list()
    for(i in 1:nIV) {
        IVs[[i]] <- new("NominalVariable",
          designMatrix[,i],
          name = colnames(designMatrix)[i]
        )
    }
    IVs <- VariableList(c(list(IDvar),IVs))
    
    wnames <- paste(DV$name,apply(within,1,paste,collapse="."),sep=".")
    
    #DVs <- list()
    #for(i in 1:NROW(within)) {
    #  DVs[[i]] <- new("RandomIntervalVariable",
    #    rep(NA,sum(N)),
    #    name = wnames[i],
    #    min=DV$min,
    #    max=DV$max,
    #    digits=as.integer(DV$digits)
    #  )
    #}
    #DVs <- list(DVs)
    
    DVs <- new("RandomIntervalVariable",
        rep(NA,sum(N)*length(wnames)), # TODO: change computation of N
        name = DV$name,
        min=DV$min,
        max=DV$max,
        digits=as.integer(DV$digits)
    )
    
    #mFormula <- as.formula(paste(paste("cbind(",paste(wnames,collapse=","),") ","~",paste(factor.names,collapse="*"))))
    mFormula <- as.formula(paste(DVs@name,"~",paste(factor.names,collapse="*")))
    dat <- getData(IVs)
    #colnames(dat) <- names(fixed)
    dat <- cbind(dat,as.vector(t(apply(means,2,rep,times=N))))
    colnames(dat) <- c(names(IVs),names(DVs))
    #dat[,] <- 
    mmod <- lm(mFormula,data=dat)
    mcoeff <- coefficients(mmod)
    
    # sigma
    # TODO: correct computation!
    if(length(unique(wsds))!=1) {
      sFormula <- as.formula(paste(DVs@name,"~",paste(factor.names,collapse="*")))
    } else {
      sFormula <- as.formula(paste(DVs@name,"~",1))
    }
    dat <- getData(IVs)
    #colnames(dat) <- names(fixed)
    dat <- cbind(dat,as.vector(t(apply(wsds,2,rep,times=N))))
    colnames(dat) <- c(names(IVs),names(DVs))
    #dat[,DV$name] <- DV$family$sigma.linkfun(rep(wsds,N))
    #dat[,] <- 
    smod <- lm(sFormula,data=dat)
    scoeff <- coefficients(smod)
    sFormula[[2]] <- NULL
        
    # random intercept model
    rFormula <- as.formula(paste(DVs@name,"~ 1"))
    rcoeff <- matrix(rnorm(length(unique(IDvar)),mean=0,sd=rep(bsds,N)),ncol=1)
    grouping <- as.numeric(IDvar)
    if(length(unique(bsds))>1) {
      rsigma <- array(rep(bsds^2,N),dim=c(1,1,sum(N)))
    } else {
      rsigma <- array(bsds^2,dim=c(1,1,1))
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
      sigma=new("ParModel",
        formula=sFormula,
        coefficients=scoeff),
      family=DV$family)
      
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
      direction=display.direction,
      IDvar = names(IDvar)
    )
    
    return(sdmod)
    
}

