fluidPage(
  shinyFeedback::useShinyFeedback(),
  shinyjs::useShinyjs(),
  # Application Title
  titlePanel(
    h1("Datenbank öffentlicher Sprecher", align = 'center'),
    windowTitle = "Datenbank öffentlicher Sprecher"
  ),
  dboes_table_module_ui("dboes_table")
)

