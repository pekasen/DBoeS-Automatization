# Library in packages used in this application
library(shiny)
library(DT)
library(shinyjs)
library(shinycssloaders)
library(shinydashboard)
library(lubridate)
library(shinyFeedback)
library(dplyr)

# Turn off scientific notation and stringsAsFactors
options(scipen = 999, stringsAsFactors = F)

# Set spinner type (for loading)
options(spinner.type = 8)

# debug
options(shiny.error = browser)

# paths to all dboes categories files
dboes_db_filepaths <- list(
  "Parlamentarier" = "../db/reviewed/Parlamentarier.csv",
  "BT-Wahl 2021" = "../db/reviewed/BT-Wahl_2021.csv"
)

# default selected category
selected_dboes_category <- list(
  Name = "Parlamentarier",
  Location = "../db/reviewed/Parlamentarier.csv"
)
