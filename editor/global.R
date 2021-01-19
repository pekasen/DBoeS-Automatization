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


# CSV storage connection
dboes_db_filepath <- as.character(config::get()$csv_storage)
dboes_db <- read.csv(dboes_db_filepath, sep = ",", encoding = "UTF-8") %>%
  mutate(
    Partei = factor(Partei),
    Parlament = factor(Parlament),
    Geschlecht = factor(Geschlecht, levels = c("männlich", "weiblich", "divers")),
    Wikipedia = "https://de.wikipedia.org/wiki/"
  ) %>%
  relocate(
    Parlament, .before = Name
  ) %>%
  mutate(
    uid = 1:n(),
    modified_at = as.POSIXct(Sys.time()) # needs change
  ) %>%
  arrange(desc(Parlament))


