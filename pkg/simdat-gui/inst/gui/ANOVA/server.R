library(shiny)
library(ggplot2)
library(simdat.base)

defaults <- list(nLevel=2,N=10,mu=0,sigma=1)

shinyServer(function(input, output) {
  
  DVmin <- reactive({
    if(input$hasMin) {
      return(input$minimum)
    } else {
      return(-Inf)
    }
  })
  
  DVmax <- reactive({
    if(input$hasMax) {
      return(input$maximum)
    } else {
      return(Inf)
    }
  })
    
  design <- reactive({
    # factorial design
    factors <- list()
    for(i in 1:input$nFactor) {
      nLevel <- input[[paste("factor",i,"levels",sep="")]]
      if(!is.null(nLevel)) {
        factors[[i]] <- paste(LETTERS[i],1:nLevel,sep="")
      } else {
        factors[[i]] <- paste(LETTERS[i],1:defaults$nLevel,sep="")
      }
    }
    des <- expand.grid(factors)
    colnames(des) <- LETTERS[1:input$nFactor]
    return(des)
  })
   
  N <- reactive({
    n <- rep(NA,length=nrow(design()))
    if(length(n) > 0) {
        for(i in 1:length(n)) {
          tn <- input[[paste("N",i,sep="")]]
          if(!is.null(tn)) {
            n[i] <- tn
          } else {
            n[i] <- defaults$N
          }
        }
    }
    return(n)
  })
  
  mu <- reactive({
    n <- rep(NA,length=nrow(design()))
    if(length(n) > 0) {
        for(i in 1:length(n)) {
          tn <- input[[paste("mean",i,sep="")]]
          if(!is.null(tn)) {
            n[i] <- tn
          } else {
            n[i] <- defaults$mu
          }
        }
    }
    return(n)
  })
  
  sigma <- reactive({
    n <- rep(NA,length=nrow(design()))
    if(length(n) > 0) {
        for(i in 1:length(n)) {
          tn <- input[[paste("sd",i,sep="")]]
          if(!is.null(tn)) {
            n[i] <- tn
          } else {
            n[i] <- defaults$sigma
          }
        }
    }
    return(n)
  })
  
  mod <- reactive({
    DV <- list(name="Y",min=DVmin(),max=DVmax(),digits=input$digits)
    mod <- ANOVA(DV=DV,design=design(),N=N(),mu=mu(),sigma=sigma(),family=NO())
  })
  
  data <- reactive({
    getData(mod())
  })
  
  output$factorLevels <- renderUI({
    out <- list()
    for(i in 1:input$nFactor) {
      out[[i]] <- numericInput(paste("factor",i,"levels",sep=""), paste("number of levels for Factor",LETTERS[i]),value=2,min=1,max=10,step=1)
    }
    return(out)
  })
  
  output$parametersNew <- renderUI({
    factors <- list()
    for(i in 1:input$nFactor) {
      factors[[i]] <- paste(LETTERS[i],1:input[[paste("factor",i,"levels",sep="")]])
    }
    combs <- expand.grid(factors)
    pars <- cbind(combs,data.frame(N=10,mean=0,sd=1))
    colnames(pars) <- c(LETTERS[1:input$nFactor],"N","mean","sd")
    return(matrixInput("parameters","Set parameters",pars))
  })
  
  output$parameters <- renderUI({
    out <- list()
    out[[1]] <- HTML(paste("<table><tr>",paste("<th>",LETTERS[1:input$nFactor],"</th>",sep="",collapse=""),"<th>N</th><th>mean</ht><th>sd</th></tr>",collapse=""))
    j <- 2
    for(i in 1:nrow(design())) {
      # set labels for factor combinations
      out[[j]] <- HTML(paste("<tr>",paste("<td>",as.character(apply(as.matrix(design()[i,]),2,as.character)),"</td>",sep="",collapse="")))
      j <- j + 1
      # set inputs
      out[[j]] <- HTML("<td>")
      j <- j+1
      out[[j]] <- numericInput(paste("N",i,sep=""),"",value=defaults$N,min=1,max=Inf,step=1)
      j <- j+1
      out[[j]] <- HTML("</td>")
      j <- j+1
      out[[j]] <- HTML("<td>")
      j <- j+1
      out[[j]] <- numericInput(paste("mean",i,sep=""),"",value=defaults$mu)
      j <- j+1
      out[[j]] <- HTML("</td>")
      j <- j+1
      out[[j]] <- HTML("<td>")
      j <- j+1
      out[[j]] <- numericInput(paste("sd",i,sep=""),"",value=defaults$sigma,min=.000001,max=Inf)
      j <- j+1
      out[[j]] <- HTML("</td>")
      j <- j+1
      # close the table row
      out[[j]] <- HTML("</tr>")
      j <- j + 1
    }
    # close table
    out[[j]] <- HTML("</table>")
    return(out)
  })
  
  output$dataTable <- renderTable({
    data()
  },digits=input$digits)
  
  output$summary <- renderPrint({
    print(summary(mod()))
  })
  
  output$downloadData <- downloadHandler(
    filename = function() { "simdat.csv" },
    content = function(file) {
      write.csv(data(), file, row.names=FALSE)
    }
  )
})
