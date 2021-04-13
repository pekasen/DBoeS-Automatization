
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
    dboes_db_category <- values$dboes_entries[[session$userData$selected_category()]]
    
    search_result <- reactiveVal(data.frame())

    showModal(
      modalDialog(
        fluidRow(
          column(
            width = 6,
            selectInput(
              ns('Kategorie'),
              'Kategorie',
              choices = levels(dboes_db_category$Kategorie),
              selected = ifelse(is.null(hold), "", as.character(hold$Kategorie))
            ),
            textInput(
              ns("Name"),
              'Name',
              value = ifelse(is.null(hold), "", hold$Name)
            ),
            selectInput(
              ns('Geschlecht'),
              'Geschlecht',
              choices = levels(dboes_db_category$Geschlecht),
              selected = ifelse(is.null(hold), "", as.character(hold$Geschlecht))
            )
          ),
          column(
            width = 6,
            selectInput(
              ns('Partei'),
              'Partei',
              choices = levels(dboes_db_category$Partei),
              selected = ifelse(is.null(hold), "", as.character(hold$Partei))
            ),
            textInput(
              ns('Wahlkreis'),
              'Wahlkreis',
              value = ifelse(is.null(hold), "", hold$Wahlkreis)
            ),
            textInput(
              ns('tags'),
              'Tags',
              value = ifelse(is.null(hold), "", hold$tags)
            )
          )
        ),
        fluidRow(
          column(
            width = 12,
            textInput(
              width = "100%",
              ns('Kommentar'),
              'Kommentar',
              value = ifelse(is.null(hold), "", hold$Kommentar)
            )
          )
        ),
        fluidRow(
          box(
            width = 12,
            tabsetPanel(
              id = "socialmedia",
              type = "tabs",
              tabPanel(
                "Twitter", 
                fluidRow(
                  column(
                    width = 4,
                    textInput(
                      ns("SM_Twitter_user"),
                      'Twitter user',
                      value = ifelse(is.null(hold), "", hold$SM_Twitter_user)
                    )
                  ),
                  column(
                    width = 4,
                    textInput(
                      ns("SM_Twitter_id"),
                      'Twitter id',
                      value = ifelse(is.null(hold), "", hold$SM_Twitter_id)
                    )
                  ),
                  column(
                    width = 4,
                    checkboxInput(
                      ns("SM_Twitter_verifiziert"),
                      label = "Verifiziert",
                      value = ifelse(
                        is.null(hold), 
                        F, 
                        ifelse(
                          is.logical(hold$SM_Twitter_verifiziert) & !is.na(hold$SM_Twitter_verifiziert), 
                          hold$SM_Twitter_verifiziert, 
                          F
                        )
                      )
                    )
                  )
                ),
                actionButton(ns("buttonTwitter"), label = "Search"),
                DT::dataTableOutput(ns("twitterSearchOutput")) %>% withSpinner()
              ),
              tabPanel(
                "Facebook", 
                fluidRow(
                  column(
                    width = 4,
                    textInput(
                      ns("SM_Facebook_user"),
                      'Facebook user',
                      value = ifelse(is.null(hold), "", hold$SM_Facebook_user)
                    )
                  ),
                  column(
                    width = 4,
                    textInput(
                      ns("SM_Facebook_id"),
                      'Facebook id',
                      value = ifelse(is.null(hold), "", hold$SM_Facebook_id)
                    )
                  ),
                  column(
                    width = 4,
                    checkboxInput(
                      ns("SM_Facebook_verifiziert"),
                      label = "Verifiziert",
                      value = ifelse(
                        is.null(hold), 
                        F, 
                        ifelse(
                          is.logical(hold$SM_Facebook_verifiziert) & !is.na(hold$SM_Facebook_verifiziert), 
                          hold$SM_Facebook_verifiziert, 
                          F
                        )
                      )
                    )
                  )
                ),
                actionButton(ns("buttonFacebook"), label = "Search"),
                DT::dataTableOutput(ns("facebookSearchOutput")) %>% withSpinner()
              ),
              tabPanel(
                "URLs", 
                fluidRow(
                  column(
                    width = 12,
                    textInput(
                      ns("Homepage_URL"),
                      'Homepage_URL',
                      value = ifelse(is.null(hold), "", hold$Homepage_URL)
                    ),
                    textInput(
                      ns("Wikipedia_URL"),
                      'Wikipedia_URL',
                      value = ifelse(is.null(hold), "", hold$Wikipedia_URL)
                    ),
                    textInput(
                      ns("Bild"),
                      'Bild',
                      value = ifelse(is.null(hold), "", hold$Bild)
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
    
    output$twitterSearchOutput <- DT::renderDT(
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
      id = if (is.null(hold)) NA else hold$id,
      data = list(
        "Kategorie" = input$Kategorie,
        "Name" = input$Name,
        "Partei" = input$Partei,
        "Wahlkreis" = input$Wahlkreis,
        "Kommentar" = input$Kommentar,
        "Geschlecht" = input$Geschlecht,
        "SM_Twitter_user" = input$SM_Twitter_user,
        "SM_Twitter_id" = input$SM_Twitter_id,
        "SM_Twitter_verifiziert" = input$SM_Twitter_verifiziert,
        "SM_Facebook_user" = input$SM_Facebook_user,
        "SM_Facebook_id" = input$SM_Facebook_id,
        "SM_Facebook_verifiziert" = input$SM_Facebook_verifiziert,
        "Wikipedia_URL" = input$Wikipedia_URL,
        "Homepage_URL" = input$Homepage_URL,
        "Bild" = input$Bild,
        "tags" = input$tags
      )
    )
    
    time_now <- as.character(Sys.time())
    
    if (is.null(hold)) {
      # adding a new entry
      out$data$created_at <- time_now
      out$data$created_by <- session$userData$username
    } else {
      # Editing existing entry
      out$data$created_at <- as.character(hold$created_at)
      out$data$created_by <- hold$created_by
    }
    
    out$data$modified_at <- time_now
    out$data$modified_by <- session$userData$username
    
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

      colnames_to_update <- names(dat$data)
      
      if (is.na(dat$id)) {
        
        # creating a new entry
        id <- uuid::UUIDgenerate()
        colnames_to_update <- c("id", colnames_to_update)
        dat$data$id <- id
        values$dboes_entries[[session$userData$selected_category()]][id, colnames_to_update] <- dat$data[colnames_to_update]
        
      } else {
        
        # editing an existing entry
        values$dboes_entries[[session$userData$selected_category()]][dat$id, colnames_to_update] <- dat$data[colnames_to_update]
        
      }
      
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
  return(head(twitter_df))
}

