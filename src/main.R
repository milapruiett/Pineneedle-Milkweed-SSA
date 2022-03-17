# load packages:

library("spocc")
library("sp")
library("raster")
library("maptools")
library("rgdal")
library("dismo")
library("sf")
library("tidyverse")
library("dplyr")
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

sort(milkweedGBIF$latitude, decreasing = TRUE) [1:20] #there are places where lat and long =0
sort(milkweedGBIF$longitude, decreasing = TRUE) [1:20]
wronglong<-subset(x=milkweedGBIF, longitude==0) #remove where lat and long =0 
milkweedGBIF<-anti_join(milkweedGBIF, wronglong)

namilkweed<- subset(x=milkweedGBIF, is.na(latitude)) #remove where lat is na. 
milkweedGBIF<-anti_join(milkweedGBIF, namilkweed)


# separate the lat and long from location in inat
df1 <- select(milkweedGBIF,c("prov", "latitude", "longitude"))
df2 <- select(milkweedINAT, c("location"))

# split into lat and long
df2 <- df2 %>%
  separate(location, c("latitude", "longitude"), ",")

# make numerical
df2$longitude = as.numeric(df2$longitude)
df2$latitude = as.numeric(df2$latitude)

# add a column that says inat
df2$prov <- "inat"

# now combine the data frames
milkweedCombo <- rbind(df1, df2)

# remove nas
milkweedCombo <- na.omit(milkweedCombo)

# remove point that is in india
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


pdf(file="output/MUSMXspocc.pdf")
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

# SDM Mapping Code

# Thank you Jeff Oliver for your code (https://github.com/jcoliver/biodiversity-sdm-lesson)

########################### 1. Run the setup code below ####################################
# This installs libraries, and downloads climate data from bioclim (https://www.worldclim.org/data/bioclim.html)

source(file = "src/setup.R")

############### 2. In the "src" directory, copy the contents of "run-sdm-single.R" ##############
# into a new file (still in 'src') called <species>-sdm-single.R (Rename <species> to your milkweed)

# 3. In this new file, edit lines 14 & 15, changing MY_SPECIES to your milkwood species.

# 4. Below, write your spocc/gbif query, 
# and then use the "$" notation to create a variable targeting the data set. 

pineneedle<-occ(query='Asclepias linaria', from="gbif", gbifopts = list(year="2020"))

pineneedleData<-pineneedle$gbif$data$Asclepias_linaria

################ 5. Save to CSV #####################

# first, ensure all data is character data
#df <- apply(df,2,as.character)

pineneedleData<-apply(pineneedleData,2,as.character)

# use write.csv to write the data frame to 'data' directory
# make sure the file name matches what you indicated in step 3 on line 14

write.csv(pineneedleData, "data/PineneedleMilkweed.csv")

# 6. Use the source() command to run the file you created in step 2 ############

source("src/pineneedle-sdm-single.R")
