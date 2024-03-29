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
source("001_data_processing_dec.R")
source("002_recode.R")

# create survey object
svy <- svydesign(ids=~1, weights = ~weight, data = df)



# create list of demo 
demo_list <- c("asianorigin_l", "income4_l", "region4_l", "coo_l", "internet_l", "lang_athome_l", "age4_l")

# create a list of independent variables
ind_vars <- c("q1a", "q1e", "q1b", "q1c", "q6", "q7a", "q7b", "q7c", "q7d", "q7e","q8a", "q8b", "q8c", "q9a","q9b", "q9c", "q9d")
ind_qs <- c("At home, I tend to eat foods from my culture", "Food from my culture are generally healthier than American food", "I trust my doctor, or other health professionals, for information on healthy eating", "When I am feeling ill, I will eat specific food ingredients to get healthy", "I believe food is healing/good for my body", "Providing more nutrition counseling to patients", "Teaching patients to cook", "Helping pay for healthier food in grocery stores, supermarkets, and/or farmers' markets for patients with appropriate medical conditions", "Having on-site food grocery or pantry pick-up locations for healthier food for patients with appropriate medical conditions", "Helping to pay for delivery of healthy groceries or meals to homes of patients with appropriate medical conditions", "I have heard of Medically tailored meals", "I have heard of Medically tailored groceries", "I have heard of Produce prescription programs", "If offered to me, I would participate in regular nutrition counseling and/or cooking education around eating a healthy diet", "If offered to me, I would participate in Medically tailored meals", "If offered to me, I would participate in Medically tailored groceries", "If offered to me, I would participate in Produce prescription programs" )
questions <- data.frame(ind_vars, ind_qs)

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Relationship between demographic group and cultural food affinity and FIM"),
  titlePanel(h3(textOutput("question"))),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      radioButtons("demo", "Select demographic of interest", choices = demo_list),
      radioButtons("ind_var", "Select independent variable", choices = c(ind_vars, "high_cfa", "high_fim_vals"))
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
  
  # Output question --------------------------------------------------------------
  output$question <- reactive({
    questions |> filter(ind_vars == input$ind_var) |> pull(ind_qs)
  })
  
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
      group_by(.data[[demo]]) |>
      mutate(proportional_count = count / sum(count))
     # pivot_wider(names_from = .data[[demo]], values_from = proportional_count, values_fill = 0)
    
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
  

} # end server

# Run the application 
shinyApp(ui = ui, server = server)