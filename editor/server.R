function(input, output, session) {
  
  credentials <- callModule(shinyauthr::login, "login",
                            data = user_base,
                            user_col = user,
                            pwd_col = password_hash,
                            sessionid_col = sessionid,
                            cookie_getter = get_sessions_from_db,
                            cookie_setter = add_session_to_db,
                            sodium_hashed = TRUE,
                            log_out = reactive(logout_init()))
  
  # Use session$userData to store user data that will be needed throughout
  # the Shiny application
  session$userData$selected_category <- reactiveVal("Parlamentarier")
  session$userData$user_auth <- reactive(credentials()$user_auth)
  session$userData$user_info <- reactive({credentials()$info})
    
  logout_init <- callModule(shinyauthr::logout, "logout", session$userData$user_auth)
  
  output$logged_in_user <- renderText({
    out <- " Anmelden"
    if (session$userData$user_auth()) {
      out <- paste0(" ", session$userData$user_info()$user)
    }
    out
  })
  
  output$login_rights_info <- renderUI({
    out <- NULL
    if (session$userData$user_auth()) {
      out <- p(paste0("Eingeloggt als ", session$userData$user_info()$permissions), class = "permission-info")
    }
    out
  })
  
  # Call the server function portion of the `dboes_table_module.R` module file
  callModule(dboes_table_module, "dboes_table", session$userData$selected_category, session$userData$user_info)
  
  # observe selected tab 
  observeEvent(input$dboes_category, {
    session$userData$selected_category(input$dboes_category)
  })
  
  # CSV comparison
  callModule(dboes_csv_module, "dboes_csv", input$csv_file_old, input$csv_file_new)
  
}
