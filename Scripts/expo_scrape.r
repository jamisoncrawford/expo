# EXPO CENTER DATA MERGE

## RStudio Version: 1.1.456
## R Version: 3.5.1
## Windows 10

## Script Version: 1.0
## Updated: 2019-01-16


# CLEAR WORKSPACE; INSTALL/LOAD PACKAGES

rm(list = ls())

if(!require(zoo)){install.packages("zoo")}
if(!require(readr)){install.packages("readr")}
if(!require(tidyr)){install.packages("tidyr")}
if(!require(dplyr)){install.packages("dplyr")}
if(!require(readxl)){install.packages("readxl")}
if(!require(stringr)){install.packages("stringr")}
if(!require(lubridate)){install.packages("lubridate")}

library(zoo)
library(readr)
library(tidyr)
library(dplyr)
library(readxl)
library(stringr)
library(lubridate)


# SET WORKING DIRECTORY; RETRIEVE FILE NAMES

setwd("~/Projects/REIS/Expo Center/Renamed Data")

files <- dir()

# Create `names` from file names

pats <- "^ogs_sb818_|.xlsm$|.xlsx$|$sb818_|[1-9]|_pg_|\\(|\\)"

names <- dir() %>%
  tolower() %>%
  str_replace_all(" ", "_") %>%
  str_replace_all(pats, "") %>%
  str_replace_all("_$", "")

names <- paste(names, 1:length(names), sep = "_")

# Read in and assign custom names

for (i in seq_along(files)){
  assign(names[i], read_excel(files[i]))
}

master <- do.call("bind_rows", mget(names))

rm(list = setdiff(ls(), "master"))


# CACHE OBJECT: "MASTER"

file <- "~/Projects/REIS/Expo Center/expo_merge_cache.rds"

save(master, file = file)

#------------------------------------------------------------------#

# RELOAD OBJECT: "MASTER" (IF NECESSARY)

rm(list = ls())

file <- "~/Projects/REIS/Expo Center/expo_merge_cache.rds"

load(file); rm(file)


# RENAME COLUMNS; COLLAPSE ROWS

colnames(master) <- c(letters, LETTERS[1:8])
master <- master[!(rowSums(is.na(master)) == ncol(master)), ]
master <- master %>% select(a:G)


# EXTRACT WORKERS

groups <- unique(master$a)[c(11, 14, 17, 18, 19, 21)]

workers <- master %>%
  filter(a %in% groups[1:6]|e == "No. of Hours"| a == "Company Name" | 
         a == "EEO 1 Job Categories" | d == "White" | d == "Male" | 
         a == "Company Address")

rm(groups)

# CORRECTIONS

index_min <- which(workers$h == "Black/African American")     # Corrections: "Northern Stud"
index_max <- index_min + 6L

workers[index_min:index_max, 6:33] <- NA

index_min <- which(workers$c == "Robert H. Law, Inc.")
index_max <- index_min + 6L 

workers[index_min:index_max, 2:32] <- workers[index_min:index_max, 3:33]


# RESTRUCTURE DATA: COMPANY "NAME"

workers <- workers %>%
  mutate(name = NA) %>%
  select(name, a:G)          # Initialize "name" variable

for (i in 1:nrow(workers)){
  if (workers$a[i] == "Company Name" & !is.na(workers$a[i])){
    workers$name[i] <- workers$b[i]
  }
}

workers$name <- zoo::na.locf(workers$name)

workers <- workers[-which(workers$a == "Company Name"), ]


# RESTRUCTURE DATA: "MONTH"; ADDING "PROJECT"

workers <- workers %>%
  mutate(ending = NA,
         project = "Expo Center") %>%
  select(project, name, ending, a:G)

workers <- workers %>%
  mutate(date = NA) %>%
  select(project:ending, date, a:G)                          # Initialize "date" column (NA)


# RESTRUCTURE: HEADER ROW(S)

index <- which(workers$a == "EEO 1 Job Categories")[-1]

workers <- workers[-index, ]                                # Remove subheader rows

index <- which(workers$a == "Company Address")
workers <- workers[-index, ]                                # Remove address rows

index <- which(is.na(workers$a))                           # Remove race/sex labels
workers <- workers[-index, ]

rm(index)

workers <- workers %>% 
  mutate(sex = NA, race = NA) %>%
  select(project:date, sex, race, a:G)

races <- c("White", "Black/African American", "Hispanic/Latino", 
           "Asian/Native Hawaiian or Other Pacific Islander", 
           "Native American/Alaskan Native")


white <- workers[, 1:15]                                    # Split by race/sex; common cols
black <- workers[, c(1:9, 16:21)]
hispn <- workers[, c(1:9, 22:27)]
asian <- workers[, c(1:9, 28:33)]
nativ <- workers[, c(1:9, 34:39)]

white$race <- races[1]                                      # Apply "race" values
black$race <- races[2]
hispn$race <- races[3]
asian$race <- races[4]
nativ$race <- races[5]

rm(races)

white_m <- white[, c(1:12)]                                 # Split by "sex" values
white_f <- white[, c(1:9, 13:15)]
black_m <- black[, c(1:12)]
black_f <- black[, c(1:9, 13:15)]
hispn_m <- hispn[, c(1:12)]
hispn_f <- hispn[, c(1:9, 13:15)]
asian_m <- asian[, c(1:12)]
asian_f <- asian[, c(1:9, 13:15)]
nativ_m <- nativ[, c(1:12)]
nativ_f <- nativ[, c(1:9, 13:15)]

rm(white, black, hispn, asian, nativ)

white_m$sex <- "Male"                                       # Apply "sex" values
black_m$sex <- "Male"
hispn_m$sex <- "Male"
asian_m$sex <- "Male"
nativ_m$sex <- "Male"

white_f$sex <- "Female"
black_f$sex <- "Female"
hispn_f$sex <- "Female"
asian_f$sex <- "Female"
nativ_f$sex <- "Female"

rm(master, workers, i, index_min, index_max)

                                                            # Create common names; merge

names(white_m)[7:12] <- c("category", "title", "soc", "employees", "hours", "wages")
names(black_m)[7:12] <- c("category", "title", "soc", "employees", "hours", "wages")
names(hispn_m)[7:12] <- c("category", "title", "soc", "employees", "hours", "wages")
names(asian_m)[7:12] <- c("category", "title", "soc", "employees", "hours", "wages")
names(nativ_m)[7:12] <- c("category", "title", "soc", "employees", "hours", "wages")

names(white_f)[7:12] <- c("category", "title", "soc", "employees", "hours", "wages")
names(black_f)[7:12] <- c("category", "title", "soc", "employees", "hours", "wages")
names(hispn_f)[7:12] <- c("category", "title", "soc", "employees", "hours", "wages")
names(asian_f)[7:12] <- c("category", "title", "soc", "employees", "hours", "wages")
names(nativ_f)[7:12] <- c("category", "title", "soc", "employees", "hours", "wages")

master <- do.call("bind_rows", mget(ls()))

rm(list = setdiff(ls(), "master"))

master <- master %>% 
  filter(category != "EEO 1 Job Categories",
         employees != "Male|Female")                        # Filter obsolete rows

master <- master %>%
  filter(!is.na(employees),
         employees != 0)


# WRITE ROUGH OUTPUT

setwd("~/Projects/REIS/Expo Center")

write_csv(master, "expo_tidy_raw.csv")


# "MASTER" CLASSES

master$wages <- as.double(master$wages)
master$hours <- as.numeric(master$hours)
master$employees <- as.integer(master$employees)


# UNIFORM VARIABLE: "RACE"

master[master$race == "White", "race"] <- "White"
master[master$race == "Black/African American", "race"] <- "Black"
master[master$race == "Hispanic/Latino", "race"] <- "Hispanic"
master[master$race == "Native American/Alaskan Native", "race"] <- "Native"
master[master$race == "Asian/Native Hawaiian or Other Pacific Islander", "race"] <- "Asian"


# ELIMINATE DUPLICATES

index <- which(duplicated(x = master))
master <- master[-index, ]


# UNIFORM VARIABLE: "CATEGORY"

cats <- unique(master$category)

master[master$category == cats[1], "category"] <- "Craft Workers"
master[master$category == cats[2], "category"] <- "Laborers"
master[master$category == cats[3], "category"] <- "Administrative"
master[master$category == cats[4], "category"] <- "Executives"

rm(cats, index)


# REFORMAT COMPANY NAMES: "NAME"

old <- unique(master$name)
new <- c("Pompey Construction", "Ajay Glass",          "Allied Electric",
         "Casler Masonry",      "Christina Steel",     "DJ Rossetti",
         "DJ Rossetti",         "Smith Contractors",   "Martin-Zombek",
         "Steve General",       "Structural Services", "Titan Roofing",
         "Titan Steel",         "XCL Construction",    "Ferraro Pile & Shoring",
         "JJP Slipforming",     "EJ Construction",     "Danforth Company",
         "Kim Industries",      "KSP Painting",        "Ridley Electric",
         "Ridley Electric",     "Robert Law",          "All Ways Concrete",
         "Clark Rigging",       "EM Pfaff & Son",      "Glenn Davis",
         "Land Pro",            "Lupini Construction", "Northern Stud",
         "Ravi Engineering",    "Rommel Fence",        "SRI Fire Sprinkler",
         "Standard Insulating", "Weydman Electric")

for (i in 1:nrow(master)){
  for (j in seq_along(old)){
    if (master$name[i] == old[j] & !is.na(master$name[i])){
      master$name[i] <- new[j]
    }
  }
}

rm(i, j, new, old)

names(master)[4] <- "month"


# WRITE TO CSV

setwd("~/Projects/REIS/Expo Center")

write_csv(master, "expo_tidy.csv")