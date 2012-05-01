\name{rmANOVA}
\Rdversion{1.1}
\alias{rmANOVA}
\alias{rmANOVA-class}
\alias{getData,rmANOVA-method}


\title{Repeated measures ANOVA}
\description{
Constructs a repeated measures ANOVA model.
}
\usage{
rmANOVA(between=data.frame(A=factor(c(1,1,2,2),labels=c("A1","A2")),B=factor(c(1,2,1,3),labels=c("B1","B2","B3"))),within=data.frame(V=factor(c(1,1,2,2),labels=c("V1","V2")),W=factor(c(1,2,1,3),labels=c("W1","W2","W3"))),N=rep(10,4),mu=cbind(c(0,1,2,3),c(1,2,3,4),c(3,4,5,6),c(6,7,8,9)),bsigma=c(1,1,1,1),wsigma=c(1,1,1,1),nu=NULL,tau=NULL,DV=list(name="Y",min=-Inf,max=Inf,digits=8),family=NO(),id.name="ID",display.direction=c("wide","long"))
}
\arguments{
\item{between}{either a \code{data.frame} or \linkS4class{VariableList} containing the factors of the between subjects design.}
\item{within}{either a \code{data.frame} or \linkS4class{VariableList} containing the factors of the between subjects design.}
\item{N}{a vector with the number of observations in each cell of the design.}
\item{mu}{a matrix with the means in each cell of the design.}
\item{bsigma}{a vector with the standard deviations in each cell of the between design.}
\item{wsigma}{a vector with the standard deviations in each cell of the within design.}
\item{nu}{a vector with the standard deviations in each cell of the within design.}
\item{tau}{a vector with the standard deviations in each cell of the within design.}
\item{DV}{either a \code{list} or a \linkS4class{GamlssModel}}.
\item{family}{a \code{gamlss.family} object}
\item{id.name}{a string with the name of the variable used to differentiate subjects.}
\item{display.direction}{a string indicating whether the data will be in long or wide format (internally, the model always uses a long format.)}
}
\details{The rmANOVA function constructs a repeated measures ANOVA model.  }
\value{An object of class \code{rmANOVA} (directly extending the \linkS4class{SimDatModel} class).}

\author{Maarten Speekenbrink}
\examples{
mod <- rmANOVA()
mod <- simulate(mod)

# create two factors and put them into a variablelist
f1 <- NominalVariable(factor(c(1,1,2,2),labels=c("A1","A2")),name="A")
f2 <- NominalVariable(factor(c(1,2,2,3),labels=c("B1","B2","B3")),name="B")
bdesign <- VariableList(list(f1,f2))
# create two factors and put them into a variablelist
f1 <- NominalVariable(factor(c(1,1,2,2),labels=c("W1","W2")),name="W")
f2 <- NominalVariable(factor(c(1,2,1,2),labels=c("V1","V2")),name="V")
wdesign <- VariableList(list(f1,f2))
# and a random interval variable
d <- RandomIntervalVariable(numeric(1),name="Y",min=-10,max=Inf,digits=2)
# means
mu <- cbind(c(10,15,15,20),c(20,25,25,30),c(10,15,15,20),c(30,25,20,25))

mod2 <- rmANOVA(between=bdesign,within=wdesign,mu=mu,bsigma=c(2,3,4,5),wsigma=c(1,2,3,4),DV=d,family=NOF(),nu=c(1,1,1,1))
mod2 <- simulate(mod2)


}

