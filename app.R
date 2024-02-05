#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(haven)
library(janitor)
library(expss)
library(survey)
library(DT)


# Read in data -------------------------------------------------------------------
source("001_data_processing.R")
source("002_recode.R")

# create survey object
svy <- svydesign(ids=~1, weights = ~weight, data = df)



# create list of demo 
demo_list <- c("asianorigin_l", "income4_l", "region4_l", "snap", "internet_l", "lang_athome_l", "age4_l")

# create a list of independent variables
ind_vars <- c("fs", "ns")

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Relationship between demographic group and food security"),
    titlePanel(h3("22% of the AANHPI population face low food security and 20% face low nutrition security.")),
    titlePanel(h3("Of those who face low food security, 60% also face low nutrition security.")),
    p("There is a significant result between food security and asian origin, income, region, SNAP access, and language at home."),
    p("There is a significant result between nutrition security and asian origin, income, SNAP access, language at home, and age."),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
          radioButtons("demo", "Select demographic of interest", choices = demo_list),
          radioButtons("ind_var", "Select independent variable", choices = c("food security" = "fs", "nutrition security" = "ns", "hard_to_get", "expensive","lack_of_choices","hard_to_reach","lack_of_transport"))
        ),

        # Show a plot of the generated distribution
        mainPanel(
          textOutput("chi_results"),
          plotOutput("bar_plot"),
          h3("Weighted breakdown by demographic group"),
          DTOutput("svy_dt"),
          h3("Count totals"),
          DTOutput("demo_dt")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # Conducting chi square tests --------------------------------------------------
  
  # Function for chisquare
  chisq_fx <- function(demo, ind_var){
    
    chisq <- chisq.test(table(df[[input$demo]], df[[input$ind_var]]))
    sig <- if_else(chisq$p.value <0.05, "a significant", "not a significant")
    #print(chisq)
    print(paste("There is", sig, "result between", input$demo, "and", input$ind_var, "with a p-value of", format.pval(chisq$p.value, eps=0.0001)))
  }
  
  # Run chi square test
  output$chi_results <- renderText(print(chisq_fx(input$demo, input$ind_var)))
  
  # Getting raw counts for observerations -----------------------------------------
  
  # write function for raw counts
  table_fx <- function(demo, ind_var) {
    df |>
    group_by(.data[[ind_var]], .data[[demo]]) |> 
    summarise(count = n())  |>
    group_by(.data[[demo]]) 
    #filter(.data[[ind_var]] == "low") |>
    #select(-.data[[ind_var]])
    #pivot_wider(names_from = .data[[demo]], values_from = count)
  }
  
  # create demo table
  demo_table <- reactive({table_fx(input$demo, input$ind_var)})
  
  # render data table output
  output$demo_dt<- renderDT(demo_table(), options=list( info = FALSE, paging = F, searching = F))
  
  # Creating survey objects to use weights  -----------------------------------------
  
  # write function for generating survey objects
  svy_fx <- function(demo, ind_var){
    svy_object <- svyby(
      formula = as.formula(paste0("~", ind_var)),
      by = as.formula(paste0("~", demo)),
      design = svy,
      FUN = svymean
    ) |> as_tibble()
    
  }
  
 # create survey object
  svy_object <- reactive({
    svy_fx(input$demo, input$ind_var)
  })
  
  # Create bar plot for survey objects  -----------------------------------------
  
  # write function for generating plots
  plot_fx <- function(demo, ind_var){
   # fsns <- ifelse(ind_var == "fs", "fslow", "nslow")
    var_y <- if(ind_var == "fs") {"fslow"} else if (ind_var == "ns") {"nslow"} else {ind_var}
    ggplot(svy_object(), aes(x=.data[[demo]], y = .data[[var_y]], fill =  '#00BFC4')) + 
      geom_bar(stat="identity", show.legend=F) 
  }
  
  # render plot for survey object
  output$bar_plot <- renderPlot({
    plot_fx(input$demo, input$ind_var)
  })
  
  # render table for survey object
  output$svy_dt <- renderDT({
    svy_object() |> mutate(across(where(is.numeric), round, 3))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
