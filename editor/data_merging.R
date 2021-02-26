require(dplyr)

dboes_deprecated <- read.csv("../db/parliamentarians.csv", encoding = "UTF-8") %>%
  select(-Parlament, -Fraktion)
facebook_pluragraph <- read.csv("data/facebook.csv", encoding = "UTF-8")

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
  df <- read.csv(paste0("../db/new/Parlamentarier/", bl_short, ".csv"), encoding = "UTF-8")
  df$Parlament <- bl
  dboes_scraped <- rbind(dboes_scraped, df)
}

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
    "tags" = "" 
  ) %>%
  select(
    Parlament, Name, Fraktion, Wahlkreis, Geschlecht, Kommentar, Bild, tags, 
    Wikipedia_URL, Homepage_URL, SM_Twitter_user, SM_Twitter_id, SM_Facebook_id, 
    SM_Facebook_user, SM_Twitter_verifiziert, SM_Facebook_verifiziert, 
    SM_Youtube_user, SM_Youtube_id, SM_Youtube_verifiziert, SM_Instagram_user, 
    SM_Instagram_id, SM_Instagram_verifiziert, SM_Telegram_user, SM_Telegram_id, 
    SM_Telegram_verifiziert
  )

merged_dboes[is.na(merged_dboes)] <- ""

merged_dboes <- apply(merged_dboes, 2, as.character)

write.csv(merged_dboes, file = "../db/reviewed/Parlamentarier.csv", fileEncoding = "UTF-8")