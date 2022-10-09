#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)


# Get the data
df1 <- read_csv("https://extranet.who.int/tme/generateCSV.asp?ds=estimates")
df2 <- read_csv("https://extranet.who.int/tme/generateCSV.asp?ds=notifications")

df <- df1 %>% 
  left_join(df2, suffix = c("_est","_rep" ),  by=c("country", "year")) %>% 
  select(country,g_whoregion_est, year, e_inc_num, c_newinc) %>% 
  mutate(c_newinc=if_else(is.na(c_newinc),0,c_newinc),
         diff=scales::percent((c_newinc/e_inc_num)-1,1.1)) %>% 
  filter(year>=2010)


#countries

shinyServer(function(input, output) {
  
  
  output$conlist <- renderUI({
    
    conlist <- sort(unique(as.vector(df$country)), decreasing = FALSE)
    conlist <- append(conlist, "All", after =  0)
    selectizeInput("conchoose", "Country:", conlist)
    
  })
  
  
  output$yearlist <- renderUI({
    
    yearlist <- sort(unique(as.vector(df$year)), decreasing = FALSE)
    yearlist <- append(yearlist, "All", 0)
    selectizeInput("yearchoose", "year:", yearlist)
    
  }) 
  
  
  data <- reactive({
    
    req(input$conchoose)
    req(input$yearchoose)
    
    
    if(input$conchoose == "All") {
      
      filt1 <- quote(country != "@?><")
      
      
    } else {
      
      filt1 <- quote(country == input$conchoose) 
      
    }
    
    
    if (input$yearchoose == "All") {
      
      filt2 <- quote(year != "")
      
      
    } else {
      
      filt2 <- quote(year == input$yearchoose)
      
    }
    
    
    
    df %>%
      filter_(filt1) %>%
      filter_(filt2) %>% 
      rename(Country=country,
             Region=g_whoregion_est,
             Year=year,
             `Estimated cases`=e_inc_num,
             `Reported cases`=c_newinc,
             `Difference Estimated vs. reported`=diff)
    
  })
  
  
  output$table <- renderDataTable({
    
    data()

    
  })

  output$plot <- renderPlotly({
    ggplotly({
      p <- ggplot(data(), aes_string(color="Region")) + 
        geom_point(aes_string(x="factor(Year)", y="`Estimated cases`"), alpha = 0.5) + 
        geom_line(aes_string(x="factor(Year)", y="`Reported cases`", group="Region"), alpha = 0.5) +
        geom_text(aes_string(x="factor(Year)", y=0,
                             label="`Difference Estimated vs. reported`"),
                  check_overlap = T, size=2,
                  nudge_y = 2) + 
        scale_y_continuous(label=scales::comma, limits = c(0,NA))+
        theme(legend.position = "bottom") +
        theme_minimal()+
        labs(x="Years",
             y="Number of cases",
             color="Region")
      
      p
    
  
    })
    
  })
})

