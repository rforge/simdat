setClass("Distribution",
  representation(
    "VIRTUAL"
  )
)

setClass("DistributionList",
  representation(
    .Data = "list"
  )
)

setValidity("DistributionList",
  method=function(object) {
    all(lapply(object,function(x) is(x,"Distribution"))==TRUE)
  }
)

setClass("NormalDistribution",
  contains="Distribution",
  representation(
    mean="numeric",
    sd="numeric"
  )
)


setMethod("mean","NormalDistribution",
    function(x,...) {
        return(x@mean)
    }
)

setReplaceMethod("mean","NormalDistribution",
    function(x,value,...) {
        if(length(x@mean) == 0) x@mean <- value else {
            if(length(value) == length(x@mean)) x@mean <- value else stop("replacement value does not have equal length to original value")
        }
        x
    }
)

setMethod("sd","NormalDistribution",
    function(x) {
        return(x@sd)
    }
)

setReplaceMethod("sd","NormalDistribution",
    function(x,value,...) {
        if(length(x@sd) == 0) x@sd <- value else {
            if(length(value) == length(x@sd)) x@sd <- value else stop("replacement value does not have equal length to original value")
        }
        x
    }
)

setMethod("var","NormalDistribution",
    function(x) {
        return((x@sd)^2)
    }
)

setReplaceMethod("var","NormalDistribution",
    function(x,value,...) {
        if(length(x@sd) == 0) x@sd <- sqrt(value) else {
            if(length(value) == length(x@var)) x@var <- value else stop("replacement value does not have equal length to original value")
        }
        x
    }
)

setMethod("simulate",signature(object="NormalDistribution"),
    function(object,nsim,seed,min,max,digits,...) {
        if(min==-Inf & max == Inf) {
            out <- rnorm(nsim,mean=mean(object),sd=sd(object),...)
        } else {
            # use a truncated normal
            # TODO: first we need the correct mean and sd
            warning("Truncated distributions won't replicate means and standard deviations yet")
            mean <- mean(object,...)
            sd <- sd(object,...)
            out <- rtnorm(nsim,mean=mean,sd=sd,lower=min,upper=max,...)
        }
        round(out,digits)
    }
)


TruncNormMoments <- function(mu,sigma,min,max) {
        d1 <- dnorm((min-mu)/sigma)
        d2 <- dnorm((max-mu)/sigma)
        p1 <- pnorm((min-mu)/sigma)
        p2 <- pnorm((max-mu)/sigma)
        mean <- mu + ((d1 - d2)/( p2 - p1))*sigma
        var <- sd^2*(1+(((min-mu)/sigma)*d1 - ((max-mu)/sigma)*d2)/(p2 - p1) - ((d1 - d2)/(p2 - p1))^2)
        return(list(mean=mean,sd=sqrt(var)))
}

# this doesn't work very well, unfortunately
calcParTruncatedNormal <- function(mean,sd,min,max) {
    opfun <- function(par,mean,sd,min,max) {
        mu <- par[1]
        sigma <- par[2]
        d1 <- dnorm((min-mu)/sigma)
        d2 <- dnorm((max-mu)/sigma)
        p1 <- pnorm((min-mu)/sigma)
        p2 <- pnorm((max-mu)/sigma)
        m <- mu + ((d1 - d2)/( p2 - p1))*sigma
        s <- sd^2*(1+(((min-mu)/sigma)*d1 - ((max-mu)/sigma)*d2)/(p2 - p1) - ((d1 - d2)/(p2 - p1))^2)
        out <- sum(c((m-mean)^2,(s-sd^2)^2))
        #out <- max(abs(m-mean),abs(sqrt(s)-sd))
        #return(out)
        if(is.na(out)) out <- 1e+300
        if(out == Inf) return(1e+300) else return(out)
    }
    out <- nlminb(start=c(mean,sd),objective=opfun,lower=c(-Inf,0),upper=c(Inf,Inf),mean=mean,sd=sd,min=min,max=max)
    return(list(mu=out$par[1],sigma=out$par[2]))
}


calcParTruncatedNormal <- function(mean,sd,min,max) {
    opfun <- function(par,mean,sd,min,max) {
        mu <- par[1]
        sigma <- par[2]
        m <- mu + ((dnorm((min-mu)/sigma) - dnorm((max-mu)/sigma))/(pnorm((max-mu)/sigma) - pnorm((min-mu)/sigma)))*sigma
        s <- sigma^2*(1+(((min-mu)/sigma)*dnorm((min-mu)/sigma) - ((max-mu)/sigma)*dnorm((max-mu)/sigma))/(pnorm((max-mu)/sigma) - pnorm((min-mu)/sigma)) - ((dnorm((min-mu)/sigma) - dnorm((max-mu)/sigma))/(pnorm((max-mu)/sigma) - pnorm((min-mu)/sigma)))^2)
        #out <- max(abs(m-mean),abs(s-sd^2))
        out <- sum(c((m-mean)^2,(s-sd^2)^2))
        return(out)
        #if(is.na(out)) out <- 1e+300
        #if(out == Inf) return(1e+300) else return(out)
    }
    out <- nlminb(start=c(mean,sd),objective=opfun,lower=c(-Inf,0),upper=c(Inf,Inf),mean=mean,sd=sd,min=min,max=max)
    return(list(mu=out$par[1],sigma=out$par[2]))
}


calcParTruncatedNormal <- function(mean,sd,min,max) {
    opfun <- function(par,mean,sd,min,max) {
        mu <- par[1]
        sigma <- exp(par[2])
        al <- (min-mu)/sigma
        be <- (max-mu)/sigma
        dal <- dnorm(al)
        dbe <- dnorm(be)
        pal <- pnorm(al)
        pbe <- pnorm(be)
        m <- mu + ((dal - dbe)/(pbe - pal))*sigma
        s <- sigma^2*(1+(al*dal - be*dbe)/(pbe - pal) - ((dal - dbe)/(pbe - pal))^2)
        #out <- max(abs(m-mean),abs(s-sd^2))
        out <- sum(c((m-mean)^2,(sqrt(s)-sd)^2))
        return(out)
        #if(is.na(out)) out <- 1e+300
        #if(out == Inf) return(1e+300) else return(out)
    }
    out <- optim(par=c(mean,log(sd)),fn=opfun,mean=mean,sd=sd,min=min,max=max)
    return(list(mu=out$par[1],sigma=exp(out$par[2])))
}

setClass("UniformDistribution",
  contains="Distribution",
  representation(
    min="numeric",
    max="numeric"
  )
)

# distribution list
# each element contains:
  # distribution object
  # distribution id
  
# each random variable should have a distribution id linking to the distribution list
