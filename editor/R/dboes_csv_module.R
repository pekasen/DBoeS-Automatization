dboes_csv_module_ui <- function(id) {
  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(
        width = 3,
        h1("Änderungen", align = 'center'),
        p("Hier werden Änderungen in den automatisch erfassten Daten angezeigt"),
        selectInput("csv_file_old", "Alte CSV-Datei", auto_csv_dates),
        selectInput("csv_file_new", "Neue CSV-Datei", auto_csv_dates, selected = tail(auto_csv_dates, 1))
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


dboes_csv_module <- function(input, output, session, csv_file_old, csv_file_new) {
  
  entities <- reticulate::import_from_path("scraper.entities", path = "..")
  
  output$csvComparisonOutput <- renderUI({
    
    tables <- list()
    
    for (csv_file_category in auto_csv_categories) {
      
      old_parliament <- entities$EntityGroup(paste0('../output/parliaments/', csv_file_old, '/', csv_file_category)) 
      new_parliament <- entities$EntityGroup(paste0('../output/parliaments/', csv_file_new, '/', csv_file_category)) 
      
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