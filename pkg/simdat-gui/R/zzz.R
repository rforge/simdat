# adapted from similar functions in Deducer

.registerDialog <- function(name,generator){
	de <- as.environment(match("package:simdat.gui", search()))
	if(!exists(".dialogGenerators",envir=de))
		assign(".dialogGenerators",  list(), envir=de)
	dg <- get(".dialogGenerators",envir=de)
	dg[[name]] <- generator
	assign(".dialogGenerators",  dg, envir=de)
}

.getDialog <- function(name,newInstance=FALSE){
	de <- as.environment(match("package:simdat.gui", search()))
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

.simdatExecute <- function(cmd){
    cmds<-parse(text=cmd)
    for(i in 1:length(cmds)){
        #out<-eval(parse(text=paste("capture.output(",as.character(cmds[i]),")")),globalenv())
        out <- eval(parse(text=paste("capture.output(",as.character(cmds[i]),")")),parent.env())
        for(line in out)
            cat(line,"\n")
    }
}

.jChooserMacLAF<-function(){

	if(Sys.info()[1]!="Darwin") stop("Silly rabbit, Mac Look And Feel is only for Macs!")
	
	.jaddClassPath("./System/Library/Java")
	.jaddLibrary("quaqua",system.file("java/quaqua","libquaqua.jnilib",package="simdat.gui"))
	.jaddLibrary("quaqua64",system.file("java/quaqua","libquaqua64.jnilib",package="simdat.gui"))
	.jpackage("simdat.gui","quaqua.jar")
	
	HashSet <- J("java.util.HashSet")
	QuaquaManager <- J("ch.randelshofer.quaqua.QuaquaManager")
	
	excludes <- new(HashSet)
	excludes$add("TitledBorder")
	excludes$add("Button")
	QuaquaManager$setExcludedUIs(excludes)
	
	J("java.lang.System")$setProperty("Quaqua.visualMargin","0,0,0,0")
	
	J("javax.swing.UIManager")$setLookAndFeel(QuaquaManager$getLookAndFeel())
}

.assign.classnames <- function() {
	de <- as.environment(match("package:simdat.gui", search()))
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
	
	de <- as.environment(match("package:simdat.gui", search()))
	
	.jgr<-exists(".jgr.works",envir=as.environment(match("package:JGR", search())))
	
	if(.jgr) .jgr <- get(".jgr.works", envir=as.environment(match("package:JGR", search())))
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
	
	.simdat <- try(.jnew("simdat/SimDat",.jgr),silent=TRUE)
	
	if(class(.simdat) %in% "try-error"){
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
			
			cat("\n\nSimDat has been loaded from within the Windows Rgui. For the best experience, you are encouraged to use JGR console which can be downloaded from: http://jgr.markushelbig.org/\n")
			.windowsGUI <- TRUE
		}
	} else if(!.jgr || !.jcall("simdat/SimDat", "Z", "isJGR")) {
		cat("\n\nNote Non-JGR console detected:\n\tSimDat is best used from within JGR (http://rforge.net/JGR/)\tTo Bring up GUI dialogs, type simdat().\n")
	}
	##sort of
	assign(".jgr.works", TRUE, as.environment(match("package:JGR", search())))
	assign(".jgr",.jgr,de)
	assign(".windowsGUI",.windowsGUI,de)
	simdat.addMenu("File")
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

	help.choices<-c("SimDat Online Help")
	help.cmds<-c("dhelp")
	populate.items(help.choices,help.cmds,"Help")
	
	.assign.classnames()
	
	if(J("simdat.toolkit.SimDatPrefs")$USEQUAQUACHOOSER && Sys.info()[1]=="Darwin") .jChooserMacLAF()
	
}

.Last.lib <- function(libpath){
	de <- as.environment(match("package:simdat.gui", search()))
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
				.simdatExecute(item$command)
			}
			options(device=oldDevice)
			return(invisible(NULL))
		}
		men <- menus[[m]]$items
		
		itemChoices<- c(sapply(men,function(x)x$name),"back")
		
		i <- menu(itemChoices,,names(menus)[m])
		if(i == length(itemChoices) || i<=0){
			options(device=oldDevice)
			simmdat()
			return(invisible(NULL))
		}
		item <- men[[i]]
		lastItem<<-item
		if(item$silent==TRUE){
			eval(parse(text=item$command),globalenv())
		}else{
			.simdatExecute(item$command)
		}
		options(device=oldDevice)
		return(invisible(NULL))
	}
	simdat
})()

simdat.viewer <- function() {
	simdat("SimDat Viewer")
}
