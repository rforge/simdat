# adapted from similar functions in Deducer

.registerDialog <- function(name,generator){
	de <- as.environment(match("package:simdat-gui", search()))
	if(!exists(".dialogGenerators",envir=de))
		assign(".dialogGenerators",  list(), envir=de)
	dg <- get(".dialogGenerators",envir=de)
	dg[[name]] <- generator
	assign(".dialogGenerators",  dg, envir=de)
}

.getDialog <- function(name,newInstance=FALSE){
	de <- as.environment(match("package:simdat-gui", search()))
	if(!exists(".dialogs",envir=de))
		assign(".dialogs",  list(), envir=de)
	dialog <- .dialogs[[name]]
	if(is.null(dialog) || newInstance){
		dialog <- .dialogGenerators[[name]]()
		if(!newInstance){
			di <- get(".dialogs",envir=de)
			di[[name]] <- dialog
			assign(".dialogs",  di, envir=de)
		}
	}
	dialog
}

.simdatExecute<-function(cmd){
    cmds<-parse(text=cmd)
    for(i in 1:length(cmds)){
        out<-eval(parse(text=paste("capture.output(",as.character(cmds[i]),")")),globalenv())
        for(line in out)
            cat(line,"\n")
    }
}

.jChooserMacLAF<-function(){

	if(Sys.info()[1]!="Darwin") stop("Silly rabbit, Mac Look And Feel is only for Macs!")
	
	.jaddClassPath("./System/Library/Java")
	.jaddLibrary("quaqua",system.file("java/quaqua","libquaqua.jnilib",package="simdat-gui"))
	.jaddLibrary("quaqua64",system.file("java/quaqua","libquaqua64.jnilib",package="simdat-gui"))
	.jpackage("simdat-gui","quaqua.jar")
	
	HashSet <- J("java.util.HashSet")
	QuaquaManager <- J("ch.randelshofer.quaqua.QuaquaManager")
	
	excludes <- new(HashSet)
	excludes$add("TitledBorder")
	excludes$add("Button")
	QuaquaManager$setExcludedUIs(excludes)
	
	J("java.lang.System")$setProperty("Quaqua.visualMargin","0,0,0,0")
	
	J("javax.swing.UIManager")$setLookAndFeel(QuaquaManager$getLookAndFeel())
}

.assign.classnames <- function(){
	de <- as.environment(match("package:simdat-gui", search()))
	assign("SimDatMain", J("simdat.SimDat"), de)

	#assign("SimpleRDialog", J("org.rosuda.deducer.widgets.SimpleRDialog") , de)
	#assign("SimpleRSubDialog", J("org.rosuda.deducer.widgets.SimpleRSubDialog") , de)
	#assign("RDialog", J("org.rosuda.deducer.widgets.RDialog") , de)

	#assign("VariableSelectorWidget", J("org.rosuda.deducer.widgets.VariableSelectorWidget"), de)
	#assign("VariableListWidget", J("org.rosuda.deducer.widgets.VariableListWidget"), de)
	#assign("CheckBoxesWidget", J("org.rosuda.deducer.widgets.CheckBoxesWidget"), de)
	#assign("ButtonGroupWidget", J("org.rosuda.deducer.widgets.ButtonGroupWidget"), de)
	#assign("SingleVariableWidget", J("org.rosuda.deducer.widgets.SingleVariableWidget"), de)
	#assign("SliderWidget", J("org.rosuda.deducer.widgets.SliderWidget"), de)
	#assign("TextAreaWidget", J("org.rosuda.deducer.widgets.TextAreaWidget"), de)
	#assign("ComboBoxWidget", J("org.rosuda.deducer.widgets.ComboBoxWidget"), de)
	#assign("ListWidget", J("org.rosuda.deducer.widgets.ListWidget"), de)
	#assign("TextFieldWidget", J("org.rosuda.deducer.widgets.TextFieldWidget"), de)
	#assign("ObjectChooserWidget", J("org.rosuda.deducer.widgets.ObjectChooserWidget"), de)
	
	#assign("RDialogMonitor", J("org.rosuda.deducer.widgets.RDialogMonitor"), de)
	#assign("AddRemoveButtons", J("org.rosuda.deducer.widgets.AddRemoveButtons"), de)
	
	#assign("JLabel", J("javax.swing.JLabel"), de)
}

.First.lib <- function(libname, pkgname) { 
	de <- as.environment(match("package:simdat-gui", search()))
	
	.jgr<-exists(".jgr.works",envir=as.environment(match("package:JGR", search())))
	if(.jgr)
		.jgr<-get(".jgr.works", envir=as.environment(match("package:JGR", search())))
	if(!is.null(getOption("SimDatNoGUI")) && getOption("SimDatNoGUI")){
		cat("\nLoading SimDat without GUI. If you wish the GUI to load, run options(SimDatNoGUI=FALSE) before loading SimDat\n")
		assign(".simdat",.jnull(),de)
		assign(".simdat.loaded",TRUE,de)
		assign(".jgr",.jgr,de)
		assign(".windowsGUI",exists("winMenuAdd"),de)
		return(TRUE)
	}

	if (nzchar(Sys.getenv("NOAWT")) && .jgr!=TRUE) {
		cat("\nNOTE: Environmental variable NOAWT set. Loading SimDat without GUI.\n")
		assign(".simdat",.jnull(),de)
		assign(".simdat.loaded",TRUE,de)
		assign(".jgr",FALSE,de)
		assign(".windowsGUI",exists("winMenuAdd"),de)
		return(TRUE)	
	}
	
	jriOK <- try(.jinit(),silent=TRUE)
	if(class(jriOK) %in% "try-error"){
		cat("\nWarning: Problem initiating JRI. The Java GUI will not be available.\n")
		print(jriOK)
		assign(".simdat",.jnull(),de)
		assign(".simdat.loaded",TRUE,de)
		assign(".jgr",FALSE,de)
		assign(".windowsGUI",exists("winMenuAdd"),de)
		return(TRUE)
	}
	
	jriOK <- try(.jengine(TRUE),silent=TRUE)
	if(class(jriOK) %in% "try-error"){
		cat("\nWarning: Problem initiating JRI. Make sure you built R with shared libraries The Java GUI will not be available.\n")
		print(jriOK)
		assign(".simdat",.jnull(),de)
		assign(".simdat.loaded",TRUE,de)
		assign(".jgr",FALSE,de)
		assign(".windowsGUI",exists("winMenuAdd"),de)
		return(TRUE)
	}
	.jpackage(pkgname,"simdat.jar") 
	.jpackage("JavaGD")
	.jpackage("JGR")
	
	.simdat<-try(.jnew("simdat/SimDat",.jgr),silent=TRUE)
	if(class(simdat) %in% "try-error"){
		cat("Warning: Unable to start SimDat's Java class. The Java GUI will not be available.")
		print(simdat)
		assign(".simdat",.jnull(),de)
		assign(".simdat.loaded",TRUE,de)
		assign(".jgr",.jgr,de)
		assign(".windowsGUI",exists("winMenuAdd"),de)
		return(TRUE)
	}
	assign(".simdat",.simdat,de)
	assign(".simdat.loaded",TRUE,de)
	
	.windowsGUI <- FALSE
	
	if(exists("winMenuAdd")){
		temp<-try(winMenuAdd("SimDat"),silent=TRUE)
		if(class(temp)!="try-error"){
		  winMenuAddItem("SimDat", "New Model", "simdat('New Model')")
			winMenuAddItem("SimDat", "Open Model", "simdat('Open Model')")
			winMenuAddItem("SimDat", "Save Model", "simdat('Save Model')")
			winMenuAddItem("SimDat", "Data viewer", "simdat('Data viewer')")
			winMenuAddItem("SimDat", "SimDat Online Help", "simdat('SimDat Online Help')")
			#winMenuAdd("Data")
			#winMenuAddItem("Data", "Edit Factor", "deducer('Edit Factor')")
			#winMenuAddItem("Data", "Recode Variables", "deducer('Recode Variables')")
			#winMenuAddItem("Data", "Transform", "deducer('Transform')")
			#winMenuAddItem("Data", "Reset Row Names", "deducer('Reset Row Names')")
			#winMenuAddItem("Data", "Sort", "deducer('Sort')")
			#winMenuAddItem("Data", "Transpose", "deducer('Transpose')")			
			#winMenuAddItem("Data", "Merge", "deducer('Merge')")
			#winMenuAddItem("Data", "Subset", "deducer('Subset')")
			#winMenuAdd("Analysis")
			#winMenuAddItem("Analysis", "Frequencies", "deducer('Frequencies')")
			#winMenuAddItem("Analysis", "Descriptives", "deducer('Descriptives')")
			#winMenuAddItem("Analysis", "Contingency Tables", "deducer('Contingency Tables')")
			#winMenuAddItem("Analysis", "One Sample Test", "deducer('One Sample Test')")
			#winMenuAddItem("Analysis", "Two Sample Test", "deducer('Two Sample Test')")
			#winMenuAddItem("Analysis", "K-Sample Test", "deducer('K-Sample Test')")
			#winMenuAddItem("Analysis", "Correlation", "deducer('Correlation')")
			#winMenuAddItem("Analysis", "Linear Model", "deducer('Linear Model')")
			#winMenuAddItem("Analysis", "Logistic Model", "deducer('Logistic Model')")
			#winMenuAddItem("Analysis", "Generalized Linear Model", "deducer('Generalized Linear Model')")
			#winMenuAdd("Plots")
			#winMenuAddItem("Plots", "Open plot", "deducer('Open plot')")
			#winMenuAddItem("Plots", "Plot builder", "deducer('Plot builder')")			
			cat("\n\nSimDat has been loaded from within the Windows Rgui. 
				For the best experience, you are encouraged to use JGR console which can be
				downloaded from: http://jgr.markushelbig.org/\n")
			.windowsGUI <- TRUE
		}
	}else if(!.jgr || !.jcall("simdat/SimDat", "Z", "isJGR") )
		cat("\n\nNote Non-JGR console detected:\n\tSimDat is best used from within JGR (http://rforge.net/JGR/).
						\tTo Bring up GUI dialogs, type simdat().\n")
	##sort of
	assign(".jgr.works", TRUE, as.environment(match("package:JGR", search())))
	assign(".jgr",.jgr,de)
	assign(".windowsGUI",.windowsGUI,de)
	sidat.addMenu("File")
	#simdat.addMenu("Data")
	#deducer.addMenu("Analysis")
	#deducer.addMenu("Plots")
	simdat.addMenu("Help")
	populate.items<-function(ch,cmds,men){
		for(i in 1:length(ch)){
			if(.jgr)
				cmd<-paste(".jcall('simdat/SimDat',,'runCmdThreaded','" , cmds[i],"')",sep="")
			else
				cmd<-paste(".jcall('simdat/SimDat',,'runCmd','" , cmds[i],"',TRUE)",sep="")
			simdat.addMenuItem(ch[i],,cmd,men)
		}
	}
		
	file.choices<-c("Open Model", "Save Model","SimDat Viewer")
	file.cmds<-c("Open Data Set", "Save Data Set","table")
	populate.items(file.choices,file.cmds,"File")

	
	#analysis.choices<-c("Frequencies","Descriptives",
	#			"Contingency Tables","One Sample Test","Two Sample Test",
	#			"K-Sample Test", "Correlation", "Linear Model", 
	#			"Logistic Model","Generalized Linear Model")
	#analysis.cmds<-c("frequency","descriptives","contingency","onesample",
	#		"two sample","ksample","corr","linear", "logistic","glm")
	#populate.items(analysis.choices,analysis.cmds,"Analysis")
	
	#data.choices<-c("Edit Factor","Recode Variables","Transform",
	#		"Reset Row Names","Sort","Transpose","Merge",
	#		"Subset")
	#data.cmds<-c("factor","recode","transform","reset rows","sort","trans","merge","subset")
	#populate.items(data.choices,data.cmds,"Data")
	
	#plot.choices<-c("Open plot","Plot builder")
	#plot.cmds<-c("Open plot", "plotbuilder")
	#populate.items(plot.choices,plot.cmds,"Plots")
	
	help.choices<-c("SimDat Online Help")
	help.cmds<-c("dhelp")
	populate.items(help.choices,help.cmds,"Help")
	
	.assign.classnames()
	
	#.registerDialog("Interactive Scatter Plot", .makeIplotDialog)
	#.registerDialog("Interactive Histogram", .makeIhistDialog)
	#.registerDialog("Interactive Bar Plot", .makeIbarDialog)
	#.registerDialog("Interactive Box Plot Long", .makeIboxLongDialog)
	#.registerDialog("Interactive Box Plot Wide", .makeIboxWideDialog)
	#.registerDialog("Interactive Mosaic Plot", .makeImosaicDialog)
	#.registerDialog("Interactive Parallel Coordinate Plot", .makeIpcpDialog)
	
	if(J("simdat.toolkit.SimDatPrefs")$USEQUAQUACHOOSER && Sys.info()[1]=="Darwin")
		.jChooserMacLAF()
	
}

.Last.lib <- function(libpath){
	de <- as.environment(match("package:simdat-gui", search()))
	if(exists(".simdat") && exists(".simdat.loaded") && .simdat.loaded){
		try(.jcall(.simdat,"V","detach",silent=TRUE),silent=TRUE)
		rm(".simdat",pos=de)
		rm(".simdat.loaded",pos=de)
	}
}

simdat<-(function(){
	lastItem<-NULL
	simdat<-function(cmd=NULL){
		if(!.jfield("simdat/SimDat","Z","started")){
			.jcall(.simdat,,"startNoJGR")
		}
		oldDevice<-getOption("device")
		options(device="JavaGD")
		
		menus<- simdat.getMenus()
		menuNames <- names(menus)
		
		if(!is.null(cmd)){
			for(m in menus){
				for(item in m$items){
					if(item$name == cmd){
						if(item$silent==TRUE){
							eval(parse(text=item$command),globalenv())
						}else{
							.simdatExecute(item$command)
						}
						lastItem<<-item
						options(device=oldDevice)
						return(invisible(NULL))
					}
				}
			}
			stop("Command not present in menus")
		}
		menuChoices<-menuNames
		if(!is.null(lastItem)){
			menuChoices <- c(menuChoices,paste("Last:",lastItem$name))
		}
		menuChoices <- c(menuChoices,"exit")
		m<-menu(menuChoices,,"SimDat")
		if(m == length(menuChoices)){
			options(device=oldDevice)
			return(invisible(NULL))
		}
		if(m == length(menuChoices)-1 && !is.null(lastItem)){
			item<-lastItem
			if(item$silent==TRUE){
				eval(parse(text=item$command),globalenv())
			}else{
				.deducerExecute(item$command)
			}
			options(device=oldDevice)
			return(invisible(NULL))
		}
		men <- menus[[m]]$items
		
		itemChoices<- c(sapply(men,function(x)x$name),"back")
		
		i <- menu(itemChoices,,names(menus)[m])
		if(i == length(itemChoices) || i<=0){
			options(device=oldDevice)
			deducer()
			return(invisible(NULL))
		}
		item <- men[[i]]
		lastItem<<-item
		if(item$silent==TRUE){
			eval(parse(text=item$command),globalenv())
		}else{
			.deducerExecute(item$command)
		}
		options(device=oldDevice)
		return(invisible(NULL))
	}
	deducer
})()


simdat.viewer<-function(){
	simdat("SimDat Viewer")
}









