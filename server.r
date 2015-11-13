library(e1071)
library(cluster)
set.seed(123)
shinyServer(function(input, output) {
  
  library("RPostgreSQL")
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, host='localhost', port='5432', dbname='TESTDB',
                   user='postgres', password='root')
  rk <- dbSendQuery(con,"select * from persons")
  rs<-fetch(rk)
  
  radioValues <- reactive({
    gender <- input$gender
    if (gender==1){
      rs[rs$gender=="male",]
    } else if (gender==2){
      rs[rs$gender=="female",]
    } else if (gender==3){
      rs
    }
    
    
    
  })
  
  selectedData <- reactive({
    radioValues()[,input$show_vars, drop = FALSE]
    
  })
  
  
  membership<- reactive({
    input$member
    
  })
  
  interations<- reactive({
    input$iter
  })
  
  sliderValues <- reactive({
   radioValues()
   n<-input$n
   rs.cl<- fanny(selectedData(),input$n,diss=FALSE,memb.exp=membership()
                 ,metric = input$dist,stand=FALSE,maxit=interations() )
   rs.cl
 
   })
      
  output$mytable = renderDataTable({
    radioValues()
  })
  
  
  output$result <- renderDataTable({
    rs.cl<-sliderValues()
    groups <- as.factor(rs.cl$cluster)
    rs2<-cbind(radioValues()[,c(-4,-5,-6,-7,-8)],groups)  
  })
  
  output$summary <- renderPrint({
   c(sliderValues()[c(2,3,5,7)],
    table(sliderValues()[4]))
  })
  
 labelsButton<-reactive({
   if(input$show_vars2=="None"){
     text(selectedData(),label=NULL)
   }
   else if(input$show_vars2=="gender"){
     text(selectedData(),label=radioValues()[,2])
   }
   else if(input$show_vars2=="id"){
     text(selectedData(),label=radioValues()[,1])
   }
   else if(input$show_vars2=="Cluster"){
     text(selectedData(),label=sliderValues()$cluster)
   }
     
 })
  
  
  output$plot1 <- renderPlot({
    par(mar = c(10.1, 5.1, 0, 1.0))
    clust2<-sliderValues()
    plot(selectedData(),
         col = clust2$cluster,
         pch = 20, cex =3)
    points(clust2$centers, pch = 4, cex = 4, lwd = 4)
    labelsButton()
 
    
  })
  
  
  
  
  dbDisconnect(con)  
}

)