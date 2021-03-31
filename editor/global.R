# Library in packages used in this application
library(shiny)
library(DT)
library(shinyjs)
library(shinycssloaders)
library(shinydashboard)
library(shinyFeedback)
library(tidyverse)
library(magrittr)

# Turn off scientific notation and stringsAsFactors
options(scipen = 999, stringsAsFactors = F)

# Set spinner type (for loading)
options(spinner.type = 8)

# debug
options(shiny.error = browser)

# paths to all dboes categories files
dboes_db_filepaths <- list(
  "Parlamentarier" = "../db/reviewed/Parlamentarier.csv",
  "BT-Wahl 2021" = "../db/reviewed/BT-Wahl 2021.csv"
)

dboes_db <- list()

for (i in 1:length(dboes_db_filepaths)) {
  category = names(dboes_db_filepaths)[i]
  file_path = dboes_db_filepaths[[category]]
  # Read in dboes table from the database
  dboes_df <- read.csv(
    file_path, 
    encoding = "UTF-8", 
    colClasses = "character"
  )
  # format dboes df
  dboes_df <- dboes_df %>%
    mutate_at(vars(c("Kategorie", "Geschlecht", "Partei")), as.factor)
  rownames(dboes_df) <- dboes_df$id
  dboes_db[[category]] <- dboes_df
}

# set db as reactive value in a list of reactive values for multi-user editing
values <- reactiveValues(
  dboes_entries = dboes_db
)
