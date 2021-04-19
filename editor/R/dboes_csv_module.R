dboes_csv_module_ui <- function(id) {
  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(
        width = 3,
        h1("Änderungen", align = 'center'),
        p("Hier werden Änderungen in den automatisch erfassten Daten angezeigt"),
        selectInput("csv_file_old", "Alte CSV-Datei", auto_csv_dates),
        selectInput("csv_file_new", "Neue CSV-Datei", auto_csv_dates, selected = tail(auto_csv_dates, 1)),
        selectInput("csv_file_category", "Kategorie", auto_csv_categories)
      ),
      mainPanel(
        fluidRow(
          width = 9,
          DT::dataTableOutput(ns("csvComparisonOutput")) %>% withSpinner()
        )
      )
    )
  )
}


dboes_csv_module <- function(input, output, session) {
  print("module loaded")
}