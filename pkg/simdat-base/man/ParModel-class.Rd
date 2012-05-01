\name{ParModel-class}
\Rdversion{1.1}
\docType{class}
\alias{ParModel-class}
\alias{RandomParModel-class}
\alias{MixedParModel-class}
\alias{MultilevelParModel-class}

\alias{predict,ParModel-method}

\alias{isRandom,ParModel-method}
\alias{isRandom,MultilevelParModel-method}
\alias{isRandom,MixedParModel-method}
\alias{isRandom,MultilevelParModel-method}
\alias{isRandom,RandomParModel-method}
\alias{isRandom,RandomParModelList-method}

\alias{simulate,MixedParModel-method}
\alias{simulate,RandomParModel-method}

\title{Parameter models}

\description{
Objects of class \code{"ParModel"} are parameter models, as used in \linkS4class{GamlssModel}.
}
\section{Objects from the class }{
Objects can be created by calls of the form \code{new("ParModel", ...)}.
%%  ~~ describe objects here ~~ 
}
\section{Slots}{
  \describe{
    \item{\code{formula}:}{Object of class \code{"formula"} ~~ }
    \item{\code{coefficients}:}{Object of class \code{"vector"} ~~ }
  }
}
\section{Methods}{
  \describe{
    \item{isRandom}{\code{signature(object = "ParModel")}: ... }
    \item{predict}{\code{signature(object = "ParModel")}: ... }
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
showClass("ParModel")
}
\keyword{classes}
