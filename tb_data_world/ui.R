#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#




library(shiny)
library(plotly)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  tags$style('.container-fluid {
                             background-color: #EEE9E9
              }'),
  
  fluidRow(column(12,align ="center",
                  div(img(src="https://cdn2.vectorstock.com/i/thumb-large/83/06/tuberculosis-black-glyph-icon-contagious-vector-39918306.jpg", height=80, width=110))),
           
           fluidRow(column(12, align = 'center', 
                           div(style = "font-size: 10px; padding: 0px 0px; margin-top:-2em"),
                           titlePanel(windowTitle = 'TB Dat Comparison',
                                      title = "TB data analysis"))
           )
  ),
  
  # Application title
  titlePanel(h4("Comparison of Tuberculosis Estiamated and Reported Cases by Countries", align="center")),
  
  sidebarLayout(
    
    sidebarPanel(
      uiOutput("conlist"),
      uiOutput("yearlist")),
    
    mainPanel(
      tabsetPanel(type = "tabs",
      tabPanel("Line List", br(), dataTableOutput("table")),
      tabPanel("Graph", br(), plotlyOutput(outputId = "plot"),
               h5("% at bottom is the differences between estimated cases (dots) vs. reported (line)", align="center"),
               h6("Source: https://www.who.int/teams/global-tuberculosis-programme/data#csv_files", align="center")))))))
