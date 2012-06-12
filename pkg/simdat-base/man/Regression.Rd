\name{Regression}
\Rdversion{1.1}
\alias{Regression}
\alias{Regression-class}

\title{Regression}

\description{
Constructs a linear Regression model.
}

\usage{
Regression(predictors=VariableList(list(RandomIntervalVariable(numeric(sum(N)),digits=8,min=-Inf,max=Inf,name="X"))),predictorModels=ModelList(list(NormalModel(mean=0,sd=1))),N=10,mu=0,sigma=1,nu=NULL,tau=NULL,beta=1,DV=list(name="Y",min=-Inf,max=Inf,digits=8),family=NO())
}

\arguments{
\item{predictors}{either a \code{data.frame} or \linkS4class{VariableList} containing the predictors in the design.}
\item{predictorModels}{(optional) a list with models to simulate random predictors.}
\item{N}{a vector with the number of observations in each cell of the design.}
\item{mu}{a vector with the values of mu in each cell of the design.}
\item{sigma}{a vector with the values of sigma in each cell of the design.}
\item{nu}{a vector with the values of nu in each cell of the design.}
\item{tau}{a vector with the values of tau in each cell of the design.}
\item{beta}{a vector or matrix with the slopes of the covariates in each cell of the design.}
\item{DV}{either a \code{list} or a \linkS4class{GamlssModel}}.
\item{family}{a \code{gamlss.family} object}
}
\details{The Regression function constructs a Regression model. The workhorse function is \code{GLM_create}, which should not be called directly.}

\value{An object of class \code{Regression} (directly extending the \linkS4class{SimDatModel} class).}

\author{Maarten Speekenbrink}
\examples{
mod <- Regression()
mod <- simulate(mod)

# and a random interval covariate
x <- VariableList(list(
  RandomIntervalVariable(numeric(1),name="X1",min=-5,max=5,digits=2),
  RandomIntervalVariable(numeric(1),name="X2",min=-9,max=11,digits=4)
  ))
# and a random interval dependent variable
d <- RandomIntervalVariable(numeric(1),name="Y",min=-Inf,max=Inf,digits=2)
mod2 <- Regression(predictors=x,
  predictorModels=ModelList(list(UniformModel(),NormalModel(mean=1,sd=2))),
  N=10000,mu=2,sigma=3,beta=matrix(c(1,2),ncol=2),
  DV=d,family=NO())
mod2 <- simulate(mod2)
summary(lm(Y~X1+X2,data=getData(simulate(mod2))))
}

