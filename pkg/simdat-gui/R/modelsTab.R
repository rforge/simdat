modelsTab_initialize() <- function() {
  if(!exists(.sde)) stop("sde environment does not exist")
  if(!exists(.sde$modelsTab)) {
    .sde$modelsTab$main <- gtkVBox()
    .sde$modelsTab$buttonBox <- gtkHBox()
    .sde$modelsTab$addModelButton <- gtkButton("Add model")
    .sde$modelsTab$deleteModelButton <- gtkButton("Delete model")
    .sde$modelsTab$label <- gtkLabel("Models")
    .sde$modelsTab$buttonBox$add(.sde$modelsTab$addModelButton)
    .sde$modelsTab$buttonBox$add(.sde$modelsTab$deleteModelButton)
    .sde$simdatGUI$notebook
  }
}

modelsTab_update() {
  if(!exists(.sde)) stop("sde environment does not exist")
  if(!exists(.sde$modelsTab)) modelsTab_initialize()
  .sde$modelsTab
  
}


notebook_page_models <- gtkVBox()
notebook_page_models_buttonBox <- gtkHBox()
add_model <- gtkButton("Add model") # should bring up wizard
delete_model <- gtkButton("Delete model")
notebook_page_models_buttonBox$add(add_model)
notebook_page_models_buttonBox$add(delete_model)
notebook_page_models$add(notebook_page_models_buttonBox)
notebook_page_models_label <- gtkLabel("Models")
notebook$appendPage(notebook_page_models,notebook_page_models_label)
