# adapted from similar functions in Deducer
.simdatExecute <- function(cmd){
    cmds<-parse(text=cmd)
    for(i in 1:length(cmds)){
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
	##de <- as.environment(match("package:simdat.gui", search()))
	SimDatMain <<- J("simdat.SimDat")

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

#.First.lib <- function(libname, pkgname) {

.onLoad <- function(libname, pkgname) { 

	jgrEnv <- try(as.environment(match("package:JGR", search())),silent=TRUE)
	
	assign("simdat.gui.env",new.env(),parent.frame())
	
	if(inherits(jgrEnv,"try-error")){
		packageStartupMessage("\nNamespace for JGR could not be found\n")
		.simdat <<- .jnull()
		.simdat.loaded <<- TRUE
		if(!exists(".jgr",parent.frame())) .jgr <<- FALSE
		if(!exists(".windowsGUI",parent.frame())) .windowsGUI <<- exists("winMenuAdd")	
		return(TRUE)
	}
	unlockBinding(".jgr.works", jgrEnv)
	.jgr <- exists(".jgr.works",envir=jgrEnv)
	if(.jgr)
		.jgr<-get(".jgr.works", envir=jgrEnv)
	if(!is.null(getOption("SimDatNoGUI")) && getOption("SimDatNoGUI")){
		packageStartupMessage("\nLoading SimDat without GUI. If you wish the GUI to load, run options(SimDatNoGUI=FALSE) before loading SimDat\n")
		.simdat <<- .jnull()
		.simdat.loaded <<- TRUE
		if(!exists(".jgr",parent.frame())) .jgr <<-FALSE
		if(!exists(".windowsGUI",parent.frame())) .windowsGUI <<- exists("winMenuAdd")
		return(TRUE)
	}

	if (nzchar(Sys.getenv("NOAWT")) && .jgr!=TRUE) {
		packageStartupMessage("\nNOTE: Environmental variable NOAWT set. Loading SimDat without GUI.\n")
		.simdat <<- .jnull()
		.simdat.loaded <<- TRUE
		if(!exists(".jgr",parent.frame())) .jgr <<-FALSE
		if(!exists(".windowsGUI",parent.frame())) .windowsGUI <<- exists("winMenuAdd")
		return(TRUE)	
	}
	
	jriOK <- try(.jinit(),silent=TRUE)
	if(class(jriOK) %in% "try-error"){
		packageStartupMessage("\nWarning: Problem initiating JRI. The Java GUI will not be available.\n")
		.simdat <<- .jnull()
		.simdat.loaded <<- TRUE
		if(!exists(".jgr",parent.frame())) .jgr <<-FALSE
		if(!exists(".windowsGUI",parent.frame()))  .windowsGUI <<- exists("winMenuAdd")
		return(TRUE)
	}
	
	jriOK <- try(.jengine(TRUE),silent=TRUE)
	if(class(jriOK) %in% "try-error"){
		packageStartupMessage("\nWarning: Problem initiating JRI. Make sure you built R with shared libraries The Java GUI will not be available.\n")
		.simdat <<- .jnull()
		.simdat.loaded <<- TRUE
		if(!exists(".jgr",parent.frame())) .jgr <<-FALSE
		if(!exists(".windowsGUI",parent.frame())) .windowsGUI <<- exists("winMenuAdd")
		return(TRUE)
	}
	
	.jpackage(pkgname,"simdat.jar")
	
	
	#.jpackage(pkgname)
	.jpackage("JavaGD")
	.jpackage("Deducer")
	.jpackage("JGR")
	
	#tmp <- ANOVA()

  #if(!exists(".jniInitialized") || !.jniInitialized)
  #  .jinit()
  #classes <- system.file("java", package = pkgname, lib.loc = libname)
  #classes <- system.file("java", package = pkgname)
  #.jaddClassPath(classes)
  
  #.jengine(TRUE)
  #.jaddClassPath("/home/maarten/lib/R/library/simdat.gui/java/simdat.jar")

	
	.simdat<-try(.jnew("simdat/SimDat",.jgr),silent=TRUE)
	
	if(class(.simdat) %in% "try-error"){
		packageStartupMessage("Warning: Unable to start SimDat's Java class. The Java GUI will not be available.")
		.simdat <<- .jnull()
		.simdat.loaded <<- TRUE
		if(!exists(".jgr",parent.frame())) .jgr <<-.jgr
		if(!exists(".windowsGUI",parent.frame())) .windowsGUI <<- exists("winMenuAdd")
		return(TRUE)
	}
	
	.simdat <<- .simdat
	.simdat.loaded <<- TRUE
	if(!exists(".jgr",parent.frame())) .jgr <<- .jgr
	if(!exists(".windowsGUI",parent.frame())) .windowsGUI <<- FALSE
	
	if(exists("winMenuAdd")){
		temp<-try(winMenuAdd("SimDat"),silent=TRUE)
		if(class(temp)!="try-error"){
		  winMenuAddItem("SimDat", "SimDat viewer", "simdat('SimDat viewer')")
			packageStartupMessage("\n\nSimDat has been loaded from within the Windows Rgui. 
				For the best experience, you are encouraged to use JGR console which can be
				downloaded from: http://jgr.markushelbig.org/\n")
			if(!exists(".windowsGUI",parent.frame())) .windowsGUI <<- TRUE
		}
	} else if(!.jgr || !.jcall("simdat/SimDat", "Z", "isJGR") )
		packageStartupMessage("\n\nNote Non-JGR console detected:\n\tSimDat is best used from within JGR (http://jgr.markushelbig.org/).
						\tTo Bring up GUI dialogs, type simdat().\n")
	##sort of
	assign(".jgr.works", TRUE, jgrEnv)
	#simdat.addMenu("SimDat")
	#populate.items<-function(ch,cmds,men){
	#	for(i in 1:length(ch)){
	#		if(.jgr)
	#			cmd<-paste(".jcall('simdat/SimDat',,'runCmdThreaded','" , cmds[i],"')",sep="")
	#		else
	#			cmd<-paste(".jcall('simdat/SimDat',,'runCmd','" , cmds[i],"',TRUE)",sep="")
	#		simdat.addMenuItem(ch[i],,cmd,men)
	#	}
	#}
		
	#file.choices<-c("SimDat Viewer")
	#file.cmds<-c("table")
	#populate.items(file.choices,file.cmds,"File")

	#help.choices<-c("SimDat Online Help")
	#help.cmds<-c("sdhelp")
	#populate.items(help.choices,help.cmds,"Help")
	
	#.dialogGenerators <<- list()
	#.dialogs <<- list()
	
	#.assign.classnames()

	
	#if(J("simdat.toolkit.SimDatPrefs")$USEQUAQUACHOOSER && Sys.info()[1]=="Darwin")
	#	.jChooserMacLAF()
	
}

.onUnload <- function(libpath){
	#de <- as.environment(match("package:Deducer", search()))
	if(exists(".simdat") && exists(".simdat.loaded") && .simdat.loaded){
		try(.jcall(.simdat,"V","detach",silent=TRUE),silent=TRUE)
		#rm(".deducer",pos=de)
		#rm(".deducer.loaded",pos=de)
	}
}

simdat<-(function(){
	lastItem<-NULL
	simdat<-function(cmd=NULL){
	
	  assign("simdat.gui.env",new.env(),parent.frame())
	  assign("tmp",ANOVA(),parent.frame()$simdat.gui.env)
		
		if(!.jfield("simdat/SimDat","Z","started")){
			.jcall(.simdat,,"startNoJGR")
		}
		#.jcall(.simdat,,"startNoJGR")
    #assign("tmp",ANOVA(),simdat.gui.env)
		
		oldDevice<-getOption("device")
		options(device="JavaGD")
		
		menus<- simdat.getMenus()
		menuNames <- names(menus)
		
		
    .jcall(.simdat,,"refreshModels")
    .jcall(.simdat,,"startViewerAndWait")
    
    return()
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
			simdat()
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
