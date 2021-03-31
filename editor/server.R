function(input, output, session) {

  # Use session$userData to store user data that will be needed throughout
  # the Shiny application
  session$userData$email <- 'anonymous@leibniz-hbi.de'
  session$userData$selected_category = "Parlamentarier"

  # Call the server function portion of the `dboes_table_module.R` module file
  callModule(dboes_table_module, "dboes_table")

}
