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
  rename(Partei = Fraktion) %>%
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
    uid = uuid::UUIDgenerate(n = n()),
    modified_at = as.POSIXct(Sys.time()) # needs change
  ) %>%
  arrange(desc(Parlament))
rownames(dboes_db) <- dboes_db$uid

# 
# # Library in packages used in this application
# library(shiny)
# library(DT)
# library(shinyjs)
# library(shinycssloaders)
# library(shinydashboard)
# library(lubridate)
# library(shinyFeedback)
# library(dplyr)
# 
# # Turn off scientific notation and stringsAsFactors
# options(scipen = 999, stringsAsFactors = F)
# 
# # Set spinner type (for loading)
# options(spinner.type = 8)
# 
# # debug
# options(shiny.error = browser)
# 
# 
# # CSV storage connection
# dboes_base_path <- "../db/reviewed/"
# dboes_db_filepath <- list.files(paste0(dboes_base_path, "Parlamentarier/"), full.names = T)
# 
# # Infer categories and groups from file system structure
# dboes_categories <- list.files("../db/reviewed")
# dboes_groups <- lapply(dboes_categories, FUN = function(x) gsub(".csv", "", list.files(paste0(dboes_base_path, x))))
# names(dboes_groups) <- dboes_categories
# 
# 
# dboes_db <- read.csv(dboes_db_filepath[1], sep = ",", encoding = "UTF-8") 
# dboes_db[is.na(dboes_db)] <- ""
# dboes_db <- dboes_db %>%
#   rename(uid = uuid, Partei = Fraktion, Parlament = group, Wikipedia = Wikipedia_URL) %>%
#   mutate(
#     Partei = factor(Partei),
#     Parlament = factor(Parlament),
#     Geschlecht = factor(Geschlecht, levels = c("männlich", "weiblich", "divers")),
#   ) %>%
#   arrange(Name)
# 
# 


