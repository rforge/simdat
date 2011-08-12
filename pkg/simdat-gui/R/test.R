require(RGtk2)

factorsDefaultData <- function(nfactor) {
  fdat <- vector("list",length=nfactor)
  for(i in 1:nfactor) {
    fdat[[i]]$name <- c(LETTERS,letters)[i]
    fdat[[i]]$nlevels <- 2
    fdat[[i]]$labels <- paste(fdat[[i]]$name,".",1:2,sep="")
  }
  return(fdat)
}

setFactorsControls <- function(factorsData,factorsControls) {
  nfactor <- length(factorsData)
  for(i in 1:nfactor) {s
    if(length(factorsControls$names) != nfactor) {
      l <- length(factorsControls$names)
    }
    if(length(factorsControls$nlevels) != nfactor) {
    
    }
    if(length(factorsControls$labels) != nfactor) {
    
    }
    if(length(factorsControls$setLabels) != nfactor) {
    
    }
  }
}

setFactorsTable <- function(nfactor,factorsControls) {
  factorsTable <<- gtkTable(nfactor+1,4)
  factorsTable$attach(gtkLabel("name"),left.attach=0,right.attach=1,top.attach=0,bottom.attach=1)
  factorsTable$attach(gtkLabel("n levels"),left.attach=1,right.attach=2,top.attach=0,bottom.attach=1)
  factorsTable$attach(gtkLabel("level names"),left.attach=2,right.attach=3,top.attach=0,bottom.attach=1)
  factorsTable$attach(gtkLabel(""),left.attach=3,right.attach=4,top.attach=0,bottom.attach=1)
  #table <- gtkTable(nfactor+1,4)
  table$attach(gtkLabel(paste(i,"-1")),left.attach=0,right.attach=1,top.attach=i-1,bottom.attach=i)
  for(i in 1:(nfactor)) {
    factorsTable$attach(factorsControl$names[[i]],left.attach=0,right.attach=1,top.attach=i,bottom.attach=i+1)
    factorsTable$attach(factorsControl$nlevels[[i]],left.attach=1,right.attach=2,top.attach=i,bottom.attach=i+1)
    factorsTable$attach(factorsControl$labels[[i]],left.attach=2,right.attach=3,top.attach=i,bottom.attach=i+1)
    factorsTable$attach(factorsControl$setLlabels[[i]],left.attach=3,right.attach=4,top.attach=i,bottom.attach=i+1)
  }
}

on_entry_factors_changed <- function(widget, assistant)
{
  page_number <- assistant$getCurrentPage()
  current_page <- assistant$getNthPage(page_number)
  nfactor <<- widget$getValueAsInt()

  if (nfactor > 0) {
    assistant$setPageComplete(current_page, TRUE)
    #nfactor <<- nfactor ## TODO
    #
  } else
    assistant$setPageComplete(current_page, FALSE)
}

on_assistant_apply <- function(widget, data)
{
  current_page <- widget$getCurrentPage()
  if (current_page == 0) {
     #gtkTableResize(factorsTable, nfactor, 4)
     
     factorsTable <<- setFactorsTable(nfactor,factorsData,factorsControls)
     #i <- 1
     #factorTable$attach(gtkLabel(paste(i,"-1")),left.attach=0,right.attach=1,top.attach=i-1,bottom.attach=i)
     #widget$insertPage(create_define_factors(),1)# addActionWidget(swindow, table)
     #create_page2(widget)
  }
  gTimeoutAdd(100, apply_changes_gradually)
}

on_assistant_prepare <- function(widget, page, data)
{
  current_page <- widget$getCurrentPage()
  n_pages <- widget$getNPages()

  title <- sprintf("Sample assistant (%d of %d)", current_page + 1, n_pages)
  widget$setTitle(title)

  # prepare is just before changing the page
  if (current_page == 1) {
     cat(title)
     factorsTable$resize(nfactor, 4)
     factorsTable$attach(gtkLabel(paste("nfactor")),left.attach=0,right.attach=1,top.attach=i-1,bottom.attach=i)
     #create_page2(widget)
  }
  if (current_page == 3)
    widget$commit()
}

create_page1 <- function(assistant)
{
  box <- gtkHBox(FALSE, 12)
  box$setBorderWidth(12)

  label <- gtkLabel("How many factors?:")
  box$packStart(label, FALSE, FALSE, 0)

  entry <- gtkSpinButton(min=0,max=100,step=1,digits=0)
  box$packStart(entry, TRUE, TRUE, 0)
  gSignalConnect(entry, "changed", on_entry_factors_changed, assistant)

  assistant$appendPage(box)
  assistant$setPageTitle(box, "Factorial ANOVA design")
  assistant$setPageType(box, "intro")
  
  #pixbuf <- assistant$renderIcon(GTK_STOCK_DIALOG_INFO, "dialog")
  #assistant$setPageHeaderImage(box, pixbuf)
}


create_page2 <- function(assistant)
{
  swindow <- gtkScrolledWindow()
  swindow$AddWithViewport(factorsTable)
  
  assistant$appendPage(swindow)
  assistant$setPageTitle(swindow, "Define factors")
}

nfactor <- 0

assistant <- gtkAssistant(show = F)
assistant$setDefaultSize(-1, 300)

factorsData <- factorsDefaultData(1)
factorsControls <- list(names=list(),nlevels=list(),labels=list())

factorsTable <- gtkTable(1,4)
factorsTable$attach(gtkLabel("name"),left.attach=0,right.attach=1,top.attach=0,bottom.attach=1)
factorsTable$attach(gtkLabel("n levels"),left.attach=1,right.attach=2,top.attach=0,bottom.attach=1)
factorsTable$attach(gtkLabel("level names"),left.attach=2,right.attach=3,top.attach=0,bottom.attach=1)
factorsTable$attach(gtkLabel(""),left.attach=3,right.attach=4,top.attach=0,bottom.attach=1)

create_page1(assistant)
create_page2(assistant)

gSignalConnect(assistant, "cancel", gtkWidgetDestroy)
gSignalConnect(assistant, "close", gtkWidgetDestroy)
gSignalConnect(assistant, "apply", on_assistant_apply)
gSignalConnect(assistant, "prepare", on_assistant_prepare)

assistant$showAll()

