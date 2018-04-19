###
# analysis.R
#

options(scipen=999) # turn off scientific notation

# load in all stores and get list of stores available over 10 years
source("~/src/purchase-analysis/stores/stores.R")

# regenerate include file with file paths of universe of drinks we care about
drinks <- read.csv("~/src/purchase-analysis/beverage-groupings-20170821.csv", stringsAsFactors=F)

include_annual <- list()
for (i in 1:length(years)) {
    include <- c()
    for (j in 1:nrow(drinks)) { 
    	include <- c(include, paste0("~/nielsen_extracts/RMS/", years[i], "/Movement_Files/", sprintf("%04d", drinks$product_group_code[j]), "_", years[i], "/", sprintf("%04d", drinks$product_module_code[j]) ,"_", years[i], ".tsv"))
    }
    include_annual[[i]] <- include
}
names(include_annual) <- years

write.table(unlist(include_annual, use.names=F), file="~/src/purchase-analysis/stores/include.txt", quote=F, sep=",", col.names=F, row.names=F)

big10 <- subset(all_stores, all_stores$years_all == 10) 
drink10 <- big10[, 1:2]
for (i in 1:length(years)) {
    drink10[, paste0("year_", years[i])] <- 0 # assume store doesn't sell drinks unless proven otherwise
    for (j in 1:length(include_annual[[i]])) {
    	print(paste("loading", include_annual[[i]][j]))
    	tmp <- fread(include_annual[[i]][j], integer64="character", verbose=F)
	tmp <- subset(tmp, tmp$store_code_uc %in% drink10$store_code_uc)
	stores_annual <- unique(tmp$store_code_uc)
	
	drink10[drink10$store_code_uc %in% stores_annual, paste0("year_", years[i])] <- 1 # tabulate if store exists this year out of stores we have 10 year data for
    }
}

drink10$years_drink <- apply(drink10[, 3:12], 1, FUN=sum)
write.table(drink10, file="~/src/purchase-analysis/stores/drink10.csv", quote=F, sep=",", row.names=F)

all_stores$years_all <- ifelse(all_stores$years_all == 10, 1, 0)
drink10$years_drink <- ifelse(drink10$years_drink == 10, 1, 0)

excel <- merge(all_stores[, c("store_code_uc", "store_zip3", "fips_state_code", "fips_state_descr", "fips_county_code", "fips_county_descr", "years_all")], drink10[, c("store_code_uc", "store_zip3", "years_drink")], by=c("store_code_uc", "store_zip3"), all.x=T)
excel$years_drink[is.na(excel$years_drink)] <- 0

write.table(excel, file="~/src/purchase-analysis/stores/excel.csv", quote=F, sep=",", row.names=F)
