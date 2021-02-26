#' DBoeS Table Module UI
#'
#' The UI portion of the module for displaying the dboes datatable
#'
#' @importFrom shiny NS tagList fluidRow column actionButton tags
#' @importFrom DT DTOutput
#' @importFrom shinycssloaders withSpinner
#'
#' @param id The id for this module
#'
#' @return a \code{shiny::\link[shiny]{tagList}} containing UI elements
#'
dboes_table_module_ui <- function(id) {
  ns <- NS(id)

  tagList(
    fluidRow(
      column(
        width = 2,
        actionButton(
          ns("add_dboes"),
          "Add",
          class = "btn-success",
          style = "color: #fff;",
          icon = icon('plus'),
          width = '100%'
        ),
        tags$br(),
        tags$br()
      )
    ),
    fluidRow(
      column(
        width = 12,
        title = "Public speakers",
        DTOutput(ns('dboes_table')) %>%
          withSpinner(),
        tags$br(),
        tags$br()
      )
    ),
    tags$script(src = "dboes_table_module.js"),
    tags$script(paste0("dboes_table_module_js('", ns(''), "')"))
  )
}

#' DBoeS Table Module Server
#'
#' The Server portion of the module for displaying the dboes datatable
#'
#' @importFrom shiny reactive reactiveVal observeEvent req callModule eventReactive
#' @importFrom DT renderDT datatable replaceData dataTableProxy
#' @importFrom dplyr tbl collect mutate arrange select filter pull
#' @importFrom purrr map_chr
#' @importFrom tibble tibble
#'
#' @param None
#'
#' @return None

dboes_table_module <- function(input, output, session) {

  # trigger to reload data from the dboes table
  session$userData$dboes_trigger <- reactiveVal(0)

  # Read in dboes table from the database
  dboes_entries <- reactive({
    session$userData$dboes_trigger()
    
    tryCatch({
      out <- dboes_db # is read from csv in global.R
    }, error = function(err) {
      msg <- "CSV File Connection  Error"
      # print `msg` so that we can find it in the logs
      print(msg)
      # print the actual error to log it
      print(err)
      # show error `msg` to user.  User can then tell us about error and we can
      # quickly identify where it cam from based on the value in `msg`
      showToast("error", msg)
    })

    out
  })


  dboes_table_prep <- reactiveVal(NULL)

  observeEvent(dboes_entries(), {
    out <- dboes_entries()

    ids <- out$uid

    actions <- purrr::map_chr(ids, function(id_) {
      paste0(
        '<div class="btn-group" style="width: 75px;" role="group" aria-label="Basic example">
          <button class="btn btn-primary btn-sm edit_btn" data-toggle="tooltip" data-placement="top" title="Edit" id = ', id_, ' style="margin: 0"><i class="fa fa-pencil-square-o"></i></button>
          <button class="btn btn-danger btn-sm delete_btn" data-toggle="tooltip" data-placement="top" title="Delete" id = ', id_, ' style="margin: 0"><i class="fa fa-trash-o"></i></button>
        </div>'
      )
    })

    # Remove the `uid` column. We don't want to show this column to the user
    out <- out %>%
      select(-uid)

    # Set the Action Buttons row to the first column of the dboes table
    out <- cbind(
      tibble("Aktion" = actions),
      out
    )

    if (is.null(dboes_table_prep())) {
      # loading data into the table for the first time, so we render the entire table
      # rather than using a DT proxy
      dboes_table_prep(out)

    } else {

      # table has already rendered, so use DT proxy to update the data in the
      # table without rerendering the entire table
      replaceData(dboes_table_proxy, out, resetPaging = FALSE, rownames = FALSE)

    }
  })

  output$dboes_table <- DT::renderDT({
    req(dboes_table_prep())
    out <- dboes_table_prep()

    DT::datatable(
      out,
      rownames = FALSE,
      # colnames = c("Parlament", "Name", "Partei", "Geschlecht", "Twitter name", "Twitter id", "Wikipedia", "Geändert am"),
      selection = "none",
      class = "compact stripe row-border nowrap",
      # Escape the HTML in all except 1st column (which has the buttons)
      escape = -1,
      extensions = c("Buttons"),
      filter = list(position = "top"),
      options = list(
        scrollX = TRUE,
        dom = 'Bftip',
        buttons = list(
          list(
            extend = "excel",
            text = "Download",
            title = paste0("dboes-", Sys.Date()),
            exportOptions = list(
              columns = 1:(length(out) - 1)
            )
          )
        ),
        columnDefs = list(
          list(targets = 0, orderable = FALSE)
        ),
        pageLength = 100,
        lengthMenu = c(10, 50, 100, 500, 1000, 2000),
        drawCallback = JS("function(settings) {
          // removes any lingering tooltips
          $('.tooltip').remove()
        }")
      )
    ) %>%
      formatDate(
        columns = c("modified_at"),
        method = 'toLocaleString'
      )

  })

  dboes_table_proxy <- DT::dataTableProxy('dboes_table')

  edit_name_var <- callModule(
    dboes_edit_module,
    "add_dboes",
    modal_title = "Add DBoeS Entry",
    dboes_to_edit = function() NULL,
    modal_trigger = reactive({input$add_dboes})
  )

  dboes_to_edit <- eventReactive(input$dboes_id_to_edit, {
    dboes_entries() %>%
      filter(uid == input$dboes_id_to_edit)
  })

  callModule(
    dboes_edit_module,
    "edit_dboes",
    modal_title = "Edit DBoeS entry",
    dboes_to_edit = dboes_to_edit,
    modal_trigger = reactive({input$dboes_id_to_edit})
  )

  dboes_to_delete <- eventReactive(input$dboes_id_to_delete, {
    out <- dboes_entries() %>%
      filter(uid == input$dboes_id_to_delete) %>%
      as.list()
  })

  callModule(
    dboes_delete_module,
    "delete_dboes",
    modal_title = "Delete DBoeS Entry",
    dboes_to_delete = dboes_to_delete,
    modal_trigger = reactive({input$dboes_id_to_delete})
  )

}