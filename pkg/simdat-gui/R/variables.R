cell.edited <- function(cell, path.string, new.text, data)
{
  checkPtrType(data, "GtkListStore")
  model <- data
  
  path <- gtkTreePathNewFromString(path.string)
  
  column <- cell$getData("column")

  iter <- model$getIter(path)$iter

  switch(column+1, {
	i <- path$getIndices()[[1]]+1
	articles[[i]]$number <<- as.integer(new.text)

	model$set(iter, column, articles[[i]]$number)
  }, {
	old.text <- model$get(iter, column)
	i <- path$getIndices()[[1]]+1
	articles[[i]]$product <<- new.text

	model$set(iter, column, articles[[i]]$product)
  })
}


cell.changed <- function(combo, path.string, new.iter, data)
{
  checkPtrType(data, "GtkListStore")
  model <- data
  
  path <- gtkTreePathNewFromString(path.string)
  cat(str(path$getIndices()),"\n")
  value <- combo$getData("active")
  #cat(value)

  iter <- model$getIter(path)$iter

  switch(column+1, {
	i <- path$getIndices()[[1]]+1
	#articles[[i]]$number <<- as.integer(new.text)

	model$set(iter, column, articles[[i]]$number)
  }, {
	old.text <- model$get(iter, column)
	i <- path$getIndices()[[1]]+1
	#articles[[i]]$product <<- new.text

	model$set(iter, column, articles[[i]]$product)
  })
}

cell_edited_callback <- function(renderer, path, new.text, user.data) {
  checkPtrType(data, "GtkListStore")
  model <- data
  
  path <- gtkTreePathNewFromString(path.string)
  
  column <- cell$getData("column")

  iter <- model$getIter(path)$iter

  switch(column+1, {
	i <- path$getIndices()[[1]]+1
	articles[[i]]$number <<- as.integer(new.text)

	model$set(iter, column, articles[[i]]$number)
  }, {
	old.text <- model$get(iter, column)
	i <- path$getIndices()[[1]]+1
	articles[[i]]$product <<- new.text

	model$set(iter, column, articles[[i]]$product)
  })
}

window <- gtkWindow()
swindow <- gtkScrolledWindow()

variables_dataframe <- data.frame(
  name=character(),
  scale=factor(,levels=c("nominal","ordinal","interval","ratio")),
  mode=factor(,levels=c("fixed","random")),
  nlevels=integer(),
  levels=character(),
  min=numeric(),
  max=numeric(),
  digits=numeric()
)

variables_dataframe <- data.frame(
  name=c("Y","X"),
  scale=factor(c("Nominal","Interval"),levels=c("Nominal","Ordinal","Interval","Ratio")),
  mode=factor(c("Fixed","Random"),levels=c("Fixed","Random")),
  nlevels=c(2,Inf),
  levels=list(c("Y1","Y2"),NA),
  min=c(NA,-Inf),
  max=c(NA,Inf),
  digits=c(NA,8),#,
  editable=rep(TRUE,2),
  not_editable = rep(FALSE,2)
  #editable=
)
  
variables_treeview_model <- gtkListStoreNew("gint", "gchararray", "gchararray", "gchararray", "gint", "gchararray", "gdouble", "gdouble", "gint", "gboolean","gboolean")
variables_treeview_model_editable <- gtkListStoreNew("gboolean")
model_COLUMN <- c(id = 0, name = 1, scale = 2, mode = 3, nlevels = 4, levels = 5, min = 6, max = 7, digits = 8, editable = 9, not_editable = 10)

#variables_editable <- c(FALSE,rep(TRUE,8))
#for(i in 1:length(variables_editable)) {
#  iter <- variables_treeview_model_editable$append()$iter
#  variables_treeview_model_editable$set(iter,
#    0, variables_editable[i])
#}

for (i in 1:nrow(variables_dataframe)) {
  iter <- variables_treeview_model$append()$iter
  variables_treeview_model$set(iter,
	  model_COLUMN["id"], i,
		model_COLUMN["name"], variables_dataframe[i,"name"],
		model_COLUMN["scale"], variables_dataframe[i,"scale"],
		model_COLUMN["mode"], variables_dataframe[i,"mode"],
		model_COLUMN["nlevels"], variables_dataframe[i,"nlevels"],
		model_COLUMN["levels"], variables_dataframe[i,"levels"],
		model_COLUMN["min"], variables_dataframe[i,"min"],
		model_COLUMN["max"], variables_dataframe[i,"max"],
		model_COLUMN["digits"], variables_dataframe[i,"digits"],
		model_COLUMN["editable"], variables_dataframe[i,"editable"],
		model_COLUMN["not_editable"], variables_dataframe[i,"not_editable"])
		#model_COLUMN["editable"], variables_dataframe[i,"editable"])
}

variables_treeview <- gtkTreeViewNewWithModel(variables_treeview_model)

variables_treeview$setRulesHint(TRUE)
variables_treeview$getSelection()$setMode("single")

#add.columns(treeview)

#variables_treeview_data <- rGtkDataFrame(variables_dataframe)
#variables_treeview <- gtkTreeView(variables_treeview_data)

# add id column
renderer <- gtkCellRendererTextNew()
renderer$setData("column", model_COLUMN["id"])
variables_treeview$insertColumnWithAttributes(-1, "Id", renderer, text = model_COLUMN[["id"]],
  editable = model_COLUMN[["not_editable"]])


# add name column
renderer <- gtkCellRendererTextNew()
renderer$setData("column",model_COLUMN["name"])
gSignalConnect(renderer, "edited", cell.edited, variables_treeview$getModel())
variables_treeview$insertColumnWithAttributes(-1, "Name", renderer, text = model_COLUMN[["name"]],
  editable = model_COLUMN[["editable"]])

# add scale column
#model <- gtkListStoreNew("gchararray", "gchararray", "gchararray", "gchararray")
#model$set(model$append()$iter,0,"Nominal",1,"Ordinal",2,"Interval",3,"Ratio")
model <- gtkListStoreNew("gchararray")
levels <- c("Nominal","Ordinal","Interval","Ratio")
for(i in 1:4) {
  iter <- model$append()$iter
  model$set(iter,0,levels[i])
}
renderer <- gtkCellRendererComboNew()
renderer$set("model" = model)
renderer$set("text-column" = 0)
gSignalConnect(renderer, "edited", cell.edited, variables_treeview$getModel())
gSignalConnect(renderer, "changed", cell.changed, variables_treeview$getModel())
variables_treeview$insertColumnWithAttributes(-1, "Scale", renderer, text = model_COLUMN[["scale"]],
  editable = model_COLUMN[["editable"]])

# add mode column
model <- gtkListStoreNew("gchararray")
levels <- c("Fixed","Random")
for(i in 1:2) {
  iter <- model$append()$iter
  model$set(iter,0,levels[i])
}
renderer <- gtkCellRendererComboNew()
renderer$set("model" = model)
renderer$set("text-column" = 0)
renderer$set("has-entry" = FALSE)
gSignalConnect(renderer, "edited", cell.edited, variables_treeview$getModel())
gSignalConnect(renderer, "changed", cell.changed, variables_treeview$getModel())
#variables_treeview$insertColumnWithAttributes(-1, "Scale", renderer, text = model_COLUMN[["scale"]],
#  editable = model_COLUMN[["editable"]])
#renderer <- gtkCellRendererComboNew()
#renderer$set("model",variables_treeview_data[,3])
#renderer$setData("column",model_COLUMN["mode"])
#gSignalConnect(renderer, "edited", cell.edited, variables_treeview_model)
variables_treeview$insertColumnWithAttributes(-1, "Mode", renderer, text = model_COLUMN[["mode"]],
  editable = model_COLUMN[["editable"]])
                                        
# add nlevels column
renderer <- gtkCellRendererText()
renderer$setData("column",model_COLUMN["nlevels"])
gSignalConnect(renderer, "edited", cell.edited, variables_treeview_model)
variables_treeview$insertColumnWithAttributes(-1, "Levels", renderer, text = model_COLUMN[["nlevels"]],
  editable = model_COLUMN[["editable"]])
                                        
# add labels column
renderer <- gtkCellRendererText()
renderer$setData("column",model_COLUMN["levels"])
gSignalConnect(renderer, "edited", cell.edited, variables_treeview_model)
variables_treeview$insertColumnWithAttributes(-1, "Labels", renderer, text = model_COLUMN[["levels"]],
  editable = model_COLUMN[["editable"]])

# add min column
renderer <- gtkCellRendererText()
renderer$setData("column",model_COLUMN["min"])
gSignalConnect(renderer, "edited", cell.edited, variables_treeview_model)
variables_treeview$insertColumnWithAttributes(-1, "Minimum", renderer, text = model_COLUMN[["min"]],
  editable = model_COLUMN[["editable"]])

# add max column
renderer <- gtkCellRendererText()
renderer$setData("column",model_COLUMN["max"])
gSignalConnect(renderer, "edited", cell.edited, variables_treeview_model)
variables_treeview$insertColumnWithAttributes(-1, "Maximum", renderer, text = model_COLUMN[["max"]],
  editable = model_COLUMN[["editable"]])
                                        
# add digits column
renderer <- gtkCellRendererText()
renderer$setData("column",model_COLUMN["digits"])
gSignalConnect(renderer, "edited", cell.edited, variables_treeview_model)
variables_treeview$insertColumnWithAttributes(-1, "Digits", renderer, text = model_COLUMN[["digits"]],
  editable = model_COLUMN[["editable"]])

variables_treeview$getSelection()$setMode("single")
#variables_treeview$setHeadersClickable(TRUE)

swindow$add(variables_treeview)
window$add(swindow)
