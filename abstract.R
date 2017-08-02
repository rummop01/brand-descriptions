# 2006
stores_2006 <- read.delim("~/nielsen_extracts/RMS/2006/Annual_Files/stores_2006.tsv", stringsAsFactors=F)
movement_2006_1484 <- fread("~/nielsen_extracts/RMS/2006/Movement_Files/1503_2006/1484_2006.tsv", integer64="character")
movement_2006_1553 <- fread("~/nielsen_extracts/RMS/2006/Movement_Files/1503_2006/1553_2006.tsv", integer64="character")
# 2015
stores_2015 <- read.delim("~/nielsen_extracts/RMS/2015/Annual_Files/stores_2015.tsv", stringsAsFactors=F)
movement_2015_1484 <- fread("~/nielsen_extracts/RMS/2015/Movement_Files/1503_2015/1484_2015.tsv", integer64="character")
movement_2015_1553 <- fread("~/nielsen_extracts/RMS/2015/Movement_Files/1503_2015/1553_2015.tsv", integer64="character")

# only get NYC counties
movement_2006_1484 <- subset(movement_2006_1484, movement_2006_1484$fips_county_descr %in% c("BRONX", "NEW YORK", "RICHMOND", "KING", "QUEENS"))
movement_2006_1553 <- subset(movement_2006_1553, movement_2006_1553$fips_county_descr %in% c("BRONX", "NEW YORK", "RICHMOND", "KING", "QUEENS"))
movement_2015_1484 <- subset(movement_2015_1484, movement_2015_1484$fips_county_descr %in% c("BRONX", "NEW YORK", "RICHMOND", "KING", "QUEENS"))
movement_2015_1553 <- subset(movement_2015_1553, movement_2015_1553$fips_county_descr %in% c("BRONX", "NEW YORK", "RICHMOND", "KING", "QUEENS"))

# merge movement and store files
movement_2006_1484 <- merge(movement_2006_1484, stores_2006[, c("store_code_uc", "fips_county_descr", "channel_code")], by="store_code_uc", all.x=T)
movement_2006_1553 <- merge(movement_2006_1553, stores_2006[, c("store_code_uc", "fips_county_descr", "channel_code")], by="store_code_uc", all.x=T)
movement_2015_1484 <- merge(movement_2015_1484, stores_2015[, c("store_code_uc", "fips_county_descr", "channel_code")], by="store_code_uc", all.x=T)
movement_2015_1553 <- merge(movement_2015_1553, stores_2015[, c("store_code_uc", "fips_county_descr", "channel_code")], by="store_code_uc", all.x=T)

# merge products file with movement-store data
products_1 <- subset(products, products$upc_ver_uc == 1)

movement_2006_1484 <- merge(movement_2006_1484, products_1, by="upc", all.x=T)
movement_2006_1553 <- merge(movement_2006_1553, products_1, by="upc", all.x=T)
movement_2015_1484 <- merge(movement_2015_1484, products_1, by="upc", all.x=T)
movement_2015_1553 <- merge(movement_2015_1553, products_1, by="upc", all.x=T)

# calculate total volume
movement_2006_1484$total_volume <- movement_2006_1484$units * movement_2006_1484$size1_amount * movement_2006_1484$multi
movement_2006_1553$total_volume <- movement_2006_1553$units * movement_2006_1553$size1_amount * movement_2006_1553$multi
movement_2015_1484$total_volume <- movement_2015_1484$units * movement_2015_1484$size1_amount * movement_2015_1484$multi
movement_2015_1553$total_volume <- movement_2015_1553$units * movement_2015_1553$size1_amount * movement_2015_1553$multi

# calculate summary statistics on total_volume
summary(movement_2006_1484$total_volume)
sd(movement_2006_1484$total_volume)
summary(movement_2006_1553$total_volume)
sd(movement_2006_1553$total_volume)

summary(movement_2015_1484$total_volume)
sd(movement_2015_1484$total_volume)
summary(movement_2015_1553$total_volume)
sd(movement_2015_1553$total_volume)

# repeat summary stats in total_volume per channel_code family
for(i in names(channel_code)) { print(i); print(summary(subset(movement_2006_1484, movement_2006_1484$channel_code == i)$total_volume)) }
for(i in names(channel_code)) { print(i); print(sd(subset(movement_2006_1484, movement_2006_1484$channel_code == i)$total_volume)) }
for(i in names(channel_code)) { print(i); print(summary(subset(movement_2006_1553, movement_2006_1553$channel_code == i)$total_volume)) }
for(i in names(channel_code)) { print(i); print(sd(subset(movement_2006_1553, movement_2006_1553$channel_code == i)$total_volume)) }

for(i in names(channel_code)) { print(i); print(summary(subset(movement_2015_1484, movement_2015_1484$channel_code == i)$total_volume)) }
for(i in names(channel_code)) { print(i); print(sd(subset(movement_2015_1484, movement_2015_1484$channel_code == i)$total_volume)) }
for(i in names(channel_code)) { print(i); print(summary(subset(movement_2015_1553, movement_2015_1553$channel_code == i)$total_volume)) }
for(i in names(channel_code)) { print(i); print(sd(subset(movement_2015_1553, movement_2015_1553$channel_code == i)$total_volume)) }

# t-tests
t.test(c(movement_2006_1484$total_volume, movement_2006_1553$total_volume), c(movement_2015_1484$total_volume,  movement_2015_1553$total_volume))

for (i in names(channel_code)) { print(i); print( t.test(c(subset(movement_2006_1484, movement_2006_1484$channel_code == i)$total_volume, subset(movement_2006_1553, movement_2006_1553$channel_code == i)$total_volume), c(subset(movement_2015_1484, movement_2015_1484$channel_code == i)$total_volume, subset(movement_2015_1553, movement_2015_1553$channel_code == i)$total_volume)) ) }

t.test(movement_2006_1484$total_volume, movement_2015_1484$total_volume)

for (i in names(channel_code)) { print(i); print( t.test(subset(movement_2006_1484, movement_2006_1484$channel_code == i)$total_volume, subset(movement_2015_1484, movement_2015_1484$channel_code == i)$total_volume) ) }

t.test(movement_2006_1553$total_volume, movement_2015_1553$total_volume)

for (i in names(channel_code)) { print(i); print( t.test(subset(movement_2006_1553, movement_2006_1553$channel_code == i)$total_volume, subset(movement_2015_1553, movement_2015_1553$channel_code == i)$total_volume) ) }
