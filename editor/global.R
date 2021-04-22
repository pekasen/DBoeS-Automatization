# Library in packages used in this application
if (!require("pacman")) install.packages("pacman")

pacman::p_load(shiny)
pacman::p_load(DT)
pacman::p_load(shinyjs)
pacman::p_load(shinycssloaders)
pacman::p_load(shinydashboard)
pacman::p_load(shinyFeedback)
pacman::p_load(tidyverse)
pacman::p_load(magrittr)
pacman::p_load(RSQLite)
pacman::p_load(DBI)
pacman::p_load(lubridate)
pacman::p_load(kableExtra)
pacman::p_load(reticulate)

pacman::p_load_gh("PaulC91/shinyauthr")

# Turn off scientific notation and stringsAsFactors
options(scipen = 999, stringsAsFactors = F)

# Set spinner type (for loading)
options(spinner.type = 8)

# debug
options(shiny.error = browser)

# ShinyAuthR Authentication
# -------------------------
# How many days should sessions last?
cookie_expiry <- 7

# This function must return a data.frame with columns user and sessionid.  Other columns are also okay
# and will be made available to the app after log in.

get_sessions_from_db <- function(conn = db, expiry = cookie_expiry){
  dbReadTable(conn, "sessions") %>%
    mutate(login_time = ymd_hms(login_time)) %>%
    as_tibble() %>%
    filter(login_time > now() - days(expiry))
}

# This function must accept two parameters: user and sessionid. It will be called whenever the user
# successfully logs in with a password.

add_session_to_db <- function(user, sessionid, conn = db){
  tibble(user = user, sessionid = sessionid, login_time = as.character(now())) %>%
    dbWriteTable(conn, "sessions", ., append = TRUE)
}

# create SQLite db in memory
db <- dbConnect(SQLite(), ":memory:")
dbCreateTable(db, "sessions", c(user = "TEXT", sessionid = "TEXT", login_time = "TEXT"))

# read credentials base
user_base <- readRDS("auth_credentials.rds")


# DB Data configurations
# ----------------------

# CSV files from automatic retrieval
auto_csv_path <- "../output/parliaments"
auto_csv_files <- list.files(auto_csv_path, pattern = "*.csv$", full.names = F, recursive = T)
auto_csv_dates <- list.files(auto_csv_path)
auto_csv_categories <- sort(unique(sapply(strsplit(auto_csv_files, "/"), FUN = function(x) x[2])))

# categories
tag_categories <- yaml::read_yaml("data/categories.yaml")

# paths to all dboes categories files
dboes_db_filepaths <- list(
  "Parlamentarier" = "../db/reviewed/Parlamentarier.csv",
  "BT-Wahl 2021" = "../db/reviewed/BT-Wahl 2021.csv",
  "Medienorganisation" = "../db/reviewed/BT-Wahl 2021.csv"
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
