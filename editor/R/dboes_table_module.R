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
        width = 12,
        tabsetPanel(
          id = "dboes_category",
          type = "tabs",
          tabPanel("Parlamentarier", br()),
          tabPanel("BT-Wahl 2021", br())
          # tabPanel("Medienorganisation", br())
        )
      )
    ),
    fluidRow(
      column(
        width = 4,
        div(style = "display:inline-block; float:left; margin-right: 12px;", 
            actionButton(
              ns("add_dboes"),
              "Add",
              class = "btn-success",
              style = "color: #fff;",
              icon = icon('plus'),
              width = '100%',
              style="margin-right:15px; margin-bottom: 15px;"
            )
        ),
        div(style = "display:inline-block; float:left;", 
            actionButton(
              ns("save_dboes"),
              "Save",
              class = "btn-success",
              style = "color: #fff;",
              icon = icon('save'),
              width = '100%',
              style="margin-right:15px; margin-bottom: 15px;"
            )
        )
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

dboes_table_module <- function(input, output, session, selected_tab, user_login) {
  
  dboes_table_prep <- reactiveVal(NULL)
  
  observe({
    
    out <- values$dboes_entries[[selected_tab()]]
    
    ids <- rownames(out)
    
    # Remove the `uuid` column. We don't want to show this column to the user
    out <- out %>%
      select(-id) %>%
      relocate(Bild)
    
    # Create edit / add action buttons
    actions <- purrr::map_chr(ids, function(id_) {
      paste0(
        '<div class="btn-group" style="width: 75px;" role="group" aria-label="Basic example">
          <button class="btn btn-primary btn-sm edit_btn" data-toggle="tooltip" data-placement="top" title="Edit" id = ', id_, ' style="margin: 0"><i class="fa fa-pencil-square-o"></i></button>
          <button class="btn btn-danger btn-sm delete_btn" data-toggle="tooltip" data-placement="top" title="Delete" id = ', id_, ' style="margin: 0"><i class="fa fa-trash-o"></i></button>
        </div>'
      )
    })
    
    # Set the Action Buttons row to the first column of the dboes table
    out <- cbind(
      tibble("Aktion" = actions),
      out
    )
    
    # Add photo
    image_names <- gsub("https://de.wikipedia.org/wiki/Datei:", "", out$Bild)
    image_names_enc <- iconv(sapply(image_names, URLdecode, USE.NAMES = FALSE), from = "UTF-8", to="UTF-8")
    digest <- str_split(openssl::md5(image_names_enc), "")
    image_paths <- paste0(sapply(digest, FUN = function(x) paste0(x[1], '/', x[1], x[2], '/')), image_names_enc, "/70px-", image_names_enc)
    image_urls <- paste0("https://upload.wikimedia.org/wikipedia/commons/thumb/", image_paths)
    image_urls <- ifelse(endsWith(image_urls, ".svg"), paste0(image_urls, ".png"), image_urls)
    out$Bild <- paste0('<img src="', image_urls, '" width=70/>')
    
    # replace social media information with symbols
    empty_fields_tw <- rowSums(cbind(out$SM_Twitter_user == "", out$SM_Twitter_id == "", is.na(out$SM_Twitter_verifiziert)))
    empty_fields_fb <- rowSums(cbind(out$SM_Facebook_user == "", out$SM_Facebook_id == "", is.na(out$SM_Facebook_verifiziert)))

    out <- out %>%
      mutate(Wahlkreis = ifelse(Wahlkreis == "", as.character(icon("minus-circle", class = "text-danger")), as.character(icon("check-circle", class = "text-success")))) %>%
      mutate(Wikipedia = ifelse(Wikipedia_URL == "", as.character(icon("minus-circle", class = "text-danger")), as.character(icon("check-circle", class = "text-success")))) %>%
      mutate(Homepage = ifelse(Homepage_URL == "", as.character(icon("minus-circle", class = "text-danger")), as.character(icon("check-circle", class = "text-success")))) %>%
      mutate(Twitter = ifelse(empty_fields_tw >= 2, as.character(icon("minus-circle", class = "text-danger")), ifelse(empty_fields_tw == 1, as.character(icon("exclamation-circle", class = "text-warning")), as.character(icon("check-circle", class = "text-success"))))) %>% 
      mutate(Facebook = ifelse(empty_fields_fb >= 2, as.character(icon("minus-circle", class = "text-danger")), ifelse(empty_fields_fb == 1, as.character(icon("exclamation-circle", class = "text-warning")), as.character(icon("check-circle", class = "text-success"))))) %>% 
      select(-c(Wikipedia_URL, Homepage_URL, Kommentar)) %>%
      select(-starts_with('SM_')) %>%
      relocate(Wikipedia, Homepage, Twitter, Facebook, .after = "tags")
    
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
      # Do not escape the HTML in columns
      escape = F,
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
        columns = c("created_at", "modified_at"),
        method = 'toLocaleString'
      ) 
    
  })
  
  
  observe({
    toggle(hide("save_dboes"))
    if (is.null(user_login())) {
      shinyjs::hide("save_dboes")
      shinyjs::hide("add_dboes")
      DT::hideCols(dboes_table_proxy, 0)
    } else {
      DT::showCols(dboes_table_proxy, 0)
      shinyjs::show("save_dboes")
      shinyjs::show("add_dboes")
    }
  })
  
  
  dboes_table_proxy <- DT::dataTableProxy('dboes_table')
  
  callModule(
    dboes_save_module,
    "save_dboes",
    modal_title = "Save DBoeS",
    dboes_to_save = session$userData$selected_category(),
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
    values$dboes_entries[[session$userData$selected_category()]][input$dboes_id_to_edit, ]
  })
  
  callModule(
    dboes_edit_module,
    "edit_dboes",
    modal_title = "Edit DBoeS entry",
    dboes_to_edit = dboes_to_edit,
    modal_trigger = reactive({input$dboes_id_to_edit})
  )
  
  dboes_to_delete <- eventReactive(input$dboes_id_to_delete, {
    values$dboes_entries[[session$userData$selected_category()]][input$dboes_id_to_delete, ]
  })
  
  callModule(
    dboes_delete_module,
    "delete_dboes",
    modal_title = "Delete DBoeS Entry",
    dboes_to_delete = dboes_to_delete,
    modal_trigger = reactive({input$dboes_id_to_delete})
  )
  
}
