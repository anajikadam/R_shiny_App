library(tibble) 
library(sodium)

user_base <- tibble(
  user = c("user1", "user2","anaji", "admin"),
  password = sapply(c("pass1", "pass2","asdfg","123"), sodium::password_store)
)

write.csv(user_base,file = "R/28Sept/user_base.csv", row.names=FALSE)
