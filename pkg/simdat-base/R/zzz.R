".simdat.Options" <-
    list(digits=8,mu.default=0,sigma.default=1,nu.default=0,tau.default=0,
    N.default=10)
         
.onAttach <- function(library, pkg) {
    ## we can't do this in .onLoad
    unlockBinding(".simdat.Options", asNamespace("simdat.base"))
    #packageStartupMessage("Package `sm', version 2.2-4.1\n",
    #    "Copyright (C) 1997, 2000, 2005, 2007, 2008, A.W.Bowman & A.Azzalini\n",
    #    "Type help(sm) for summary information\n")
    invisible()
}
