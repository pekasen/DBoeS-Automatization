# create a user base then hash passwords with sodium
# then save to an rds file in app directory
pacman::p_load(sodium)

user_base <- data.frame(
  user = c("user1", "user2"),
  password = sapply(c("pass1", "pass2"), sodium::password_store), 
  permissions = c("admin", "standard"),
  name = c("User One", "User Two"),
  stringsAsFactors = FALSE,
  row.names = NULL
)

saveRDS(user_base, "auth_credentials.rds")
