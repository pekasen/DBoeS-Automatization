function(input, output, session) {
  
  # check_credentials returns a function to authenticate users
  source("auth_credentials.R")
  res_auth <- callModule(
    module = shinymanager::auth_server,
    id = "auth",
    check_credentials = check_credentials(credentials)
  )
  
  observeEvent(session$input$logout,{
    session$reload()
  })

  # Use session$userData to store user data that will be needed throughout
  # the Shiny application
  session$userData$username <- "Anonymer user"
  session$userData$selected_category <- reactiveVal("Parlamentarier")

  # Call the server function portion of the `dboes_table_module.R` module file
  callModule(dboes_table_module, "dboes_table", session$userData$selected_category)
  
  # observe selected tab 
  observeEvent(input$dboes_category, {
    session$userData$selected_category(input$dboes_category)
  })
  
  # user login info and message menu
  output$messageMenu <- renderMenu({
    
    # messages
    messageData <- data.frame(
      "from" = "Logged in as",
      "message" = session$userData$username
    )
    
    # prepare list of messageItems
    msgs <- apply(messageData, 1, function(row) {
      messageItem(from = row[["from"]], message = row[["message"]])
    })
    
    # This is equivalent to calling:
    #   dropdownMenu(type="messages", msgs[[1]], msgs[[2]], ...)
    dropdownMenu(type = "messages", .list = msgs)
  })
  
}
