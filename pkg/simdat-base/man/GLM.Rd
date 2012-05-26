\name{GLM}
\Rdversion{1.1}
\alias{GLM}
\alias{GLM-class}

\title{GLM}

\description{
Constructs a GLM model.
}

\usage{
GLM(factors=data.frame(A=factor(c(1,1,2,2),labels=c("A1","A2")),B=factor(c(1,2,1,3),labels=c("B1","B2","B3"))),covariates=VariableList(list(RandomIntervalVariable(numeric(sum(N)),digits=8,min=-Inf,max=Inf,name="X"))),covariateModels=ModelList(list(NormalModel(mean=0,sd=1))),N=c(15,15,15,15),mu=c(0,1,2,3),sigma=c(2,2,2,2),nu=NULL,tau=NULL,beta=c(1,1,1,1),DV=list(name="Y",min=-Inf,max=Inf,digits=8),family=NO())
}

\arguments{
\item{factors}{either a \code{data.frame} or \linkS4class{VariableList} containing the factors of the design.}
\item{covariates}{either a \code{data.frame} or \linkS4class{VariableList} containing the covariates in the design.}
\item{covariateModels}{(optional) a list with models to simulate random covariates.}
\item{N}{a vector with the number of observations in each cell of the design.}
\item{mu}{a vector with the values of mu in each cell of the design.}
\item{sigma}{a vector with the values of sigma in each cell of the design.}
\item{nu}{a vector with the values of nu in each cell of the design.}
\item{tau}{a vector with the values of tau in each cell of the design.}
\item{beta}{a vector or matrix with the slopes of the covariates in each cell of the design.}
\item{DV}{either a \code{list} or a \linkS4class{GamlssModel}}.
\item{family}{a \code{gamlss.family} object}
}
\details{The GLM function constructs a GLM model. The workhorse function is \code{GLM_create}, which should not be called directly.}

\value{An object of class \code{GLM} (directly extending the \linkS4class{SimDatModel} class).}

\author{Maarten Speekenbrink}
\examples{
mod <- GLM()
mod <- simulate(mod)

# create two factors and put them into a variablelist
f1 <- NominalVariable(factor(c(1,1,2,2),labels=c("A1","A2")),name="A")
f2 <- NominalVariable(factor(c(1,2,2,3),labels=c("B1","B2","B3")),name="B")
design <- VariableList(list(f1,f2))
# and a random interval covariate
x <- VariableList(list(RandomIntervalVariable(numeric(1),name="X",min=-5,max=5,digits=2)))
# and a random interval dependent variable
d <- RandomIntervalVariable(numeric(1),name="Y",min=-10,max=Inf,digits=2)
mod2 <- GLM(factors=design,covariates=x,
  covariateModels=ModelList(list(UniformModel())),
  N=c(20,20,20,20),mu=c(2,5,2,10),sigma=c(2,2,2,2),beta=c(1,2,1,2),
  DV=d,family=NO())
mod2 <- simulate(mod2)
}

