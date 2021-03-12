
#' dboes Delete Module
#'
#' This module is for deleting a row's information from the database file
#'
#' @importFrom shiny observeEvent req showModal h3 modalDialog removeModal actionButton modalButton
#' @importFrom DBI dbExecute
#' @importFrom shinyFeedback showToast
#'
#' @param modal_title string - the title for the modal
#' @param dboes_to_delete string - the model of the dboes entry to be deleted
#' @param modal_trigger reactive trigger to open the modal (Delete button)
#'
#' @return None
#'
dboes_delete_module <- function(input, output, session, modal_title, dboes_to_delete, modal_trigger) {
  ns <- session$ns

  # Observes trigger for this module (here, the Delete Button)
  observeEvent(modal_trigger(), {
    # Authorize who is able to access particular buttons (here, modules)
    req(session$userData$email == 'anonymous@leibniz-hbi.de')
    
    showModal(
      modalDialog(
        div(
          style = "padding: 30px;",
          class = "text-center",
          h2(
            style = "line-height: 1.75;",
            paste0(
              'Are you sure you want to delete the entry for "',
              dboes_to_delete()$Name,
              '"?'
            )
          )
        ),
        title = modal_title,
        size = "m",
        footer = list(
          modalButton("Cancel"),
          actionButton(
            ns("submit_delete"),
            "Delete entry",
            class = "btn-danger",
            style="color: #fff;"
          )
        )
      )
    )
  })

  observeEvent(input$submit_delete, {
    req(dboes_to_delete())

    removeModal()

    tryCatch({

      uuid <- dboes_to_delete()$uuid

      session$userData$dboes_db <- session$userData[-which(session$userData$uuid == uuid), ]

      session$userData$dboes_trigger(session$userData$dboes_trigger() + 1)
      showToast("success", "Entry successfully deleted")
      
    }, error = function(error) {

      msg <- "Error deleting entry"
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
