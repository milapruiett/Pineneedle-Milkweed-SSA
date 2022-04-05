# Pineneedle readme
## Overview
- Creating Species Occurence Maps and Species Distribution Models for Species Status Assessment of Monarch Butterflies
- [SSA.md](final SSA)
- Team Pineneedle (Claire, Mila, Moritz), Spring 2022
- With the help of code by Jeff Oliver https://github.com/jcoliver/biodiversity-sdm-lesson


## Dependencies 
The following additional R packages are required (these will be installed by running the setup script, src/setup.R):
- raster
- sp
- dismo
- maptools
- spocc

The following additional R packages are also required (these will be installed by running the first part of the main.R script, src/main.R):
- rgdal
- sf
- tidyverse
- maps

## Structure

+ SSA.md: Species Status Assessment for Monarch Butterfly hostplant Pineneedle Milkweed
+ data
  + wc2-5: climate data at 2.5 minute resolution from [WorldClim](http://www.worldclim.org) (_note_: this folder is not under version control, but will be created by running the setup script (`scripts/setup.R`))
  + cmip5: forcast climate data at 2.5 minute resolution from [WorldClim](http://www.worldclim.org). These data were originally downloaded from the WorldClim website, but stored in the `.RData` format for ease of use. The data are for the year 2070, based on the GFDL-ESM2G model with an RCP of 4.5 CO<sub>2</sub>. For an examination of different forecast models, see [McSweeney et al. 2015](https://link.springer.com/article/10.1007/s00382-014-2418-8).
  + MilkweedCombo.csv: data harvested from [GBIF](https://www.gbif.org/) and INaturalist for _Pineneedle Milkweed_. This dataset is not under version control, but will be harvested by running src/main.R.
+ output (contents are not under version control)
  +
+ src: directory containing R scripts for gathering occurrence data, running forecast models, and creating map outputs.
  + main.R: this queries data from INAT and GBIF, and creates a csv. file from the data. It then produces a species occurence map and a current and future species distribution model
  +

## Running the code
-
-
-
-
