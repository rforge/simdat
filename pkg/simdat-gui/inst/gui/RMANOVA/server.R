library(shiny)
library(ggplot2)
library(simdat.base)

defaults <- list(nLevel=2,N=10,mu=0,sigma=1,rho=0.1)

# Define server logic required to plot various variables against mpg
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
    
  betweenDesign <- reactive({
    if(input$nBetweenFactor > 0) {
    # factorial design
    factors <- list()
    for(i in 1:input$nBetweenFactor) {
      nLevel <- input[[paste("betweenfactor",i,"levels",sep="")]]
      if(!is.null(nLevel)) {
        factors[[i]] <- paste("b",LETTERS[i],1:nLevel,sep="")
      } else {
        factors[[i]] <- paste("b",LETTERS[i],1:defaults$nLevel,sep="")
      }
    }
    des <- expand.grid(factors)
    colnames(des) <- paste("b",LETTERS[1:input$nBetweenFactor],sep="")
    return(des)
    } else {
        return(NULL)
    }
  })
  
  nBetweenCells <- reactive({
    if(input$nBetweenFactor > 0) {
        return(nrow(betweenDesign()))
    } else {
        return(1)
    }
  })
  
  nWithinCells <- reactive({
    nrow(withinDesign())
  })

  withinDesign <- reactive({
    # factorial design
    factors <- list()
    for(i in 1:input$nWithinFactor) {
      nLevel <- input[[paste("withinfactor",i,"levels",sep="")]]
      if(!is.null(nLevel)) {
        factors[[i]] <- paste("w",LETTERS[i],1:nLevel,sep="")
      } else {
        factors[[i]] <- paste("w",LETTERS[i],1:defaults$nLevel,sep="")
      }
    }
    des <- expand.grid(factors)
    colnames(des) <- paste("w",LETTERS[1:input$nWithinFactor],sep="")
    return(des)
  })
  
  N <- reactive({
    n <- rep(NA,length=nBetweenCells())
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
    n <- rep(NA,length=nBetweenCells()*nWithinCells())
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
    n <- matrix(n,nrow=nBetweenCells())
    return(n)
  })
  
  sigma <- reactive({
    n <- rep(NA,length=nBetweenCells())
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
  
  rho <- reactive({
    n <- rep(NA,length=nWithinCells())
    if(length(n) > 0) {
        for(i in 1:length(n)) {
          tn <- input[[paste("rho",i,sep="")]]
          if(!is.null(tn)) {
            n[i] <- tn
          } else {
            n[i] <- defaults$rho
          }
        }
    }
    return(n)
  })
  
  mod <- reactive({
    DV <- list(name="Y",min=DVmin(),max=DVmax(),digits=input$digits)
    #rmANOVA(DV,family=NO(),between,within,N,mu,bsigma,wsigma,nu,tau,id.name="ID",display.direction=c("wide","long"))
    wsigma <- rho()
    if(input$nBetweenFactor > 0) {
        mod <- rmANOVA(DV=DV,between=betweenDesign(),within=withinDesign(),N=N(),mu=mu(),bsigma=sigma(),wsigma=wsigma,family=NO())
    } else {
        mod <- rmANOVA(DV=DV,within=withinDesign(),N=N(),mu=mu(),bsigma=sigma(),wsigma=wsigma,family=NO())
    }
    mod
  })
  
  data <- reactive({
    getData(mod())
  })
  
  output$betweenFactorLevels <- renderUI({
    if(input$nBetweenFactor > 0) {
        out <- list()
        for(i in 1:input$nBetweenFactor) {
          out[[i]] <- numericInput(paste("betweenfactor",i,"levels",sep=""), paste("number of levels for Factor b",LETTERS[i],sep=""),value=2,min=1,max=10,step=1)
        }
        return(out)
    } else {
        return(NULL)
    }
  })
  
  output$withinFactorLevels <- renderUI({
    out <- list()
    for(i in 1:input$nWithinFactor) {
      out[[i]] <- numericInput(paste("withinfactor",i,"levels",sep=""), paste("number of levels for Factor w",LETTERS[i],sep=""),value=2,min=1,max=10,step=1)
    }
    return(out)
  })
  
  
  output$parameters <- renderUI({
    if(input$nBetweenFactor > 0) bDesign <- betweenDesign()
    wDesign <- withinDesign()
    wCombinations <- apply(wDesign,1,function(x) paste(as.character(x),collapse="."))
    out <- list()
    j <- 1
    out[[j]] <- HTML(paste("<h2>Means and between-subjects parameters</h2><table><tr>",ifelse(input$nBetweenFactor > 0,paste("<th>",colnames(bDesign),"</th>",sep="",collapse=""),""),"<th>N</th>",paste("<th>mean ",wCombinations,"</th>",sep="",collapse=""),"<th>sd</th></tr>",collapse=""))
    j <- j+1
    if(input$nBetweenFactor > 0) {
        for(i in 1:nrow(bDesign)) {
          # set labels for factor combinations
          out[[j]] <- HTML(paste("<tr>",paste("<td>",as.character(apply(as.matrix(bDesign[i,]),2,as.character)),"</td>",sep="",collapse="")))
          j <- j + 1
          # set inputs
          out[[j]] <- HTML("<td>")
          j <- j+1
          out[[j]] <- numericInput(paste("N",i,sep=""),"",value=defaults$N,min=1,max=Inf,step=1)
          j <- j+1
          out[[j]] <- HTML("</td>")
          j <- j+1
          for(k in 1:nrow(wDesign)) {
            out[[j]] <- HTML("<td>")
            j <- j+1
            out[[j]] <- numericInput(paste("mean",i+(k-1)*nrow(bDesign),sep=""),"",value=defaults$mu)
            j <- j+1
            out[[j]] <- HTML("</td>")
            j <- j+1
          }
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
    } else {
        i <- 1
          out[[j]] <- HTML("<tr>")
          j <- j + 1
          # set inputs
          out[[j]] <- HTML("<td>")
          j <- j+1
          out[[j]] <- numericInput(paste("N",i,sep=""),"",value=defaults$N,min=1,max=Inf,step=1)
          j <- j+1
          out[[j]] <- HTML("</td>")
          j <- j+1
          for(k in 1:nrow(wDesign)) {
            out[[j]] <- HTML("<td>")
            j <- j+1
            out[[j]] <- numericInput(paste("mean",k,sep=""),"",value=defaults$mu)
            j <- j+1
            out[[j]] <- HTML("</td>")
            j <- j+1
          }
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
    j <- j + 1
    out[[j]] <- HTML(paste("<h2>Within-subjects parameters</h2><table><tr>",paste("<th>",colnames(wDesign),"</th>",sep="",collapse=""),"<th>error sd</th></tr>",collapse=""))
    j <- j + 1
    for(i in 1:nrow(wDesign)) {
      # set labels for factor combinations
      out[[j]] <- HTML(paste("<tr>",paste("<td>",as.character(apply(as.matrix(wDesign[i,]),2,as.character)),"</td>",sep="",collapse="")))
      j <- j + 1
      # set inputs
      out[[j]] <- HTML("<td>")
      j <- j+1
      out[[j]] <- numericInput(paste("rho",i,sep=""),"",value=defaults$rho,min=0,max=1,step=.001)
      j <- j+1
      out[[j]] <- HTML("</td>")
      j <- j+1
      # close the table row
      out[[j]] <- HTML("</tr>")
      j <- j + 1
    }
    # close table
    out[[j]] <- HTML("</table>")
    #cat(as.character(unlist(out)))

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
