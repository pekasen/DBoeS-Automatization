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
          ns("save_dboes"),
          "Save",
          class = "btn-success",
          style = "color: #fff;",
          icon = icon('save'),
          width = '100%'
        ),
        tags$br(),
        tags$br()
      ),
      column(
        width = 1,
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
    
    if (is.null(session$userData$dboes_db)) {
      tryCatch(
        {
          
          # todo: switch to reactive input$selected_csv
          session$userData$dboes_db <- read.csv(
            selected_dboes_category$Location, 
            encoding = "UTF-8", 
            colClasses = c(
              "created_at" = "character", 
              "modified_at" = "character"
            )
          ) 
          # format df data
          rownames(session$userData$dboes_db) <- session$userData$dboes_db$uuid
          format_as_factor <- c("Kategorie", "Geschlecht", "Partei")
          for (column in format_as_factor) {
            session$userData$dboes_db[[column]] <- factor(session$userData$dboes_db[[column]])
          }
          
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
    }

    session$userData$dboes_db
  })

  dboes_table_prep <- reactiveVal(NULL)

  observeEvent(dboes_entries(), {
    out <- dboes_entries()

    ids <- out$uuid

    actions <- purrr::map_chr(ids, function(id_) {
      paste0(
        '<div class="btn-group" style="width: 75px;" role="group" aria-label="Basic example">
          <button class="btn btn-primary btn-sm edit_btn" data-toggle="tooltip" data-placement="top" title="Edit" id = ', id_, ' style="margin: 0"><i class="fa fa-pencil-square-o"></i></button>
          <button class="btn btn-danger btn-sm delete_btn" data-toggle="tooltip" data-placement="top" title="Delete" id = ', id_, ' style="margin: 0"><i class="fa fa-trash-o"></i></button>
        </div>'
      )
    })

    # Remove the `uuid` column. We don't want to show this column to the user
    out <- out %>%
      select(-uuid)

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
    # %>%
    #  relocate(Bild)
    
    
    # $filename = replace($name, ' ', '_');
    # $digest = md5($filename);
    # $folder = $digest[0] . '/' . $digest[0] . $digest[1] . '/' .  urlencode($filename);
    # $url = 'http://upload.wikimedia.org/wikipedia/commons/' . $folder;
    # out$Bild <- paste('<img src="', out$Bild, '" width=70/>', sep='')

    DT::datatable(
      out,
      rownames = FALSE,
      # colnames = c("Parlament", "Name", "Partei", "Geschlecht", "Twitter name", "Twitter id", "Wikipedia", "Geändert am"),
      selection = "none",
      class = "compact stripe row-border nowrap",
      # Escape the HTML in all except first columns
      escape = -c(1, 2),
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
  
  callModule(
    dboes_save_module,
    "save_dboes",
    modal_title = "Save DBoeS",
    dboes_to_save = selected_dboes_category,
    modal_trigger = reactive({input$save_dboes})
  )

  callModule(
    dboes_edit_module,
    "add_dboes",
    modal_title = "Add DBoeS Entry",
    dboes_to_edit = function() NULL,
    modal_trigger = reactive({input$add_dboes})
  )

  dboes_to_edit <- eventReactive(input$dboes_id_to_edit, {
    dboes_entries() %>%
      filter(uuid == input$dboes_id_to_edit)
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
      filter(uuid == input$dboes_id_to_delete) %>%
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
