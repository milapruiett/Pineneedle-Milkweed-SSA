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

##query the data from gbif and inat, include both USA and Mexico##
milkweed<-occ(query="Asclepias linaria", from=c("inat", "gbif"), limit=4000, gbifopts = list(year="1950,2021", country=c("US","MX")));
milkweedGBIF <- milkweed$gbif$data$Asclepias_linaria
milkweedINAT <- milkweed$inat$data$Asclepias_linaria

##make GBIF and INAT data ready to be merged##

# initial check of the GBIF data
unique(milkweedGBIF$occurrenceStatus) #all present, no need to remove
unique(milkweedGBIF$individualCount) #to see if there are places where count = 0

# removing places where count =0 in GBIF data
zeroWeed<-subset(x=milkweedGBIF, individualCount==0)
milkweedGBIF <- anti_join(milkweedGBIF, zeroWeed)

# select only longitude and latitude  from GBIF data
gbifLocation <- select(milkweedGBIF,c("prov", "latitude", "longitude"))

# select only location from INAT data
inatLocation <- select(milkweedINAT, c("location"))

# split location into longitude and latitude in INAT data
inatLocation <- inatLocation %>%
  separate(location, c("latitude", "longitude"), ",")

# make sure longitude and latitude data in INAT is numerical
inatLocation$longitude = as.numeric(inatLocation$longitude)
inatLocation$latitude = as.numeric(inatLocation$latitude)

# add a column that says inat
inatLocation$prov <- "inat"

## combine the data frames of INAT and GBIF## 
milkweedCombo <- rbind(gbifLocation, inatLocation)

# remove any rows where there are NAs in longitude or latitude is NA
milkweedCombo <- na.omit(milkweedCombo)

# remove points where latitude is far outside of US or Mexico
milkweedCombo <- milkweedCombo %>% filter(latitude < 50)
milkweedCombo <- milkweedCombo %>% filter(latitude > 10)

# remove points where longitude is far outside of US or Mexico
milkweedCombo <- milkweedCombo %>% filter(longitude > -130)
milkweedCombo <- milkweedCombo %>% filter(longitude < -60)

# create a csv with the combined data, includes source, longitude and latitude
write_csv(milkweedCombo, "data/milkweedCombo.csv")

## make an occurence map from the data ## 

#find the lat/long bounds of the data
max.lat <- ceiling(max(milkweedCombo$latitude))
min.lat <- floor(min(milkweedCombo$latitude))
max.lon <- ceiling(max(milkweedCombo$longitude))
min.lon <- floor(min(milkweedCombo$longitude))

jpeg(file="output/pineneedleMilkweedspocc.jpg")
data(wrld_simpl)

#Plot the base map
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

## SPOCC Mapping Code ## 
source("src/linaria-spocc.R")

# SDM Mapping Code

# Thank you Jeff Oliver for your code (https://github.com/jcoliver/biodiversity-sdm-lesson)

### 1. Run the setup code below 
# This installs libraries, and downloads climate data from bioclim (https://www.worldclim.org/data/bioclim.html)

source(file = "src/setup.R")

### 7. Use the source() command to run both files you created (one at a time)

source("src/linaria-sdm-single.R")

source("src/linaria-future-sdm-single.R")
