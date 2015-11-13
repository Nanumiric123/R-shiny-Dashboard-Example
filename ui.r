library(shiny)
palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
          "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))

library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='TESTDB',
                 user='postgres', password='root')
rk <- dbSendQuery(con,"select * from persons")
rs<-fetch(rk)

shinyUI(fluidPage(
  theme="bootstrap.css",
  titlePanel(h1("Clustering Dashboard",style='font-family:"Times New Roman", Times, serif'),windowTitle="Big-5 Dashboard"),
  sidebarPanel(
    checkboxGroupInput('show_vars', 'Select Big 5 features',names(rs)[c(-1,-2)], selected = names(rs)[c(-1,-2,-3,-9)]),
    
    radioButtons("gender","split gender",
                 c("Male" = 1,
                   "Female" = 2,
                 "Mix"=3),selected=3),

    sliderInput("n", 
                "Number of Groups:", 
                value = 2,
                min = 2, 
                max = 30),
    selectInput('dist', 'Distance Function', c("SqEuclidean","euclidean", "manhattan")),
    
    numericInput("member", "Membership Exponent", 1.5, min = 1, max = 2.0,
                 step = 0.1),
    
    numericInput("iter", "Maximum Interations", 500, min = 500, max = 2000,step=100),
    
    selectInput('show_vars2', 'Select Lebels to the points',
                       c(names(rs)[c(1,2)],"None","Cluster"), selected = "None")
  ),
  mainPanel(
   
    tabsetPanel(
      tabPanel("Table", dataTableOutput('mytable')),
      tabPanel("Plot",plotOutput('plot1')),
      tabPanel("Clustering Summary",verbatimTextOutput("summary")),
      tabPanel("Result",dataTableOutput("result"))

     
  )
  )
)
)
dbDisconnect(con) 