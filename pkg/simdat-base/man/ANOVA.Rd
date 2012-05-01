\name{ANOVA}
\Rdversion{1.1}
\alias{ANOVA}
\alias{ANOVA-class}

\title{ANOVA}

\description{
Constructs an ANOVA model.
}

\usage{
ANOVA(design=data.frame(A=factor(c(1,1,2,2),labels=c("A1","A2")),B=factor(c(1,2,1,3),labels=c("B1","B2","B3"))),N=c(15,15,15,15),mu=c(0,1,2,3),sigma=c(2,2,2,2),nu=NULL,tau=NULL,DV=list(name="Y",min=-Inf,max=Inf,digits=8),family=NO())
}

\arguments{
\item{design}{either a \code{data.frame} or \linkS4class{VariableList} containing the factors of the design.}
\item{N}{a vector with the number of observations in each cell of the design.}
\item{mu}{a vector with the means in each cell of the design.}
\item{sigma}{a vector with the standard deviations in each cell of the design.}
\item{nu}{a vector with the standard deviations in each cell of the design.}
\item{tau}{a vector with the standard deviations in each cell of the design.}
\item{DV}{either a \code{list} or a \linkS4class{GamlssModel}}.
\item{family}{a \code{gamlss.family} object}
}
\details{The ANOVA function constructs an ANOVA model.  }
\value{An object of class \code{ANOVA} (directly extending the \linkS4class{SimDatModel} class).}

\author{Maarten Speekenbrink}
\examples{
mod <- ANOVA()
mod <- simulate(mod)

# create two factors and put them into a variablelist
f1 <- NominalVariable(factor(c(1,1,2,2),labels=c("A1","A2")),name="A")
f2 <- NominalVariable(factor(c(1,2,2,3),labels=c("B1","B2","B3")),name="A")
design <- VariableList(list(f1,f2))
# and a random interval variable
d <- RandomIntervalVariable(numeric(1),name="Y",min=-10,max=Inf,digits=2)
mod2 <- ANOVA(design=design,DV=d,family=NOF(),nu=c(1,1,1,1))
mod2 <- simulate(mod2)
}

