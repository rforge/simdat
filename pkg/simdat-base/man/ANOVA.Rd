\name{ANOVA}
\Rdversion{1.1}
\alias{ANOVA}
\alias{ANOVA-class}
\alias{summary,ANOVA-method}

\title{ANOVA}

\description{
Constructs an ANOVA model.
}

\usage{
ANOVA(DV,family=NO(),design,N,mu,sigma,nu,tau)
}

\arguments{
\item{DV}{either a \code{list} or a \linkS4class{RandomVariable} (see details)}.
\item{design}{either a \code{data.frame} or \linkS4class{VariableList} containing the factors of the design (see details).}

\item{N}{a vector with the number of observations in each cell of the design.}
\item{mu}{a vector with the means in each cell of the design.}
\item{sigma}{a vector with the standard deviations in each cell of the design.}
\item{nu}{a vector with the standard deviations in each cell of the design.}
\item{tau}{a vector with the standard deviations in each cell of the design.}
\item{family}{a \code{gamlss.family} object}
}
\details{The ANOVA function constructs an ANalysis Of VAriance (ANOVA) model. The workhorse function is \code{GLM_create}, which should not be called directly.}

\value{An object of class \code{ANOVA} (directly extending the \linkS4class{GLM} class).}

\author{Maarten Speekenbrink}
\examples{
mod <- ANOVA(design=data.frame(A=factor(c(1,1,2,2),labels=c("A1","A2")),B=factor(c(1,2,1,2),labels=c("B1","B2"))),DV=list(name="Y",min=-Inf,max=Inf,digits=8),N=c(20,20,20,20),mu=c(10,20,20,30),sigma=c(5,5,5,5),family=NO())
mod <- simulate(mod)

# create two factors and put them into a variablelist
f1 <- NominalVariable(factor(c(1,1,2,2),labels=c("A1","A2")),name="A")
f2 <- NominalVariable(factor(c(1,2,1,3),labels=c("B1","B2","B3")),name="A")
design <- VariableList(list(f1,f2))
# and a random interval variable
d <- RandomIntervalVariable(numeric(1),name="Y",min=-10,max=Inf,digits=2)
mod2 <- ANOVA(design=design,DV=d,family=NOF(),N=rep(10,4),mu=c(10,20,10,30),sigma=c(5,5,5,5),nu=c(1,1,1,1))
mod2 <- simulate(mod2)
}

