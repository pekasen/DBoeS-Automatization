#' dboes Save Module
#'
#' This module is for saving the current database file as csv to disk
#'
#' @importFrom shiny observeEvent req showModal h3 modalDialog removeModal actionButton modalButton
#' @importFrom DBI dbExecute
#' @importFrom shinyFeedback showToast
#'
#' @param modal_title string - the title for the modal
#' @param dboes_to_save string - the model of the dboes category to be saved
#' @param modal_trigger reactive trigger to open the modal (Save button)
#'
#' @return None
#'
dboes_save_module <- function(input, output, session, modal_title, dboes_to_save, modal_trigger) {
  ns <- session$ns
  
  # Observes trigger for this module (here, the Save Button)
  observeEvent(modal_trigger(), {
    # Authorize who is able to access particular buttons (here, modules)
    req(session$userData$user_auth())
    
    showModal(
      modalDialog(
        div(
          style = "padding: 30px;",
          class = "text-center",
          h2(
            style = "line-height: 1.75;",
            paste0(
              'Are you sure you want to save your edits for "',
              dboes_to_save,
              '"?'
            )
          )
        ),
        title = modal_title,
        size = "m",
        footer = list(
          modalButton("Cancel"),
          actionButton(
            ns("submit_save"),
            "Save",
            class = "btn-danger",
            style="color: #fff;"
          )
        )
      )
    )
  })
  
  observeEvent(input$submit_save, {
    
    removeModal()
    
    tryCatch({
      
      file_path <- dboes_db_filepaths[[dboes_to_save]] 
      
      db_to_save <- values$dboes_entries[[dboes_to_save]]
      db_to_save[is.na(db_to_save)] <- ""
      db_to_save <- apply(db_to_save, 2, as.character)
      
      write.csv(db_to_save, file = file_path, fileEncoding = "UTF-8", row.names = F)
      
      showToast("success", paste0(dboes_to_save, " successfully saved"))
      
    }, error = function(error) {
      
      msg <- "Error saving CSV"
      # print `msg` so that we can find it in the logs
      print(msg)
      # print the actual error to log it
      print(error)
      # show error `msg` to user.  User can then tell us about error and we can
      # quickly identify where it cam from based on the value in `msg`
      showToast("error", msg)
      
    })
  })
}
