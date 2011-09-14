setClass("SimDatModel",
    representation(
        variables="VariableList",
        models="ModelList",
        modelID="numeric", # vector with model indicators (0 is for fixed variables)
        structure="matrix"
    )
)

setValidity("SimDatModel",
  method=function(object) {
    nvar <- length(object@variables)
    if(ncol(object@structure)!=nvar | nrow(object@structure) != nvar) return(FALSE)
    if(length(object@models)!=length(unique(object@modelID))) return(FALSE)
    if(!all(structure %in% c(0,1))) return(FALSE)
    if(!isDAG(structure)) return(FALSE)
    # add more checks here
    # needs check that multivariate models have no interdependencies in graph!
  }
)

setMethod("simulate",signature(object="SimDatModel"),
    function(object,nsim=1,seed,...) {
        # order the models for simulation
        vorder <- topOrderGraph(object@structure)
        #nrep <- table(object@modelID)
        #multivar <- as.numeric(names(nrep[nrep>1]))
        
        #morder <- unique(object@modelID[vorder])
        
        #random <- (1:length(variables))[unlist(lapply(object@variables,isRandom))]
        #nrep <- table(object@modelID)
        #multivar <- as.numeric(names(nrep[nrep>1]))
        
        
        if(nsim > 1) {
            # use recursive programming
            out <- list()
            for(i in 1:nsim) {
                mod <- simulate(object,nsim=1,seed=seed,...)
                out[[i]] <- as.data.frame(mod@variables)
            }
            return(out)
        } else {
            for(mod in morder) {
                 vars <- which(object@modelID == mod)
                 if(length(vars) > 1) DV <- object@variables[vars] else DV <- object@variables[[vars]]
                 IV <- which(rowSums(object@structure[,vars]) > 0)
                 if(length(IV) > 0) {
                    dat <- as.data.frame(object@variables)[,IV]
                    out <- simulate(models[[mod]],nsim=nsim,seed=seed,DV=DV,data=dat,...)
                 } else {
                    out <- simulate(models[[mod]],nsim=nsim,seed=seed,DV=DV,...)
                 }
                 
                 # now set the data in dat to the correct variables
                 if(is(out,"VariableList") | is(out,"Variable")) {
                    for(i in vars) object@variables[[i]] <- out[[i]]
                 } else {
                 # probably didn't get the correct format back; but let's try...
                     warning("simulate method in model ",mod," did not return an object of class Variable")
                     if(is.matrix(out) | is.data.frame(out)) {
                        if(ncol(out) > 1) {
                            # multivariate data
                            vnames <- colnames(out)
                            for(i in vnames) {
                                object@variables[[i]]@.Data <- out[,i]
                            }
                        }
                     } else {
                        object@variables[[vars]]@.Data <- out
                     }
                }
            }
        }
        object
    }
)


topOrderGraph <- function(graph) {
# L ← Empty list where we put the sorted elements
# Q ← Set of all nodes with no incoming edges
# while Q is non-empty do
#     remove a node n from Q
#     insert n into L
#     for each node m with an edge e from n to m do
#         remove edge e from the graph
#         if m has no other incoming edges then
#             insert m into Q
# if graph has edges then
#     output error message (graph has a cycle)
# else 
#     output message (proposed topologically sorted order: L) 
    l <- vector()
    q <- which(colSums(graph) == 0)
    while(length(q) > 0) {
        b <- q[1]
        l <- c(l,b)
        q <- q[-1]
        for(node in which(graph[b,] == 1)) {
            graph[b,node] <- 0
            if(sum(graph[,node]) == 0) q <- c(q,node)
        }
    }
    if(!all(colSums(graph) == 0)) return(NULL) else return(l)
}

isDAG <- function(graph) {
    !is.null(topOrderGraph(graph))
}
