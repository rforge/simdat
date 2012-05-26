\name{Variable-class}
\Rdversion{1.1}
\docType{class}
\alias{asFixed}
\alias{asRandom}
\alias{digits}
\alias{digits<-}
\alias{isMetric}
\alias{isRandom}
\alias{max<-}
\alias{min<-}
\alias{simulateFromModel}

  
\alias{Variable-class}
\alias{RandomVariable-class}
\alias{NominalVariable-class}
\alias{NominalVariable}
\alias{RandomNominalVariable-class}
\alias{RandomNominalVariable}
\alias{OrdinalVariable-class}
\alias{OrdinalVariable}
\alias{RandomOrdinalVariable-class}
\alias{RandomOrdinalVariable}
\alias{IntervalVariable-class}
\alias{IntervalVariable}
\alias{RandomIntervalVariable-class}
\alias{RandomIntervalVariable}
\alias{RatioVariable-class}
\alias{RatioVariable}
\alias{RandomRatioVariable-class}
\alias{RandomRatioVariable}


%\alias{addVariable,SimDatModel,Variable-method}
\alias{asFixed,Variable-method}
\alias{asRandom,Variable-method}
\alias{coerce,Variable,IntervalVariable-method}
\alias{coerce,Variable,NominalVariable-method}
\alias{coerce,Variable,OrdinalVariable-method}
\alias{coerce,Variable,RandomIntervalVariable-method}
\alias{coerce,Variable,RandomNominalVariable-method}
\alias{coerce,Variable,RandomOrdinalVariable-method}
\alias{coerce,Variable,RandomRatioVariable-method}
\alias{coerce,Variable,RatioVariable-method}
\alias{digits,Variable-method}
\alias{isMetric,Variable-method}
\alias{isRandom,Variable-method}
\alias{labels,Variable-method}
\alias{names<-,Variable-method}
\alias{names,Variable-method}
\alias{simulateFromModel,RandomVariable,GamlssModel-method}
\alias{simulateFromModel,RandomVariable,MixedParModel-method}
\alias{simulateFromModel,RandomVariable,MvnormModel-method}
\alias{simulateFromModel,RandomVariable,NormalModel-method}
\alias{simulateFromModel,RandomVariable,UniformModel-method}

\alias{simulate,RandomVariable-method}
\alias{Summary,Variable-method}

\alias{VariableList-class}
\alias{VariableList}
\alias{getData,VariableList-method}
\alias{isMetric,VariableList-method}
\alias{isRandom,VariableList-method}

\alias{names,VariableList-method}
\alias{names<-,VariableList-method}

\alias{digits<-,IntervalVariable-method}
\alias{levels<-,NominalVariable-method}
\alias{max<-,RandomIntervalVariable-method}
\alias{min<-,RandomIntervalVariable-method}
  
\alias{variableNames,VariableList-method}
\alias{variables,VariableList,ANY-method}
\alias{variables,VariableList,character-method}
\alias{variables<-,VariableList-method}

\title{Class \code{"Variable"}}
\description{
The Variable class is the base class for fixed and random variables in SimDat. There are four basic types of variables: nominal, ordinal, interval, and ratio variables. These can be fixed or random.
}
\section{Objects from the Class}{"Variable" itself is a virtual Class: No objects may be created from it. But there are constructor methods for the derived classes:

NominalVariable(data=factor(),name)

RandomNominalVariable(data=factor(),name)

OrdinalVariable(data=ordered(),name)

RandomOrdinalVariable(data=ordered(),name)

IntervalVariable(data=numeric(),name,digits=getOption('digits'))

RandomIntervalVariable(data=numeric(),name,digits=getOption('digits'),min=-Inf,max=Inf)

RatioVariable(data=numeric(),name,digits=getOption('digits'))

RandomRatioVariable(data=numeric(),name,digits=getOption('digits'),min=-Inf,max=Inf)
}
\section{Methods}{
  \describe{
    \item{asFixed}{\code{signature(object = "Variable")}: ... }
    \item{asRandom}{\code{signature(object = "Variable")}: ... }
    \item{coerce}{\code{signature(from = "Variable", to = "IntervalVariable")}: ... }
    \item{coerce}{\code{signature(from = "Variable", to = "NominalVariable")}: ... }
    \item{coerce}{\code{signature(from = "Variable", to = "OrdinalVariable")}: ... }
    \item{coerce}{\code{signature(from = "Variable", to = "RandomIntervalVariable")}: ... }
    \item{coerce}{\code{signature(from = "Variable", to = "RandomNominalVariable")}: ... }
    \item{coerce}{\code{signature(from = "Variable", to = "RandomOrdinalVariable")}: ... }
    \item{coerce}{\code{signature(from = "Variable", to = "RandomRatioVariable")}: ... }
    \item{coerce}{\code{signature(from = "Variable", to = "RatioVariable")}: ... }
    \item{digits}{\code{signature(object = "Variable")}: ... }
    \item{isMetric}{\code{signature(object = "Variable")}: ... }
    \item{isRandom}{\code{signature(object = "Variable")}: ... }
    \item{labels}{\code{signature(object = "Variable")}: ... }
    \item{names<-}{\code{signature(x = "Variable")}: ... }
    \item{names}{\code{signature(x = "Variable")}: ... }
    \item{simulateFromModel}{\code{signature(object = "Variable", model = "GamlssModel")}: ... }
    \item{simulateFromModel}{\code{signature(object = "Variable", model = "MixedParModel")}: ... }
    \item{simulateFromModel}{\code{signature(object = "Variable", model = "MvnormModel")}: ... }
    \item{simulateFromModel}{\code{signature(object = "Variable", model = "UniformModel")}: ... }
    \item{simulate}{\code{signature(object = "Variable")}: ... }
    \item{Summary}{\code{signature(x = "Variable")}: ... }
	 }
}
%\references{
%%  ~~put references to the literature/web site here~~
%}
\author{
Maarten Speekenbrink
}
%\note{
%%  ~~further notes~~
%}

%% ~Make other sections like Warning with \section{Warning }{....} ~

%\seealso{
%%  ~~objects to See Also as \code{\link{~~fun~~}}, ~~~
%%  ~~or \code{\linkS4class{CLASSNAME}} for links to other classes ~~~
%}
\examples{
showClass("Variable")
## create a Nominal variable
A <- NominalVariable(factor(1:2,labels="A1","A2"),name="A")
# derives some methods from 'factor':
levels(A)
levels(A) <- c("A1","A3")
## convert to a RandomInterval variable
rA <- as(A,"RandomNominalVariable")
## check that it is actually a random variable:
isRandom(rA)
## is it a metric (>= interval level) variable? 
isMetric(rA)
# construct a (truncated) interval variable
B <- RandomIntervalVariable(rnorm(10),name="B",digits=2,min=0,max=10)
}
\keyword{classes}
