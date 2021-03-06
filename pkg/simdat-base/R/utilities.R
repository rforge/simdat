cor2cov <- function(cor,sd) {
  outer(sd, sd) * cor
}

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

# adapted from package sm
simdat.options <- function (...) {
    if (nargs() == 0) return(.simdat.Options)
    current <- .simdat.Options
    temp <- list(...)
    if (length(temp) == 1 && is.null(names(temp))) {
        arg <- temp[[1]]
        switch(mode(arg),
               list = temp <- arg,
               character = return(.simdat.Options[arg]),
               stop("invalid argument: ", sQuote(arg)))
    }
    if (length(temp) == 0) return(current)
    n <- names(temp)
    if (is.null(n)) stop("options must be given by name")
    changed <- current[n]
    current[n] <- temp
    if (sys.parent() == 0) env <- asNamespace("simdat.base") else env <- parent.frame()
    assign(".simdat.Options", current, envir = env)
    invisible(current)
}
