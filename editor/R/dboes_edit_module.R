
#' DBoeS Add & Edit Module
#'
#' Module to add & edit entrys in the dboes database file
#'
#' @importFrom shiny observeEvent showModal modalDialog removeModal fluidRow column textInput numericInput selectInput modalButton actionButton reactive eventReactive
#' @importFrom shinyFeedback showFeedbackDanger hideFeedback showToast
#' @importFrom shinyjs enable disable
#' @importFrom lubridate with_tz
#' @importFrom uuid UUIDgenerate
#' @importFrom DBI dbExecute
#'
#' @param modal_title string - the title for the modal
#' @param dboes_to_edit reactive returning a 1 row data frame of the entry to edit
#' from the dboes table
#' @param modal_trigger reactive trigger to open the modal (Add or Edit buttons)
#'
#' @return None
#'
dboes_edit_module <- function(input, output, session, modal_title, dboes_to_edit, modal_trigger) {
  ns <- session$ns
  
  observeEvent(modal_trigger(), {
    hold <- dboes_to_edit()
    
    search_result <- reactiveVal(data.frame())
    
    showModal(
      modalDialog(
        fluidRow(
          column(
            width = 6,
            selectInput(
              ns('Parlament'),
              'Parlament',
              choices = levels(dboes_db$Parlament),
              selected = ifelse(is.null(hold), "", as.character(hold$Parlament))
            ),
            textInput(
              ns("Name"),
              'Name',
              value = ifelse(is.null(hold), "", hold$Name)
            )
          ),
          column(
            width = 6,
            selectInput(
              ns('Partei'),
              'Partei',
              choices = levels(dboes_db$Partei),
              selected = ifelse(is.null(hold), "", as.character(hold$Partei))
            ),
            selectInput(
              ns('Geschlecht'),
              'Geschlecht',
              choices = levels(dboes_db$Geschlecht),
              selected = ifelse(is.null(hold), "", as.character(hold$Geschlecht))
            )
          )
        ),
        fluidRow(
          box(
            width = 12,
            tabsetPanel(
              type = "tabs",
              tabPanel(
                "Twitter", 
                fluidRow(
                  column(
                    width = 6,
                    textInput(
                      ns("Twitter_screen_name"),
                      'Twitter_screen_name',
                      value = ifelse(is.null(hold), "", hold$Twitter_screen_name)
                    )
                  ),
                  column(
                    width = 6,
                    textInput(
                      ns("Twitter_id"),
                      'Twitter_id',
                      value = ifelse(is.null(hold), "", hold$Twitter_id)
                    )
                  )
                ),
                actionButton(ns("buttonTwitter"), label = "Search"),
                DT::dataTableOutput(ns("searchOutput"))
              ),
              tabPanel(
                "Wikipedia", 
                fluidRow(
                  column(
                    width = 12,
                    textInput(
                      ns("Wikipedia"),
                      'Wikipedia',
                      value = ifelse(is.null(hold), "", hold$Wikipedia)
                    )
                  )
                )
              )
              
            )
          )
        ),
        title = modal_title,
        size = 'm',
        footer = list(
          modalButton('Cancel'),
          actionButton(
            ns('submit'),
            'Submit',
            class = "btn btn-primary",
            style = "color: white"
          )
        )
      )
    )
    
    # Observe event for "Model" text input in Add/Edit entry modal
    # `shinyFeedback`
    observeEvent(input$Name, {
      if (input$Name == "") {
        shinyFeedback::showFeedbackDanger(
          "Name",
          text = "You must enter a name for an entry!"
        )
        shinyjs::disable('submit')
      } else {
        shinyFeedback::hideFeedback("Name")
        shinyjs::enable('submit')
      }
    })
    
    observeEvent(input$buttonTwitter, {
      search_result(get_twitter_suggestions(input$Name))
    })
    
    output$searchOutput <- DT::renderDT(
      {
        search_result()
      },
      rownames = FALSE,
      escape = FALSE,
      options = list(paging = FALSE, searching = FALSE, lengthMenu = NULL)
    ) 
  })
  
  
  edit_dboes_dat <- reactive({
    
    hold <- dboes_to_edit()
    
    out <- list(
      uid = if (is.null(hold)) NA else hold$uid,
      data = list(
        "Parlament" = input$Parlament,
        "Name" = input$Name,
        "Partei" = input$Partei,
        "Geschlecht" = input$Geschlecht,
        "Twitter_screen_name" = input$Twitter_screen_name,
        "Twitter_id" = input$Twitter_id,
        "Wikipedia" = input$Wikipedia
      )
    )
    
    time_now <- as.character(lubridate::with_tz(Sys.time(), tzone = "UTC"))
    
    if (is.null(hold)) {
      # adding a new entry
      out$data$created_at <- time_now
      out$data$created_by <- session$userData$email
    } else {
      # Editing existing entry
      out$data$created_at <- as.character(hold$created_at)
      out$data$created_by <- hold$created_by
    }
    
    out$data$modified_at <- time_now
    out$data$modified_by <- session$userData$email
    
    out
  })
  
  validate_edit <- eventReactive(input$submit, {
    dat <- edit_dboes_dat()
    
    # Logic to validate inputs...
    
    dat
  })
  
  observeEvent(validate_edit(), {
    removeModal()
    dat <- validate_edit()
    
    tryCatch({
      
      colnames_to_update <- c(
        "Name",
        "Partei",
        "Parlament",
        "Geschlecht",
        "Twitter_id",
        "Twitter_screen_name",
        "Wikipedia"
      )
      
      if (is.na(dat$uid)) {
        
        # creating a new entry
        uid <- uuid::UUIDgenerate()
        dboes_db[uid, colnames_to_update] <<- dat$data[colnames_to_update]
        
      } else {
        
        # editing an existing entry
        dboes_db[dat$uid, colnames_to_update] <<- dat$data[colnames_to_update]
        
      }
      
      session$userData$dboes_trigger(session$userData$dboes_trigger() + 1)
      showToast("success", paste0(modal_title, " Success"))
      
    }, error = function(error) {
      msg <- paste0(modal_title, " Error")
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




get_twitter_suggestions <- function(name) {
  twitter_df <- tryCatch(
    {
      fetcher <- reticulate::import_from_path("scraper.twitter_fetcher", path = "..")
      entity <- fetcher$EntityOnTwitter(name)
      entity$search_accounts()
      df <- do.call(rbind.data.frame, lapply(entity$twitter_accounts, FUN = function(x) data.frame(x$data)))
      df
    },
    error = function(e) {
      message("Could not get data from API (error somewhere in the python code)")
      data.frame()
    }
  )
  
  if (length(twitter_df) > 0) {
    twitter_df$profile_image_url <- paste('<img src="', twitter_df$profile_image_url, '" width=70/>', sep='')
    twitter_df$platform <- NULL
    twitter_df$reviewed <- NULL
    twitter_df <- twitter_df %>%
      mutate(user = paste0('<a href="', twitter_df$url, '" target="_blank">', twitter_df$user_name, '</a>')) %>%
      mutate(verified_icon = ifelse(verified, "<span class=\"text-success\"> ✓</span>", "")) %>%
      mutate(user_v = paste(user, verified_icon)) %>%
      select(
        Image = "profile_image_url",
        Screen_name = "user_v",
        Twitter_id =  "platform_id",
        Desc = "description"
      )
  }
  return(twitter_df)
}

