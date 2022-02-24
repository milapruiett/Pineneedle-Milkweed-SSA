# load packages:

library("spocc")
library("sp")
library("raster")
library("maptools")
library("rgdal")
library("dismo")
library("sf")
library("tidyverse")

#query the data, include both USA and Mexico
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
milkweedUSMX<-anti_join(milkweedUSMX, namilkweed)

#subset the data, choose what is relevant
lessMilkweedUSMX<-select(milkweedUSMX, c(name, longitude, latitude, scientificName, year, month, day, eventDate, individualCount, elevation, stateProvince, countryCode))
write_csv(lessMilkweedUSMX, "lessMilkweedUSMX.csv")

# create a csv with the clean data
read_csv("lessMilkweedUSMX.csv")

## make an occurence map

#find the lat/long bounds of the data
max.lat <- ceiling(max(lessMilkweedUSMX$latitude))
min.lat <- floor(min(lessMilkweedUSMX$latitude))
max.lon <- ceiling(max(lessMilkweedUSMX$longitude))
min.lon <- floor(min(lessMilkweedUSMX$longitude))


jpeg(file="MUSMXspocc.jpg")
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

