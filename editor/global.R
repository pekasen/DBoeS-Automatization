# Library in packages used in this application
library(shiny)
library(DT)
library(shinyjs)
library(shinycssloaders)
library(shinydashboard)
library(shinyFeedback)
library(shinymanager)
library(tidyverse)
library(magrittr)
library(yaml)

# Turn off scientific notation and stringsAsFactors
options(scipen = 999, stringsAsFactors = F)

# Set spinner type (for loading)
options(spinner.type = 8)

# debug
options(shiny.error = browser)

# categories
tag_categories <- yaml::read_yaml("data/categories.yaml")

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
    mutate_at(vars(c("Kategorie", "Geschlecht", "Partei")), as.factor) %>%
    mutate_at(vars(ends_with("_verifiziert")), as.logical)
  rownames(dboes_df) <- dboes_df$id
  dboes_db[[category]] <- dboes_df
}

# pre-set levels for specific tables
levels(dboes_db[["Parlamentarier"]]$Geschlecht) <- c(levels(dboes_db[["Parlamentarier"]]$Geschlecht), tag_categories$Geschlecht)
levels(dboes_db[["BT-Wahl 2021"]]$Kategorie) <- c(levels(dboes_db[["BT-Wahl 2021"]]$Kategorie), tag_categories$Bundesland)
levels(dboes_db[["BT-Wahl 2021"]]$Partei) <- c(levels(dboes_db[["BT-Wahl 2021"]]$Partei), tag_categories$Partei)
levels(dboes_db[["BT-Wahl 2021"]]$Geschlecht) <- c(levels(dboes_db[["BT-Wahl 2021"]]$Geschlecht), tag_categories$Geschlecht)

# set db as reactive value in a list of reactive values for multi-user editing
values <- reactiveValues(
  dboes_entries = dboes_db
)
