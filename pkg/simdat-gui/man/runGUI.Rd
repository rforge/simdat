\name{runGUI}
\Rdversion{1.1}
\alias{runGUI}

\title{Run a simdat GUI}

\description{
Runs a GUI application to simulate data. This function normally does not return; interrupt R to stop the application (usually by pressing Ctrl+C or Esc).
}

\usage{
runGUI(gui,port=8100L,launch.browser=TRUE)
}

\arguments{
\item{gui}{The name of the GUI (see details)}.
\item{port}{The TCP port that the application should listen on. Defaults to port 8100.}
\item{launch.browser}{If true (default), the system's default web browser will be launched automatically after the GUI is started.}
}

\details{Currently, two GUIs are available. The "ANOVA" gui is used for (factorial) designs with a normally distributed dependent variable. The "RMANOVA" gui is used for (factorial) designs with repeated-measures (possibly a combination of between and withi-subjects factors).}


\author{Maarten Speekenbrink}
\examples{
\dontrun{
runGUI("ANOVA")
runGUI("RMANOVA")
}
}
