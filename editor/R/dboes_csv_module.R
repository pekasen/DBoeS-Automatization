dboes_csv_module_ui <- function(id) {
  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(
        width = 3,
        h1("Änderungen", align = 'center'),
        p("Hier werden Änderungen in den automatisch erfassten Daten angezeigt"),
        selectInput(ns("csv_file_old"), "Alte CSV-Datei", auto_csv_dates),
        selectInput(ns("csv_file_new"), "Neue CSV-Datei", auto_csv_dates, selected = tail(auto_csv_dates, 1)),
        hr(),
        actionButton(inputId = ns("fetchdata"), "Neue Daten laden", icon = icon("download"), style="margin-bottom:15px"),
        textOutput(ns("pythonoutput")) %>% withSpinner(),
        tags$style(type="text/css", "#dboes_csv-pythonoutput {white-space: pre-wrap;}")
      ),
      mainPanel(
        fluidRow(
          width = 9,
          uiOutput(ns("csvComparisonOutput")) %>% withSpinner()
        )
      )
    )
  )
}


dboes_csv_module <- function(input, output, session) {
  
  entities_module <- reticulate::import_from_path("scraper.entities", path = "..")
  fetcher_module <- reticulate::import_from_path("scraper.wiki_fetcher", path = "..")
  
  pythonlog <- eventReactive(input$fetchdata, {
    
    # get data
    fetcher <- fetcher_module$WikiFetcher()
    
    # update selection
    today <- format(Sys.Date(), "%Y-%m-%d")
    updateSelectInput(session, "csv_file_new",
                      choices = today,
                      selected = today
    )
    
    # get log output
    reticulate::py_capture_output(fetcher$fetch_all_parliaments(output_basedir = ".."))
  })
  
  output$pythonoutput <- renderText({pythonlog()})
  
  output$csvComparisonOutput <- renderUI({
    
    tables <- list()
    
    for (csv_file_category in auto_csv_categories) {
      
      old_parliament <- entities_module$EntityGroup(paste0('../output/parliaments/', input$csv_file_old, '/', csv_file_category)) 
      new_parliament <- entities_module$EntityGroup(paste0('../output/parliaments/', input$csv_file_new, '/', csv_file_category)) 
      
      parl_diff <- old_parliament$compare(new_parliament) %>%
        select(-starts_with("id_")) %>%
        arrange("Name", desc("old/new"))
      
      if (nrow(parl_diff) > 0) {
        
        tables[[csv_file_category]] <- paste0(
          "<h3>", csv_file_category, "</h3>\n",
          kbl(parl_diff) %>%
            kable_styling(bootstrap_options = c("striped", "hover")) %>%
            row_spec(which(parl_diff[, "old/new"] == "old"), color = "red")
        )
        
      }
      
    }
    
    out <- paste(tables, collapse="\n<hr>\n")
    return(div(HTML(out), class="shiny-html-output"))
    
  })
}