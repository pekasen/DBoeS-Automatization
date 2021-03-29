require(dplyr)

# SQL for Pluragraph data:
# select p.name as Name, p.id_at_service as SM_Facebook_id, p.identifier as SM_Facebook_user from profiles p where p.type = 'Service::Facebook::Profile' and p.organisation_id in (select organisation_id from organisation_categories oc where oc.category_id in (select c.id from categories c where c."name" like '%Md%'));

dboes_deprecated <- read.csv("../db/parliamentarians.csv", encoding = "UTF-8") %>%
  select(-Parlament, -Fraktion)
facebook_pluragraph <- read.csv("data/facebook.csv", encoding = "UTF-8", colClasses = "character")

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
    "tags" = "",
    "created_at" = Sys.time(),
    "created_by" = "admin",
    "modified_at" = Sys.time(),
    "modified_by" = "admin",
    "uuid" = uuid::UUIDgenerate(n = n())
  ) %>%
  select(
    uuid, Parlament, Name, Fraktion, Wahlkreis, Geschlecht, Kommentar, Bild, 
    tags, Wikipedia_URL, Homepage_URL, SM_Twitter_user, SM_Twitter_id, 
    SM_Facebook_id, SM_Facebook_user, SM_Twitter_verifiziert, 
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

merged_dboes <- read.csv("../db/reviewed/Parlamentarier.csv", encoding = "UTF-8", colClasses = c("created_at" = "character", "modified_at" = "character"))

twitter_corrections <- read.csv("data/feedback_HBI.csv", encoding = "UTF-8") %>%
  select(Name, SM_Twitter_id = "Twitter_id", SM_Twitter_user = "Twitter_screen_name")
  
corrected_dboes <- merged_dboes %>%
  left_join(twitter_corrections, by = "Name")
corrected_dboes[!is.na(corrected_dboes$SM_Twitter_id.y), c("SM_Twitter_id.x", "SM_Twitter_user.x")] <- corrected_dboes[!is.na(corrected_dboes$SM_Twitter_id.y), c("SM_Twitter_id.y", "SM_Twitter_user.y")]
corrected_dboes <- corrected_dboes %>%
  select(-SM_Twitter_id.y, -SM_Twitter_user.y) %>%
  rename(SM_Twitter_id = SM_Twitter_id.x, SM_Twitter_user = SM_Twitter_user.x) %>%
  rename(Kategorie = Parlament, Partei = Fraktion)

corrected_dboes[is.na(corrected_dboes)] <- ""
corrected_dboes <- apply(corrected_dboes, 2, as.character)
write.csv(corrected_dboes, file = "../db/reviewed/Parlamentarier.csv", fileEncoding = "UTF-8", row.names = F)


# Correct R read.csv corruption
# -----------------------------

deprecated_dboes <- read.csv("../db/parliamentarians.csv", encoding = "UTF-8")
deprecated_dboes$Twitter_id <- as.character(deprecated_dboes$Twitter_id)

deprecated_dboes_correct_id <- read.csv("../db/parliamentarians.csv", encoding = "UTF-8", colClasses = c("Twitter_id" = "character"))

corrupted_ids_idx <- which(deprecated_dboes_correct_id$Twitter_id != deprecated_dboes$Twitter_id)
View(deprecated_dboes_correct_id[corrupted_ids_idx, ])


dboes_db <- read.csv(
  "../db/reviewed/Parlamentarier.csv", 
  encoding = "UTF-8", 
  colClasses = "character"
) 

require(dplyr)
tmp <- dboes_db %>%
  left_join(deprecated_dboes_correct_id, by = "Name") %>%
  select("Name", "SM_Twitter_user", "SM_Twitter_id", "Twitter_id") %>%
  mutate(cmp = SM_Twitter_id == Twitter_id) %>%
  # filter(cmp == F) %>%
  mutate(id_deprecated = as.numeric(stringr::str_sub(Twitter_id, -10)), id_corrupt = as.numeric(stringr::str_sub(SM_Twitter_id, -10))) %>%
  mutate(diff = as.integer(id_corrupt - id_deprecated))
View(tmp)

# copy old ids with negative difference
dboes_db[which(tmp$diff < 0), "SM_Twitter_id"] <- tmp$Twitter_id[which(tmp$diff < 0)]

# copy old ids where new ones contain nothing
idx <- which(tmp$Twitter_id != "" & tmp$SM_Twitter_id == "")
dboes_db[idx, "SM_Twitter_id"] <- tmp$Twitter_id[idx]

# what about those where we habe a new id, but no old one?
idx <- which((is.na(tmp$Twitter_id) | tmp$Twitter_id == "") & tmp$SM_Twitter_id != "")
View(tmp[idx, ])

# username <- "dguenther_cdush"
# cmd <- paste0('curl "https://tweeterid.com/ajax.php" -s -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:87.0) Gecko/20100101 Firefox/87.0" -H "Accept: */*" -H "Accept-Language: de,en-US;q=0.7,en;q=0.3" -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" -H "X-Requested-With: XMLHttpRequest" -H "Origin: https://tweeterid.com" -H "Connection: keep-alive" -H "Referer: https://tweeterid.com/?twitter=DGuenther_CDUSH" -H "Cookie: __utma=116903043.982186121.1617029240.1617043795.1617045750.3; __utmc=116903043; __utmz=116903043.1617043795.2.2.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not"%"20provided); __gads=ID=3f15205ef6c88336-225b30b93aa70069:T=1617029240:RT=1617029240:S=ALNI_Mani82iy--9DgkPTmX_qN5cm8oPXw; __utmb=116903043.1.10.1617045750; __utmt=1" --data-raw "input=',username,'"')
# res <- system(cmd, intern = T)

df <- data.frame()
for (i in idx) {
  username <- tmp[i, "SM_Twitter_user"]
  cmd <- paste0('curl "https://tweeterid.com/ajax.php" -s -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:87.0) Gecko/20100101 Firefox/87.0" -H "Accept: */*" -H "Accept-Language: de,en-US;q=0.7,en;q=0.3" -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" -H "X-Requested-With: XMLHttpRequest" -H "Origin: https://tweeterid.com" -H "Connection: keep-alive" -H "Referer: https://tweeterid.com/?twitter=DGuenther_CDUSH" -H "Cookie: __utma=116903043.982186121.1617029240.1617043795.1617045750.3; __utmc=116903043; __utmz=116903043.1617043795.2.2.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not"%"20provided); __gads=ID=3f15205ef6c88336-225b30b93aa70069:T=1617029240:RT=1617029240:S=ALNI_Mani82iy--9DgkPTmX_qN5cm8oPXw; __utmb=116903043.1.10.1617045750; __utmt=1" --data-raw "input=',username,'"')
  res <- system(cmd, intern = T)
  df <- rbind(df, data.frame(
    "SM_Twitter_user" = username,
    "SM_Twitter_id" = res
  ))
  Sys.sleep(1)
  print(i)
}

lidx <- dboes_db$SM_Twitter_user %in% df$SM_Twitter_user
dboes_db$SM_Twitter_id[lidx] <- df$SM_Twitter_id
View(dboes_db)
# errors: dieGrueneWahl, hermiworld

library(tidyr)
# id ohne username
idx <-  which(dboes_db$SM_Twitter_id != "" & dboes_db$SM_Twitter_user == "")
View(dboes_db[idx, ])
df <- data.frame()
for (i in idx) {
  id <- dboes_db[i, "SM_Twitter_id"]
  cmd <- paste0('curl "https://tweeterid.com/ajax.php" -s -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:87.0) Gecko/20100101 Firefox/87.0" -H "Accept: */*" -H "Accept-Language: de,en-US;q=0.7,en;q=0.3" -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" -H "X-Requested-With: XMLHttpRequest" -H "Origin: https://tweeterid.com" -H "Connection: keep-alive" -H "Referer: https://tweeterid.com/?twitter=DGuenther_CDUSH" -H "Cookie: __utma=116903043.982186121.1617029240.1617043795.1617045750.3; __utmc=116903043; __utmz=116903043.1617043795.2.2.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not"%"20provided); __gads=ID=3f15205ef6c88336-225b30b93aa70069:T=1617029240:RT=1617029240:S=ALNI_Mani82iy--9DgkPTmX_qN5cm8oPXw; __utmb=116903043.1.10.1617045750; __utmt=1" --data-raw "input=',id,'"')
  res <- system(cmd, intern = T)
  
  new_id <- id
  
  if (res == "error") {
    id_splitted <- strsplit(id, "")[[1]]
    last_nr <- as.numeric(id_splitted[length(id_splitted)]) + 1
    if (last_nr == 10) last_nr <- 0
    id_splitted[length(id_splitted)] <- last_nr
    new_id <- as.character(paste0(id_splitted, collapse = ""))
    cmd <- paste0('curl "https://tweeterid.com/ajax.php" -s -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:87.0) Gecko/20100101 Firefox/87.0" -H "Accept: */*" -H "Accept-Language: de,en-US;q=0.7,en;q=0.3" -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" -H "X-Requested-With: XMLHttpRequest" -H "Origin: https://tweeterid.com" -H "Connection: keep-alive" -H "Referer: https://tweeterid.com/?twitter=DGuenther_CDUSH" -H "Cookie: __utma=116903043.982186121.1617029240.1617043795.1617045750.3; __utmc=116903043; __utmz=116903043.1617043795.2.2.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not"%"20provided); __gads=ID=3f15205ef6c88336-225b30b93aa70069:T=1617029240:RT=1617029240:S=ALNI_Mani82iy--9DgkPTmX_qN5cm8oPXw; __utmb=116903043.1.10.1617045750; __utmt=1" --data-raw "input=',new_id,'"')
    res <- system(cmd, intern = T)
  }
  
  df <- rbind(df, data.frame(
    "SM_Twitter_user" = res,
    "SM_Twitter_id" = new_id,
    "SM_Twitter_old_id" = id
  ))
  Sys.sleep(1)
  print(i)
}
df[df$SM_Twitter_user=="error", "SM_Twitter_user"] <- ""
lidx <- dboes_db$SM_Twitter_id %in% df$SM_Twitter_old_id
dboes_db$SM_Twitter_user[lidx] <- df$SM_Twitter_user
View(dboes_db)
# errors: 

# facebook
dboes_db2 <- dboes_db %>%
  select(-c("SM_Facebook_id", "SM_Facebook_user")) %>%
  left_join(facebook_pluragraph, by = "Name") %>%
  relocate(SM_Facebook_id, SM_Facebook_user, .after = SM_Twitter_verifiziert) %>%
  mutate(SM_Twitter_user = gsub("@", "", SM_Twitter_user))
View(dboes_db2)

db_to_save[is.na(dboes_db2)] <- ""
db_to_save <- apply(dboes_db2, 2, as.character)
write.csv(dboes_db2, file = "../db/reviewed/Parlamentarier.csv", fileEncoding = "UTF-8", row.names = F)
