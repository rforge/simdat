# adapted from Shiny package
runGUI <- function(gui,port=8100L,launch.browser=TRUE) {
  require(shiny)
  if(missing(gui)) gui <- NA
  guiDir <- system.file('gui', package='simdat.gui')
  dir <- resolve(guiDir, gui)
  if (is.null(dir)) {
    if (is.na(gui)) {
      errFun <- message
      errMsg <- ''
    }
    else {
      errFun <- stop
      errMsg <- paste('Gui', gui, 'does not exist. ')
    }
    
    errFun(errMsg,
           'Valid examples are "',
           paste(list.files(guiDir), collapse='", "'),
           '"')
  }
  else {
    runApp(dir, port = port, launch.browser = launch.browser)
  }
}