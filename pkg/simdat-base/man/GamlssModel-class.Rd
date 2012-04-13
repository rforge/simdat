\name{GamlssModel-class}
\Rdversion{1.1}
\docType{class}
\alias{GamlssModel-class}
\alias{simulateFromModel,Variable,GamlssModel-method}

\title{Class \code{"GamlssModel"}}
\description{
%%  ~~ A concise (1-5 lines) description of what the class is. ~~
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
\references{
%%  ~~put references to the literature/web site here~~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%%  ~~objects to See Also as \code{\link{~~fun~~}}, ~~~
%%  ~~or \code{\linkS4class{CLASSNAME}} for links to other classes ~~~
}
\examples{
showClass("GamlssModel")
}
\keyword{classes}
