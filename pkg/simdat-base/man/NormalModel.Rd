\name{NormalModel}
\Rdversion{1.1}
\alias{NormalModel}
\alias{NormalModel-class}

\title{Normal model}

\description{
Constructs a Normal distribution model.
}

\usage{
NormalModel(mean=0,sd=1)
}

\arguments{
\item{mean}{mean of the distribution}
\item{sd}{standard deviation of the distribution}
}

\details{The NormalModel function constructs a NormalModel.}

\value{An object of class \code{NormalModel} (directly extending the \linkS4class{Model} class).}

\author{Maarten Speekenbrink}
\examples{
mod <- NormalModel(mean=1,sd=10)
}

