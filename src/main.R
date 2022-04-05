#creates
  #a species occurence map for Pineneedle Milkweed
  #a species distribution model for the present
  #a species distribution model for the future
#Team Pineneedle (Claire, Mila, Moritz)
#Spring 2022


# load packages:
library("spocc")
library("sp")
library("raster")
library("maptools")
library("rgdal")
library("dismo")
library("sf")
library("tidyverse")
library("maps")

#query the data from gbif and inat, include both USA and Mexico
milkweed<-occ(query="Asclepias linaria", from=c("inat", "gbif"), limit=4000, gbifopts = list(year="1950,2021", country=c("US","MX")));
milkweedGBIF <- milkweed$gbif$data$Asclepias_linaria
milkweedINAT <- milkweed$inat$data$Asclepias_linaria

##clean data section
unique(milkweedGBIF$occurrenceStatus) #all present, no need to remove
unique(milkweedGBIF$individualCount) #to see if there are places where count = 0

zeroWeed<-subset(x=milkweedGBIF, individualCount==0)
milkweedGBIF <- anti_join(milkweedGBIF, zeroWeed) # removes places where count =0

# separate the lat and long from location in inat
gbifLocation <- select(milkweedGBIF,c("prov", "latitude", "longitude"))
inatLocation <- select(milkweedINAT, c("location"))

# split into lat and long
inatLocation <- inatLocation %>%
  separate(location, c("latitude", "longitude"), ",")

# make numerical
inatLocation$longitude = as.numeric(inatLocation$longitude)
inatLocation$latitude = as.numeric(inatLocation$latitude)

# add a column that says inat
inatLocation$prov <- "inat"

# now combine the data frames
milkweedCombo <- rbind(gbifLocation, inatLocation)

# remove nas
milkweedCombo <- na.omit(milkweedCombo)

# remove point that is in India 
milkweedCombo <- milkweedCombo %>% filter(longitude < 50)

# remove points that are above 40 deg latitude
milkweedCombo <- milkweedCombo %>% filter(latitude < 40)

# create a csv with the clean data
write_csv(milkweedCombo, "data/milkweedCombo.csv")

## make an occurence map

#find the lat/long bounds of the data
max.lat <- ceiling(max(milkweedCombo$latitude))
min.lat <- floor(min(milkweedCombo$latitude))
max.lon <- ceiling(max(milkweedCombo$longitude))
min.lon <- floor(min(milkweedCombo$longitude))


jpeg(file="output/pineneedleMilkweedspocc.jpg")
data(wrld_simpl)

##### Plot the base map
plot(wrld_simpl, 
     xlim = c(min.lon, max.lon), # sets upper/lower x
     ylim = c(min.lat, max.lat), # sets upper/lower y
     axes = TRUE, 
     col = "grey95",
     main="Pineneedle Milkweed in US and MX",  # a title
     sub="1950-2021" # a caption
)

points(x =milkweedCombo$longitude, 
       y = milkweedCombo$latitude, 
       col = "blue", 
       pch = 20, 
       cex = 0.75)
box()
dev.off()

# SPOCC Mapping Code
source("src/linaria-spocc.R")

# SDM Mapping Code

# Thank you Jeff Oliver for your code (https://github.com/jcoliver/biodiversity-sdm-lesson)

### 1. Run the setup code below 
# This installs libraries, and downloads climate data from bioclim (https://www.worldclim.org/data/bioclim.html)

source(file = "src/setup.R")

### 7. Use the source() command to run both files you created (one at a time)

source("src/linaria-sdm-single.R")

source("src/linaria-future-sdm-single.R")
