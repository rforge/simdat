require(RGtk2)
require(RGtk2Extras)
etc <- "/home/maarten/Documents/RForge/simdat/glade"

on_simdat_aboutdialog_close <- function(acion,window) {
 simdatGUI$getObject("simdat_aboutdialog")$hide()
}

on_menuitemAbout_activate <- function(action, window) {
  simdatGUI$getObject("simdat_aboutdialog")$show()
  
}

simdat <- function() {
  if(!exists("simdatGUI")) {
    simdatGUI <<- gtkBuilderNew()
    simdatGUI$addFromFile(file.path(etc, "simdat_gui.ui"))
  
    dataEditor <- gtkDfEdit(iris)
    simdatGUI$getObject("dataEditorBox")$add(dataEditor)
  }
  
  simdatGUI$getObject("simdat_window")$show()
  simdatGUI$getObject("simdat_aboutdialog")$show()
}
simdat()
