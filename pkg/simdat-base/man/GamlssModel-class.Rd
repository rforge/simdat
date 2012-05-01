\name{GamlssModel-class}
\Rdversion{1.1}
\docType{class}
\alias{GamlssModel-class}
\alias{GammlssModel-class}
\alias{simulate,GamlssModel-method}
\alias{simulate,GammlssModel-method}
\alias{simulateFromModel,Variable,GamlssModel-method}

\title{Class \code{"GamlssModel"} and \code{"GammlssModel"} }
\description{
The GamlssModel class is used to simulate with gamlss family distributions.
The GamlssModel has a slot for the four gamlss parameters 
(mu, sigma, nu, and tau), each represented by a parameter model.
}
\section{Objects from the Class}{
Objects can be created by calls of the form \code{new("GamlssModel", ...)}.
%%  ~~ describe objects here ~~ 
}
\section{Slots}{
  \describe{
    \item{\code{mu}:}{Object of class \code{"ParModel"} ~~ }
    \item{\code{sigma}:}{Object of class \code{"ParModel"} ~~ }
    \item{\code{nu}:}{Object of class \code{"ParModel"} ~~ }
    \item{\code{tau}:}{Object of class \code{"ParModel"} ~~ }
    \item{\code{family}:}{Object of class \code{"gamlss.family"} ~~ }
  }
}
\section{Extends}{
Class \code{"\linkS4class{Model}"}, directly.
}
\section{Methods}{
  \describe{
    \item{simulateFromModel}{\code{signature(object = "Variable", model = "GamlssModel")}: ... }
	 }
}

%\references{
%%  ~~put references to the literature/web site here~~
%}

\author{
Maarten Speekenbrink
}

%%\note{
%%  ~~further notes~~
%%}

%% ~Make other sections like Warning with \section{Warning }{....} ~

%%\seealso{
%%  ~~objects to See Also as \code{\link{~~fun~~}}, ~~~
%%  ~~or \code{\linkS4class{CLASSNAME}} for links to other classes ~~~
%%}
\examples{
showClass("GamlssModel")
}
\keyword{classes}
