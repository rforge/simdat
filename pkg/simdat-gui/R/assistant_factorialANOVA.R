assistant_factorialANOVA <- function() {

  require(RGtk2)

  if(!exists(".sdeANOVA")) .sdeANOVA <- new.env()
  
  invalidateDesignData <- function() {
    #designData <- data.frame()
  }

  factorsDefaultData <- function(nfactor) {
    fdat <- vector("list",length=nfactor)
    for(i in 1:nfactor) {
      fdat[[i]]$name <- c(LETTERS,letters)[i]
      fdat[[i]]$nlevels <- 2
      fdat[[i]]$labels <- paste(fdat[[i]]$name,".",1:2,sep="")
    }
    return(fdat)
  }
  
  designDefaultData <- function(factorsData) {
    nfactor <- length(factorsData)
    labels <- vector("list",length=nfactor)
    names <- vector("character",length=nfactor)
    for(i in 1:nfactor) {
      labels[[i]] <- factorsData[[i]]$labels
      names[i] <- factorsData[[i]]$name
    }
    dat <- as.data.frame(expand.grid(labels))
    colnames(dat) <- names
    dat$n <- default_n
    dat$mean <- default_mean
    dat$sd <- default_sd
    dat$editable <- TRUE
    return(dat)
  }

  apply_changes_gradually <- function(data) {
    fraction <- progress_bar$getFraction() + 0.05
    if (fraction < 1.0) {
      progress_bar$setFraction(fraction)
      TRUE
    } else {
      assistant$destroy()
      FALSE
    }
  }

  factors_cell_edited <- function(cell, path.string, new.text, data) {

    checkPtrType(data, "GtkListStore")
    model <- data
     
    path <- gtkTreePathNewFromString(path.string)
    
    column <- cell$getData("column")
    
    iter <- model$getIter(path)$iter

    switch(column+1, { # name
       
        names <- vector("character",length=length(factorsData))
        for(i in 1:length(factorsData)) {
          names[i] <- factorsData[[i]]$name
        }
        i <- path$getIndices()[[1]]+1
        if(!(new.text %in% names)) {
          factorsData[[i]]$name <<- new.text
       	  model$set(iter, column, factorsData[[i]]$name)
        }
      }, { # levels
        i <- path$getIndices()[[1]]+1
        nnew <- as.integer(new.text)
        if(nnew > 0) {
          factorsData[[i]]$nlevels <<- as.integer(new.text)
         	model$set(iter, column, factorsData[[i]]$nlevels)
         	# check labels
         	if(factorsData[[i]]$nlevels != length(factorsData[[i]]$labels)) {
         	  labels <- factorsData[[i]]$labels
         	  nold <- length(labels)
         	  nnew <- factorsData[[i]]$nlevels
         	  if(nnew > nold) {
         	    # create extra labels
         	    labels[(nold+1):nnew] <- paste(factorsData[[i]]$name,(nold+1):nnew,sep="")
         	  }
         	  if(factorsData[[i]]$nlevels < length(factorsData[[i]]$labels)) {
         	    labels <- labels[1:nnew]
         	  }
         	  factorsData[[i]]$labels <<- labels
         	  model$set(iter, factors_treeview_model_column["labels"], paste(factorsData[[i]]$labels,collapse=","))
         	}
       	}
      }, {
        # labels
  # 	old.text <- model$get(iter, column)
      	i <- path$getIndices()[[1]]+1
        labels <- strsplit(paste(new.text,collapse=","),",")[[1]]
        if(length(labels) != factorsData[[i]]$nlevels) {
          warning("that ain't right!")
        } else {
          factorsData[[i]]$labels <<- labels
          model$set(iter, column, paste(factorsData[[i]]$labels,collapse=","))
        }
     })
  }
  
  design_cell_edited <- function(cell, path.string, new.text, data) {
  
    checkPtrType(data, "RGtkDataFrame")
    
    model <- data
    
    nfactor <- ncol(as.data.frame(model)) - 4
     
    path <- gtkTreePathNewFromString(path.string)
    
    column <- cell$getData("column")
    
    iter <- model$getIter(path)$iter

    sel <- colnames(as.data.frame(model))[column + 1]
    switch(sel, n = { # n
        i <- path$getIndices()[[1]]+1
        n <- as.integer(new.text)
        if(!is.na(n) & n > 1) {
          designData[i,column + 1] <<- new.text
       	  model[i, column + 1] <- designData[i,column + 1]
        }
      }, mean = { # mean
        i <- path$getIndices()[[1]]+1
        mu <- as.numeric(new.text)
        if(!is.na(mu)) {
          designData[i,column + 1] <<- mu
       	  model[i, column + 1] <- designData[i,column + 1]
        }
      }, sd = { # sd
        i <- path$getIndices()[[1]]+1
        sd <- as.numeric(new.text)
        if(!is.na(sd)) {
          designData[i,column + 1] <<- sd
       	  model[i, column + 1] <- designData[i,column + 1]
        }
      }
    )
  }
  
  design_cell_changed <- function(combo, path.string, new.iter, data)
  {
    checkPtrType(data, "RGtkDataFrame")
    model <- data
    
    nfactor <- ncol(as.data.frame(model)) - 4
    path <- gtkTreePathNewFromString(path.string)
    column <- combo$getData("column")

    iter <- model$getIter(path)$iter

    if(column+1 <= nfactor) {
      i <- path$getIndices()[[1]]+1
      designData[i,column+1] <<- new.iter
      model[i, column+1] <- new.iter
    }
  }

  update_factors_data <- function(nfactor) {
    nold <- length(factorsData)
    if(nfactor > nold) {
      for(i in (nold+1):nfactor) {
        mlist <- factorsData
        mlist[[i]] <- list()
        mlist[[i]]$name <- c(LETTERS,letters)[i]
        mlist[[i]]$nlevels <- 2
        mlist[[i]]$labels <- paste(mlist[[i]]$name,".",1:mlist[[i]]$nlevels,sep="")
        factorsData <<- mlist
      }
    }
    if(nfactor < length(factorsData)) {
      factorsData <<- factorsData[1:nfactor]
    }
  }

  update_factors_treeview_model <- function(model,data) {
    nfactor <- length(data)
    ncurrent <- model$iterNChildren()
    if(ncurrent == 0) iter <- model$append()$iter else iter <- model$getIterFirst()$iter
    i <- 1
    done <- FALSE
    while(!done) {
      #
      if(i <= nfactor) {
        model$set(iter,
        factors_treeview_model_column["name"], data[[i]]$name,
	      factors_treeview_model_column["nlevels"], data[[i]]$nlevels,
	      factors_treeview_model_column["labels"], paste(data[[i]]$labels,collapse=","),
	      factors_treeview_model_column["editable"], TRUE)
	    }
      if(i > nfactor) {
        # remove surplus rows
        while(ncurrent > nfactor) {
          model$IterNthChild(iter,ncurrent)
          model$remove(iter)
          ncurrent <- model$iterNChildren()
        }
      }
      if(i >= nfactor & i >= ncurrent) done <- TRUE else {
        if(i >= ncurrent & nfactor > ncurrent) iter <- model$append()$iter else model$iterNext(iter)
        i <- i + 1
      }
    }
  }

  update_factors_treeview <- function(treeview,data) {
    model <- treeview$getModel()
    update_factors_treeview_model(model,data)
  }

  initialize_factors_treeview <- function(treeview) {

    treeview$setModel(factors_treeview_model)
    treeview$setRulesHint(TRUE)
    treeview$getSelection()$setMode("single")
    
    renderer <- gtkCellRendererTextNew()
    gSignalConnect(renderer, "edited", factors_cell_edited, factors_treeview_model)
    renderer$setData("column", factors_treeview_model_column["name"])
    treeview$insertColumnWithAttributes(-1, "Name", renderer, text = factors_treeview_model_column[["name"]],
    editable = factors_treeview_model_column[["editable"]])

    renderer <- gtkCellRendererTextNew()
    gSignalConnect(renderer, "edited", factors_cell_edited, factors_treeview_model)
    renderer$setData("column", factors_treeview_model_column["nlevels"])
    treeview$insertColumnWithAttributes(-1, "Levels", renderer, text = factors_treeview_model_column[["nlevels"]],
    editable = factors_treeview_model_column[["editable"]])

    renderer <- gtkCellRendererTextNew()
    gSignalConnect(renderer, "edited", factors_cell_edited, factors_treeview_model)
    renderer$setData("column", factors_treeview_model_column["labels"])
    treeview$insertColumnWithAttributes(-1, "Labels", renderer, text = factors_treeview_model_column[["labels"]],
    editable = factors_treeview_model_column[["editable"]])

  }
  
  initialize_design_treeview <- function(treeview,model) {

    treeview$setModel(model)
    treeview$setRulesHint(TRUE)
    treeview$getSelection()$setMode("single")

    # delete all columns in treeview...bit annoying, but easier...
    cols <- treeview$getColumns()
    if(length(cols)>0) {
      for(i in 1:length(cols)) {
        treeview$removeColumn(cols[[i]])
      }
    }

    dat <- as.data.frame(model)
    for(i in 1:(ncol(dat) - 4)) {
      model <- gtkListStoreNew("gchararray")
      levels <- factorsData[[i]]$labels
      for(j in 1:length(levels)) {
        iter <- model$append()$iter
        model$set(iter,0,levels[j])
      }
      
      renderer <- gtkCellRendererComboNew()
      renderer$set("model" = model)
      renderer$set("text-column" = 0)
      #gSignalConnect(renderer, "edited", design_cell_edited, design_treeview_model)
      gSignalConnect(renderer, "edited", design_cell_changed, design_treeview_model)
      renderer$setData("column", i-1)
      treeview$insertColumnWithAttributes(-1, colnames(dat)[i], renderer, text = i - 1,
      editable = ncol(dat)-1)
    }
    
    #spacer
    renderer <- gtkCellRendererTextNew()
    #gSignalConnect(renderer, "edited", design_cell_edited, model)
    #renderer$setData("column", ncol(dat) - 4)
    treeview$insertColumnWithAttributes(-1, "", renderer)
    
    # N
    renderer <- gtkCellRendererTextNew()
    gSignalConnect(renderer, "edited", design_cell_edited, design_treeview_model)
    renderer$setData("column", ncol(dat) - 4)
    treeview$insertColumnWithAttributes(-1, "N", renderer, text =  ncol(dat) - 4,
    editable = ncol(dat)-1)
    
    # mean
    renderer <- gtkCellRendererTextNew()
    gSignalConnect(renderer, "edited", design_cell_edited, design_treeview_model)
    renderer$setData("column", ncol(dat) - 3)
    treeview$insertColumnWithAttributes(-1, "mean", renderer, text =  ncol(dat) - 3,
    editable = ncol(dat)-1)
    
    # sd
    renderer <- gtkCellRendererTextNew()
    gSignalConnect(renderer, "edited", design_cell_edited, design_treeview_model)
    renderer$setData("column", ncol(dat) - 2)
    treeview$insertColumnWithAttributes(-1, "sd", renderer, text =  ncol(dat) - 2,
    editable = ncol(dat)-1)
    
  }


  on_assistant_apply <- function(widget, data)
  {
    current_page <- widget$getCurrentPage()
    if (current_page == 0) {
       #
       #gtkTableResize(table, nfactor, 4)
       widget$insertPage(create_define_factors(),1)# addActionWidget(swindow, table)
       #create_page2(widget)
    }
    #gTimeoutAdd(100, apply_changes_gradually)
  }

  on_assistant_prepare <- function(widget, page, data)
  {
    current_page <- widget$getCurrentPage()
    n_pages <- widget$getNPages()

    title <- sprintf("Sample assistant (%d of %d)", current_page + 1, n_pages)
    widget$setTitle(title)

    if (current_page == 1) {
      #cat("calling on_assistant_prepare page",widget$getCurrentPage(),"\n")
      #factorsData <<- factorsDefaultData(nfactor)
      update_factors_data(nfactor)
      update_factors_treeview(factors_treeview,factorsData)
    }
    if (current_page == 2) {
       #gtkTableResize(table, nfactor, 4)
       #create_page2(widget)
       designData <<- designDefaultData(factorsData)
       design_treeview_model$setFrame(designData)
       initialize_design_treeview(design_treeview,design_treeview_model)
    }
    if (current_page == 3)
      widget$commit()
  }

  on_entry_factors_changed <- function(widget, assistant)
  {
    #cat("calling on_entry_factors_changes\n")
    page_number <- assistant$getCurrentPage()
    current_page <- assistant$getNthPage(page_number)
    nfactor <<- widget$getValueAsInt()

    if (nfactor > 0) {
      assistant$setPageComplete(current_page, TRUE)
      nfactor <<- nfactor ## TODO
      #swindow <<- create_define_factors(nfactor)
      #swindow$showAll()
      #
    } else
      assistant$setPageComplete(current_page, FALSE)
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
    swindow$AddWithViewport(factors_treeview)
    assistant$appendPage(swindow)
    assistant$setPageTitle(swindow, "Define factors")
    assistant$setPageComplete(swindow, TRUE)
  }

  create_page3 <- function(assistant)
  {
    dwindow <- gtkScrolledWindow()
    dwindow$AddWithViewport(design_treeview)
    assistant$appendPage(dwindow)
    assistant$setPageTitle(dwindow, "Define design")
    assistant$setPageComplete(dwindow, TRUE)
  }

  create_page4 <- function(assistant)
  { 
    label <- gtkLabel("This is a confirmation page, press 'Apply' to apply changes")

    assistant$appendPage(label)
    assistant$setPageType(label, "confirm")
    assistant$setPageComplete(label, TRUE)
    assistant$setPageTitle(label, "Confirmation")

    pixbuf <- assistant$renderIcon(GTK_STOCK_DIALOG_INFO, "dialog")
    assistant$setPageHeaderImage(label, pixbuf)
  }

  create_page5 <- function(assistant) {
    page <- gtkAlignment(0.5, 0.5, 0.5, 0.0)

    progress_bar <- gtkProgressBar()
    page$add(progress_bar)
    page$showAll()

    assistant$appendPage(page)

    assistant$setPageType(page, "progress")
    assistant$setPageTitle(page, "Applying changes")

    ## This prevents the assistant window from being
    ## closed while we're "busy" applying changes.
    assistant$setPageComplete(page,FALSE)
  }

  # 'global' widgets and variables
  factorsData <- factorsDefaultData(nfactor)
  nfactor <- 2
  default_n <- 15
  default_mean <- 0
  default_sd <- 1
  factors_treeview_model_column <- c(name = 0, nlevels = 1, labels = 2, editable = 3)
  factors_treeview_model <- gtkListStoreNew("gchararray", "gint", "gchararray", "gboolean")
  factors_treeview <- gtkTreeViewNewWithModel(factors_treeview_model)
  initialize_factors_treeview(factors_treeview)

  design_treeview_model_column <- c(n = 0, editable = 1, A = 2)
  #design_treeview_model <- gtkListStoreNew("gint", "gboolean","gchararray")
  design_treeview_model <- rGtkDataFrame()
  design_treeview <- gtkTreeViewNewWithModel(design_treeview_model)
  #initialize_design_treeview(design_treeview,design_treeview_model)
  
  assistant <- gtkAssistant(show = F)
  assistant$setDefaultSize(-1, 300)
  create_page1(assistant)
  create_page2(assistant)
  create_page3(assistant)
  create_page4(assistant)
  
  gSignalConnect(assistant, "cancel", gtkWidgetDestroy)
  gSignalConnect(assistant, "close", gtkWidgetDestroy)
  gSignalConnect(assistant, "apply", on_assistant_apply)
  gSignalConnect(assistant, "prepare", on_assistant_prepare)

  assistant$showAll()
}
