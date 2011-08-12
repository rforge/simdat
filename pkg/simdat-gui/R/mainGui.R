require(RGtk2)
require(RGtk2Extras)

# appWindow demo from GTK

window <- NULL

# define some callbacks

activate.radio.action <- function(action, current)
{
    name <- action$getName()
    typename <- class(action)[1]
    value <- current$getCurrentValue()
    if (current$getActive()) {
        dialog <- gtkMessageDialogNew(window, "destroy-with-parent", "info", "close",
                       "You activated radio action:", name, "of type ", typename,
                       "\nCurrent value: ", value)
        gSignalConnect(dialog, "response", gtkWidgetDestroy)
    }

}

activate.action <- function(action, w)
{
    name <- action$getName()
    typename <- class(action)[1] # parent, dialog mode, message type, buttons, message
    dialog <- gtkMessageDialogNew(window, "destroy-with-parent", "info", "close",
        "You activated action:", name, "of type", typename)
    gSignalConnect(dialog, "response", gtkWidgetDestroy)
}
activate.email <- function(about, link, data)
{
    print(paste("send mail to", link))
}
activate.url <- function(about, link, data)
{
    print(paste("show url", link))
}
about.cb <- function(action, window)
{
    filename <- imagefile("rgtk-logo.gif")
    if (file.exists(filename)) {
        pixbuf <- gdkPixbufNewFromFile(filename)[[1]]
        # make white space transparent
        transparent <- pixbuf$addAlpha(TRUE, 253, 253, 253)
    }

    gtkAboutDialogSetEmailHook(activate.email)
    gtkAboutDialogSetUrlHook(activate.url)

    gtkShowAboutDialog(window, name="SIMDAT", version="0.1",
                       copyright="(C) M. Speekenbrink and A. McClelland",
                       license="GPL",
                       website="http://www.ucl.ac.uk/SIMDAT/",
                       comments="Data simulation",
                       authors=c("Maarten Speekenbrink <m.speekenbrink@ucl.ac.uk>"),
                       documenters="See authors", logo=transparent)
    
}
update.statusbar <- function(buffer, statusbar)
{
    statusbar$pop(0)
    count <- buffer$getCharCount()
    # get an "iter" describing the position of the cursor
    mark <- buffer$getInsert()
    iter <- buffer$getIterAtMark(mark)$iter
    row <- iter$getLine()
    col <- iter$getLineOffset()
    msg <- paste("Cursor at row", row, "column", col, "-", count, "chars in document")
    statusbar$push(0, msg)
}

mark.set.callback <- function(buffer, new.location, mark, data)
{
    update.statusbar(buffer, data)
}

update.resize.grip <- function(widget, event, statusbar)
{
  max_full_mask <- GdkWindowState["maximized"] | GdkWindowState["fullscreen"]
  if (event[["changedMask"]] & max_full_mask)
  {
      statusbar$setHasResizeGrip(!(event[["newWindowState"]] & max_full_mask))
  }
  return(FALSE)
}

registered <- FALSE
register.stock.icons <- function()
{
    if (registered)
        return

    item <- list(c("rgtk-logo", "_RGtk!", 0, 0, NULL))

    gtkStockAdd(item) # register as stock

    # now we also have to add it to an icon factory
    factory <- gtkIconFactoryNew() # make our own factory
    gtkIconFactoryAddDefault(factory) # make it a default factory

    filename <- imagefile("rgtk-logo.gif")
    if (file.exists(filename)) {
        pixbuf <- gdkPixbufNewFromFile(filename)[[1]]
        # make white space transparent
        transparent <- pixbuf$addAlpha(TRUE, 255, 255, 255)
        # make an icon from the image and add it to factory using stock id
        icon.set <- gtkIconSetNewFromPixbuf(transparent)
        factory$add("rgtk-logo", icon.set)
    } else warning("Could not load the RGtk logo")

    registered = TRUE
}

# create the actions

entries <- list(
    # name, stock.id (prefab icons), label (. signifies mneumonic)
    list("ProjectMenu", NULL, "_Project"),
    list("VariablesMenu", NULL, "_Variables"),
    list("DataMenu", NULL, "_Data"),
    list("DesignMenu", NULL, "_Wizards"),
    list("UnivANOVAMenu", NULL, "_Univariate ANOVA"),
    list("HelpMenu", NULL, "_Help"), # accelerator (kb shortcut), tooltip, callback
    # File menu
    list("New", "gtk-new", "_New", "<control>N", "Create a new file", activate.action),
    list("Open", "gtk-open", "_Open", "<control>O", "Open a file", activate.action),
    list("SaveModel", "gtk-save", "_Save Model", "<control>S", "Save current SIMDAT model", activate.action),
    list("SaveData", "gtk-save", "Save _Data...", NULL, "Save data of current SIMDAT model", activate.action),
    list("Quit", "gtk-quit", "_Quit", "<control>Q", "Quit", activate.action),
    # Variables menu
    list("ViewVars", NULL, "_View variables...", NULL, "View currently specified variables", activate.action),
    list("AddVars", NULL, "_Add variables...", NULL, "Add a variable", activate.action),
    list("EditVars", NULL, "_Edit variables...", NULL, "Edit variables", activate.action),
    list("DeleteVars", NULL, "_Delete variables...", NULL, "Delete variables", activate.action),
    # Data menu
    list("ViewData", NULL, "_View data...", NULL, "View data", activate.action),
    list("EditData", NULL, "_Edit variables...", NULL, "Edit data", activate.action),
    list("SimulateData", NULL, "_Simulate variables...", NULL, "Simulate data", activate.action),
    # Design menu
    list("Oneway", NULL, "_Oneway design...", NULL, "Generate a oneway design", activate.action),
    list("Factorial", NULL, "_Factorial design...", NULL, "Generate a factorial design", activate.action),
    list("General", NULL, "_General design...", NULL, "Generate a general (ANOVA) design", activate.action),
    list("UnivRegression", NULL, "_Univariate regression design...", NULL, "Generate a univariate regression design", activate.action),
    list("About", NULL, "_About", "<control>A", "About", about.cb),
    list("Logo", "rgtk-logo", NULL, NULL, "RGtk", activate.action)
)

# create a window
window <- gtkWindowNew("toplevel")
window$setDefaultSize(800, 600)
window$setTitle("SIMDAT")

# add a table layout
table <- gtkTableNew(1, 4, FALSE)
window$add(table)

agroup <- gtkActionGroupNew("AppWindowActions")

# add actions to group with the window widget passed to callbacks
agroup$addActions(entries, window)
#agroup$addToggleActions(toggle.entries)
#agroup$addRadioActions(color.entries, 0, activate.radio.action)
#agroup$addRadioActions(shape.entries, 0, activate.radio.action)

# create a UI manager to read in menus specified in XML
manager <- gtkUIManagerNew()

window$setData("ui-manager", manager)
manager$insertActionGroup(agroup, 0)

window$addAccelGroup(manager$getAccelGroup())

# Define some XML
uistr <- paste(
"<ui>",
"  <menubar name='MenuBar'>",
"    <menu action='ProjectMenu'>",
"      <menuitem action='New'/>",
"      <menuitem action='Open'/>",
"      <menuitem action='SaveModel'/>",
"      <menuitem action='SaveData'/>",
"      <separator/>",
"      <menuitem action='Quit'/>",
"    </menu>",
"    <menu action='VariablesMenu'>",
"      <menuitem action='ViewVars'/>",
"	   <menuitem action='AddVars'/>",
"	   <menuitem action='EditVars'/>",
"	   <menuitem action='DeleteVars'/>",
"    </menu>",
"    <menu action='DataMenu'>",
"      <menuitem action='ViewData'/>",
"      <menuitem action='EditData'/>",
"      <menuitem action='SimulateData'/>",
"    </menu>",
"    <menu action='DesignMenu'>",
"      <menu action='UnivANOVAMenu'>",
"        <menuitem action='Oneway'/>",
"        <menuitem action='Factorial'/>",
"        <menuitem action='General'/>",
"      </menu>",
"      <menuitem action='UnivRegression'/>",
"    </menu>",
"    <menu action='HelpMenu'>",
"      <menuitem action='About'/>",
"    </menu>",
"  </menubar>",
"</ui>", sep="\n")

manager$addUiFromString(uistr)
menubar <- manager$getWidget("/MenuBar")
menubar$show() # location, layout behavior, padding
table$attach(menubar, 0, 1, 0, 1, c("expand", "fill"), 0, 0, 0)

#bar <- manager$getWidget("/ToolBar")
#bar$setTooltips(TRUE)
#bar$show()
#table$attach(bar, 0, 1, 1, 2, c("expand", "fill"), 0, 0, 0)

notebook <- gtkNotebook()
table$attach(notebook, 0, 1, 2, 3, c("expand", "fill"), c("expand", "fill"), 0, 0)

### Variables notebook ###
notebook_page_variables <- gtkVBox()
notebook_page_variables_buttonBox <- gtkHBox()
add_variable <- gtkButton("Add variable") # should bring up wizard
delete_variable <- gtkButton("Delete variable")
notebook_page_variables_buttonBox$add(add_variable)
notebook_page_variables_buttonBox$add(delete_variable)

notebook_page_variables$add(notebook_page_variables_buttonBox)

notebook_page_variables_label <- gtkLabel("Variables")
notebook$appendPage(notebook_page_variables,notebook_page_variables_label)

### Data notebook ###
notebook_page_data <- gtkVBox()
notebook_page_data_buttonBox <- gtkHBox()
simulate_data <- gtkButton("Simulate") # should bring up wizard
summary_data <- gtkButton("Summary") # should bring up wizard
confirm_changes_data <- gtkButton("Confirm changes")
notebook_page_data_buttonBox$add(simulate_data)
notebook_page_data_buttonBox$add(summary_data)
notebook_page_data$add(notebook_page_data_buttonBox)
notebook_page_data_swindow <- gtkDfEdit(iris)
#notebook_page_data_swindow <- gtkScrolledWindow()
notebook_page_data_dataframe <- rGtkDataFrame(iris)
notebook_page_data_dataview <- gtkTreeView(notebook_page_data_dataframe)
notebook_page_data_dataview$getSelection()$setMode("browse")
for(i in 1:ncol(iris)) {
  column <- gtkTreeViewColumn(colnames(iris)[i], gtkCellRendererText(), text = 0)
  notebook_page_data_dataview$appendColumn(column)
}
#notebook_page_data_swindow$add(notebook_page_data_dataview)
notebook_page_data$add(notebook_page_data_swindow)
notebook_page_data$add(confirm_changes_data)
notebook_page_data_label <- gtkLabel("Data")
notebook$appendPage(notebook_page_data,notebook_page_data_label)


#scrolled.window <- gtkScrolledWindowNew()
#scrolled.window$setPolicy("automatic", "automatic")
#scrolled.window$setShadowType("in") # add scrolled window below toolbar and fill the remaining space
#table$attach(scrolled.window, 0, 1, 2, 3, c("expand", "fill"), c("expand", "fill"), 0, 0)

# now let the user put some text in the scrolling window

#contents <- gtkTextViewNew()
#contents$grabFocus()
#scrolled.window$add(contents)

# how about a cool status bar?

#statusbar <- gtkStatusbarNew() # squeeze it in at the bottom
#table$attach(statusbar, 0, 1, 3, 4, c("expand", "fill"), 0, 0, 0)

#buffer <- contents$getBuffer() # statusbar listens to buffer
#gSignalConnect(buffer, "changed", update.statusbar, statusbar)
#gSignalConnect(buffer, "mark_set", mark.set.callback, statusbar)
# link resize grip to window state
#gSignalConnect(window, "window_state_event", update.resize.grip, statusbar)

#update.statusbar(buffer, statusbar)


