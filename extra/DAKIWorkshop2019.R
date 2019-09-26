# RStudio demo (DAKI workshop 27.9.2019)

### Clear the workspace and load packages ###

rm(list = ls())

library(tidyverse) # umbrella package (loads many useful packages)
library(readxl) # can be used to read in Excel files

# library(dplyr)
# library(reshape2)

### Download the data ###

# First, create a folder called data (where we will download things)

# Then download
# Data are from: http://www.kajaani.fi/fi/avoindata

# We use download.file() to download the data
# We then specify a URL and the file destination

download.file(url = "https://github.com/csc-training/R-for-beginners/blob/master/data/kajaani_2017_ostolaskut.xlsx?raw=true",
              destfile = "data/kajaani_2017_ostolaskut.xlsx")

download.file(url = "https://github.com/csc-training/R-for-beginners/blob/master/data/kajaani_2018_ostolaskut.xlsx?raw=true",
              destfile = "data/kajaani_2018_ostolaskut.xlsx")

# Read in the data using read_excel()
# Takes a while... large files.

# "skip = 2" is used to skip first two rows
# In the Excel file, missing values are indicated as "#". In R, missing values are indicated as NA.

ostolaskut2017 <- read_excel("data/kajaani_2017_ostolaskut.xlsx",  na = "#", skip = 2) # 84160 rows, 23 cols
ostolaskut2018 <- read_excel("data/kajaani_2018_ostolaskut.xlsx",  na = "#", skip = 2) # 84777 rows, 23 cols

### Examples of tidying / pre-processing ###

## Fixing typos 
# E.g. in ostolaskut2017, "Tositelajin teksi"
# This can be fixed by accessing the column names using square brackets
colnames(ostolaskut2017)[colnames(ostolaskut2017) == "Tositelajin teksi"] = "Tositelajin teksti"

## Combining tables
# rbind() is one function that can be used to combine data sets (there are several)
# This particular function needs columns to be the same (binds by row)

ostolaskut <- rbind(ostolaskut2017, ostolaskut2018) # 168937 rows! 

## Fixing column names

# First have a look at what's there
colnames(ostolaskut) 
# We can see some problems... 
# (caused by the Excel file having column names typed inside the same cell using two rows)

# A quick solution is to remove the spaces
colnames(ostolaskut) <- make.names(colnames(ostolaskut))
colnames(ostolaskut) # Neater... we still get ".." at times, but can live with that for now!
 
## Filtering examples

# Get local election data from the wider data set
Vaalit <- ostolaskut %>% filter(`Tulosyksikön.nimi` == "Kunnallisvaalit")
head(Vaalit)

# Get data where CSC is included in "Tulosyksikön.nimi"
ostolaskutCSC <- ostolaskut %>% filter(grepl("CSC",
                                             ostolaskut$`Tulosyksikön.nimi`))
head(ostolaskutCSC)

# Examples involving 'group_by' and 'summarize'
# These are functions in the dplyr package (which comes as part of tidyverse)

# Calculating the total "Osto..Netto" for each company
ostolaskut.Yritys <- ostolaskut %>% # notice the 'pipe' (%>%), which is used to chain together commands
  group_by(Yrityksen.nimi) %>% # grouping by company name
  summarize(OstoNetto = sum(Osto..Netto, na.rm = TRUE)) # sum calculation while omitting NAs

ostolaskut.Yritys

# Same as before, but including the accounting period (Tilikausi)
ostolaskut.Yritys.Tilikausi <- ostolaskut %>% 
  group_by(Yrityksen.nimi, Tilikausi) %>% 
  summarize(OstoNetto = sum(Osto..Netto, na.rm = TRUE))

ostolaskut.Yritys.Tilikausi

### Creating plots ####

# We can use the package ggplot2 (also part of the tidyverse) to create figures.

# The general ggplot2 layout is like this:
# ggplot(data = <DATA>, mapping = aes(<MAPPINGS>)) +  <GEOM_FUNCTION>()

ggplot(data = ostolaskut.Yritys,
       mapping = aes(x = Yrityksen.nimi, y = OstoNetto)) +
  geom_col() # there is also a geom_bar, but plots counts on y axis by default.

# The x axis is still looking messy, let's rotate it

ggplot(data = ostolaskut.Yritys,
       mapping = aes(x = Yrityksen.nimi, y = OstoNetto)) +
  geom_col() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# angle changes the text angle
# hjust (and vjust) used to control text justification

