# load packages:

library("spocc")
library("sp")
library("raster")
library("maptools")
library("rgdal")
library("dismo")
library("sf")
library("tidyverse")

#query the data from gbif, include both USA and Mexico
milkweedUS<-occ(query="Asclepias linaria", from="gbif", limit=4000, gbifopts = list(year="1950,2021", country="US"));
milkweedMX<-occ(query="Asclepias linaria", from="gbif", limit=4000, gbifopts = list(year="1950,2021", country="MX"));

USData<-milkweedUS$gbif$data$Asclepias_linaria
MXData<-milkweedMX$gbif$data$Asclepias_linaria


#combine US and MX
milkweedUSMX<-bind_rows(USData, MXData)
milkweedUSMX

##clean data section
unique(milkweedUSMX$occurrenceStatus) #all present, no need to remove
unique(milkweedUSMX$individualCount) #to see if there are places where count = 0

zeroWeed<-subset(x=milkweedUSMX, individualCount==0)
milkweedUSMX <- anti_join(milkweedUSMX, zeroWeed) # removes places where count =0

sort(milkweedUSMX$latitude, decreasing = TRUE) [1:20] #there are places where lat and long =0
sort(milkweedUSMX$longitude, decreasing = TRUE) [1:20]
wronglong<-subset(x=milkweedUSMX, longitude==0) #remove where lat and long =0 
milkweedUSMX<-anti_join(milkweedUSMX, wronglong)

namilkweed<- subset(x=milkweedUSMX, is.na(latitude)) #remove where lat is na. 
milkweedUSMXgbif<-anti_join(milkweedUSMX, namilkweed)

# query inat
milkweedInat<-occ(query="Asclepias linaria", from="inat", limit=4000, gbifopts = list(year="1950,2021"));
milkweedUSMXinat = milkweedInat$inat$data$Asclepias_linaria

# combine the gbif and inat data into one data frame with just lat and
# long to plot
df1 <- select(milkweedUSMXgbif,c("longitude", "latitude"))
df2 <- select(milkweedUSMXinat, "location")

# split into lat and long
df2 <- df2 %>%
  separate(location, c("latitude", "longitude"), ",")

# make numerical
df2$longitude = as.numeric(df2$longitude)
df2$latitude = as.numeric(df2$latitude)

# now combine the data frames
milkweedCombo <- rbind(df1, df2)

#subset the data, choose what is relevant
lessMilkweedUSMX<-select(milkweedUSMX, c(name, longitude, latitude, scientificName, year, month, day, eventDate, individualCount, elevation, stateProvince, countryCode))
write_csv(lessMilkweedUSMX, "data/lessMilkweedUSMX.csv")

# create a csv with the clean data
read_csv("data/lessMilkweedUSMX.csv")

## make an occurence map

#find the lat/long bounds of the data
max.lat <- ceiling(max(lessMilkweedUSMX$latitude))
min.lat <- floor(min(lessMilkweedUSMX$latitude))
max.lon <- ceiling(max(lessMilkweedUSMX$longitude))
min.lon <- floor(min(lessMilkweedUSMX$longitude))


jpeg(file="output/MUSMXspocc.jpg")
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

points(x =lessMilkweedUSMX$longitude, 
       y = lessMilkweedUSMX$latitude, 
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
