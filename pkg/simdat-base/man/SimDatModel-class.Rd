\name{SimDatModel-class}
\Rdversion{1.1}
\docType{class}
\alias{SimDatModel-class}

\alias{getData}
\alias{models}
\alias{models<-}
\alias{variableNames}
\alias{variableNames<-}
\alias{variables}
\alias{variables<-}

\alias{addModel,SimDatModel-method}


\alias{addVariable,SimDatModel,Variable-method}
\alias{deleteModel,SimDatModel-method}
\alias{deleteVariable,SimDatModel-method}
\alias{getData,SimDatModel-method}
\alias{insertRow,SimDatModel-method}
\alias{models<-,SimDatModel-method}
\alias{models,SimDatModel,ANY-method}
\alias{models,SimDatModel,character-method}
\alias{removeRow,SimDatModel-method}
\alias{replaceModel,SimDatModel-method}
\alias{replaceVariable,SimDatModel-method}
\alias{setValueAt,SimDatModel-method}
\alias{simulate,SimDatModel-method}
\alias{variableNames<-,SimDatModel-method}
\alias{variableNames,SimDatModel-method}
\alias{variables<-,SimDatModel-method}
\alias{variables,SimDatModel,ANY-method}
\alias{variables,SimDatModel,character-method}

\title{Class \code{"SimDatModel"}}
\description{
The general model in SimDat used to simulate data.
}
\section{Objects from the Class}{
Objects can be created by calls of the form \code{new("SimDatModel", ...)}.
%%  ~~ describe objects here ~~ 
}
\section{Slots}{
  \describe{
    \item{\code{name}:}{Object of class \code{"character"} ~~ }
    \item{\code{variables}:}{Object of class \code{"VariableList"} ~~ }
    \item{\code{models}:}{Object of class \code{"ModelList"} ~~ }
    \item{\code{modelID}:}{Object of class \code{"numeric"} ~~ }
    \item{\code{structure}:}{Object of class \code{"matrix"} ~~ }
  }
}
\section{Methods}{
  \describe{
    \item{addModel}{\code{signature(object = "SimDatModel")}: ... }
    \item{addVariable}{\code{signature(object = "SimDatModel", variable = "Variable")}: ... }
    \item{deleteModel}{\code{signature(object = "SimDatModel")}: ... }
    \item{deleteVariable}{\code{signature(object = "SimDatModel")}: ... }
    \item{getData}{\code{signature(object = "SimDatModel")}: ... }
    \item{insertRow}{\code{signature(object = "SimDatModel")}: ... }
    \item{models<-}{\code{signature(object = "SimDatModel")}: ... }
    \item{models}{\code{signature(object = "SimDatModel", names = "ANY")}: ... }
    \item{models}{\code{signature(object = "SimDatModel", names = "character")}: ... }
    \item{removeRow}{\code{signature(object = "SimDatModel")}: ... }
    \item{replaceModel}{\code{signature(object = "SimDatModel")}: ... }
    \item{replaceVariable}{\code{signature(object = "SimDatModel")}: ... }
    \item{setValueAt}{\code{signature(object = "SimDatModel")}: ... }
    \item{simulate}{\code{signature(object = "SimDatModel")}: ... }
    \item{variableNames<-}{\code{signature(object = "SimDatModel")}: ... }
    \item{variableNames}{\code{signature(object = "SimDatModel")}: ... }
    \item{variables<-}{\code{signature(object = "SimDatModel")}: ... }
    \item{variables}{\code{signature(object = "SimDatModel", names = "ANY")}: ... }
    \item{variables}{\code{signature(object = "SimDatModel", names = "character")}: ... }
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
showClass("SimDatModel")
}
\keyword{classes}
