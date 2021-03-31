require(dplyr)

# SQL for Pluragraph data:
# select p.name as Name, p.id_at_service as SM_Facebook_id, p.identifier as SM_Facebook_user from profiles p where p.type = 'Service::Facebook::Profile' and p.organisation_id in (select organisation_id from organisation_categories oc where oc.category_id in (select c.id from categories c where c."name" like '%Md%'));

dboes_deprecated <- read.csv("../db/parliamentarians.csv", encoding = "UTF-8", colClasses = "character") %>%
  select(-Parlament, -Fraktion)
facebook_pluragraph <- read.csv("data/facebook.csv", encoding = "UTF-8", colClasses = "character")
facebook_pluragraph <- facebook_pluragraph[order(facebook_pluragraph$Name), ] %>%
  filter(Name != "")
lidx <- !duplicated(facebook_pluragraph$Name)
facebook_pluragraph <- facebook_pluragraph[lidx, ]

bundeslaender <- list(
  "berlin" = "Abgeordnetenhaus von Berlin",
  "bayern" = "Bayerischer Landtag",
  "bremen" = "Bremische Bürgerschaft",
  "bundestag" = "Bundestag",
  "eu" = "EU-Parlament",
  "hamburg" = "Hamburgische Bürgerschaft",
  "hessen" = "Hessischer Landtag",
  "brandenburg" = "Landtag Brandenburg",
  "saarland" = "Landtag des Saarlandes",
  "mcpomm" = "Landtag Mecklenburg-Vorpommern",
  "nrw" = "Landtag Nordrhein-Westfalen",
  "rlp" = "Landtag Rheinland-Pfalz",
  "sachsen-anhalt" = "Landtag Sachsen-Anhalt",
  "bawue" = "Landtag von Baden-Württemberg",
  "niedersachsen" = "Niedersächsischer Landtag",
  "sachsen" = "Sächsischer Landtag",
  "sh" = "Schleswig-Holsteinischer Landtag",
  "thueringen" = "Thüringer Landtag"
)

dboes_scraped <- data.frame()
for (i in 1:length(bundeslaender)) {
  bl_short <- names(bundeslaender)[i]
  bl <- bundeslaender[i]
  df <- read.csv(paste0("../db/new/Parlamentarier/", bl_short, ".csv"), encoding = "UTF-8", colClasses = "character")
  df$Parlament <- bl
  dboes_scraped <- rbind(dboes_scraped, df)
}

duplicate_names_in_wikipedia <- dboes_scraped[which(duplicated(dboes_scraped$Name)), c("Name", "Fraktion", "Parlament")]
print(duplicate_names_in_wikipedia)

merged_dboes <- dboes_scraped %>%
  left_join(dboes_deprecated, by = "Name") %>%
  left_join(facebook_pluragraph) %>%
  rename(
    Wikipedia_URL = Wikipedia.URL,
    SM_Twitter_user = Twitter_screen_name,
    SM_Twitter_id = Twitter_id,
  ) %>%
  mutate(
    "SM_Twitter_verifiziert" = "",
    "SM_Facebook_verifiziert" = "",
    "SM_Youtube_user" = "",
    "SM_Youtube_id" = "",
    "SM_Youtube_verifiziert" = "",
    "SM_Instagram_user" = "",
    "SM_Instagram_id" = "",
    "SM_Instagram_verifiziert" = "",
    "SM_Telegram_user" = "",
    "SM_Telegram_id" = "",
    "SM_Telegram_verifiziert" = "",
    "Homepage_URL" = "",
    "tags" = "",
    "created_at" = as.character(Sys.time()),
    "created_by" = "admin",
    "modified_at" = as.character(Sys.time()),
    "modified_by" = "admin",
    "id" = uuid::UUIDgenerate(n = n())
  ) %>%
  select(
    id, Parlament, Name, Fraktion, Wahlkreis, Geschlecht, Kommentar, Bild, 
    tags, Wikipedia_URL, Homepage_URL, SM_Twitter_user, SM_Twitter_id, 
    SM_Twitter_verifiziert, SM_Facebook_id, SM_Facebook_user, 
    SM_Facebook_verifiziert, SM_Youtube_user, SM_Youtube_id, 
    SM_Youtube_verifiziert, SM_Instagram_user, SM_Instagram_id, 
    SM_Instagram_verifiziert, SM_Telegram_user, SM_Telegram_id, 
    SM_Telegram_verifiziert, created_at, created_by, modified_at, modified_by
  )




merged_dboes[is.na(merged_dboes)] <- ""

merged_dboes <- apply(merged_dboes, 2, as.character)

write.csv(merged_dboes, file = "../db/reviewed/Parlamentarier.csv", fileEncoding = "UTF-8", row.names = F)


# Hildesheim provided corrected lists
# -----------------------------------

merged_dboes <- read.csv("../db/reviewed/Parlamentarier.csv", encoding = "UTF-8", colClasses = "character")

twitter_corrections <- read.csv("data/feedback_HBI.csv", encoding = "UTF-8", colClasses = "character") %>%
  select(Name, SM_Twitter_id = "Twitter_id", SM_Twitter_user = "Twitter_screen_name")

dups_in_corrections <- twitter_corrections[which(duplicated(twitter_corrections$SM_Twitter_id)), ]
print(dups_in_corrections)

corrected_dboes <- merged_dboes %>%
  left_join(twitter_corrections, by = "Name")
corrected_dboes[!is.na(corrected_dboes$SM_Twitter_id.y), c("SM_Twitter_id.x", "SM_Twitter_user.x")] <- corrected_dboes[!is.na(corrected_dboes$SM_Twitter_id.y), c("SM_Twitter_id.y", "SM_Twitter_user.y")]
corrected_dboes <- corrected_dboes %>%
  select(-SM_Twitter_id.y, -SM_Twitter_user.y) %>%
  rename(SM_Twitter_id = SM_Twitter_id.x, SM_Twitter_user = SM_Twitter_user.x)
  # %>% rename(Kategorie = Parlament, Partei = Fraktion)

lidx <- corrected_dboes$Partei %in% c("LINKE", "Linke", "DIE LINKE")
corrected_dboes$Partei[lidx] <- "LINKE"
lidx <- corrected_dboes$Partei %in% c("GRÜNE", "Grüne")
corrected_dboes$Partei[lidx] <- "GRÜNE"
lidx <- grepl("los", corrected_dboes$Partei)
corrected_dboes$Partei[lidx] <- "fraktionslos"
lidx <- corrected_dboes$Partei == "CDU/CSU (CSU)"
corrected_dboes$Partei[lidx] <- "CSU"
lidx <- corrected_dboes$Partei == "CDU/CSU (CDU)"
corrected_dboes$Partei[lidx] <- "CDU"

print(unique(corrected_dboes$Partei))

corrected_dboes[is.na(corrected_dboes)] <- ""
corrected_dboes <- apply(corrected_dboes, 2, as.character)
write.csv(corrected_dboes, file = "../db/reviewed/Parlamentarier.csv", fileEncoding = "UTF-8", row.names = F)


# Check for further duplicates
# -----------------------------

print(corrected_dboes[grepl("Saskia", corrected_dboes$Name), ])

dboes_db_twitter <- corrected_dboes %>%
  filter(SM_Twitter_id != "" | SM_Twitter_user != "")
twitter_id_dups <- dboes_db_twitter[which(duplicated(dboes_db_twitter$SM_Twitter_id)), c("SM_Twitter_id", "SM_Twitter_user")]
print(twitter_id_dups)

corrected_dboes %>%
  filter(SM_Twitter_id == "", SM_Twitter_user != "")

dboes_db <- corrected_dboes
dboes_db[is.na(dboes_db)] <- ""
dboes_db <- apply(dboes_db, 2, as.character)

View(dboes_db)

write.csv(dboes_db, file = "../db/reviewed/Parlamentarier.csv", fileEncoding = "UTF-8", row.names = F)
