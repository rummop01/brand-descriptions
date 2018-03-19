#!/usr/bin/env Rscript

#####
# reduce.R
# 08/01/2017
# TBD
#

args <- commandArgs(trailingOnly=TRUE)

# derive information from file path and name
drink <- args[1]
year <- unlist(strsplit(drink, "/"))[4]
pgcode <- strsplit(unlist(strsplit(drink, "/"))[6], "_")[[1]][1]
pmcode <- strsplit(unlist(strsplit(drink, "/"))[7], "_")[[1]][1]

library(data.table)

print(paste("Processing", pgcode, "and", pmcode, "from", year))

print(paste("Reading in store file from", year))
store <- fread(paste0("~/nielsen_extracts/RMS/", year, "/Annual_Files/stores_", year, ".tsv"), integer64="character")

print("Reading in master products file")
products <- fread("~/nielsen_extracts/RMS/Master_Files/Latest/products.tsv", integer64="character")
products <- subset(products, products$upc_ver_uc == 1) # only use version 1

print(paste("Reading in movement file", drink))
movement <- fread(drink, integer64="character")
movement$feature <- NULL
movement$display <- NULL
movement$week_end <- as.Date(as.character(movement$week_end), format="%Y%m%d")

# new code to subset data to those of which stores exist across all 10 years
big10 <- read.csv("~/src/purchase-analysis/stores/excel.csv", stringsAsFactors=F)
movement <- subset(movement, movement$store_code_uc %in% subset(big10, big10$years_drink == 1)$store_code_uc)

print("Merging movement and products files")
movement <- merge(movement, products[, c("upc", "product_group_code", "product_module_code", "multi", "size1_amount", "size1_units")], by="upc", all.x=T)
movement <- subset(movement, size1_units == "OZ")
movement$size1_units <- NULL

# subset here since merge introduces some extra products
movement <- subset(movement, product_group_code == as.integer(pgcode) & product_module_code == as.integer(pmcode))

# generate values we care about
movement$volume <- movement$units * movement$size1_amount * movement$multi
movement$sales <- (movement$units / movement$prmult) * movement$price

movement$units <- NULL
movement$prmult <- NULL
movement$price <- NULL
movement$multi <- NULL
movement$size1_amount <- NULL
movement$upc <- NULL

print("Merging movement and store information")
movement <- merge(movement, store[, c("store_code_uc", "channel_code", "store_zip3", "fips_state_descr")], by="store_code_uc", all.x=T)
movement$store_code_uc <- NULL

print("Performing final aggregation")
final <- aggregate(movement[, c("volume", "sales")], movement[, c("week_end", "product_group_code", "product_module_code", "channel_code", "store_zip3", "fips_state_descr")], FUN=sum)

print("Writing data to csv")
write.table(final, file=paste0("~/src/purchase-analysis/data/reduce/reduce-", pgcode, "-", pmcode, "-", year, ".csv"), quote=F, sep=",", row.names=F)

print("This job completed!")
