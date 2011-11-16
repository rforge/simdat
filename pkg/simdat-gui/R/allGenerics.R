## these methods are used for "in place" changing
setGeneric("addModel",function(object,model,idx=NULL,env=parent.env(),...) standardGeneric("addModel"))
setGeneric("deleteModel",function(object,idx,env=parent.env(),...) standardGeneric("deleteModel"))
setGeneric("replaceModel",function(object,model,idx,env=parent.env(),...) standardGeneric("replaceModel"))
setGeneric("addVariable",function(object,variable,idx=NULL,env=parent.env(),...) standardGeneric("addVariable"))
setGeneric("deleteVariable",function(object,idx,env=parent.env(),...) standardGeneric("deleteVariable"))
setGeneric("replaceVariable",function(object,variable,idx,env=parent.env(),...) standardGeneric("replaceVariable"))
setGeneric("setValueAt",function(object,value,data_row,data_column,env=parent.env(),...) standardGeneric("setValueAt"))


