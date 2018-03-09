###
# stores.R
#

library(data.table)

# generates a union of all stores from each year's index
root <- "~/nielsen_extracts/RMS/"
years <- c(2006:2015)

annual_store_files <- paste0(root, years, "/Annual_Files/stores_", years, ".tsv")

# load all store data into a list of data.tables
annual_store_data <- list()
for (i in 1:length(annual_store_files)) {
    annual_store_data[[i]] <- fread(annual_store_files[i], integer64="character")

    # sanity check to see if any years are mislabeled
    tmp <- subset(annual_store_data[[i]], year != years[i])
    if (nrow(tmp) > 0) {
       print("ERROR incorrect labeling of years!")
    }
    
    annual_store_data[[i]]$year <- 1
    colnames(annual_store_data[[i]])[which(colnames(annual_store_data[[i]]) == "year")] <- paste0("year_", years[i])
}

# merge all store data by year into a single data.frame
all_stores <- annual_store_data[[1]][, c(1, 6, 2)]
for (i in 2:length(annual_store_files)) {
    all_stores <- merge(all_stores, annual_store_data[[i]][, c(1, 6, 2)], by=c("store_code_uc", "store_zip3"), all=T)
}
all_stores[is.na(all_stores)] <- 0

#write.table(all_stores, file="all_stores.csv", quote=F, sep=",", row.names=F)

# if not writing to output, continue on to get a set of stores that exist across all 10 years
all_stores$years <- apply(all_stores[, 3:12], 1, FUN=sum)
big10 <- subset(all_stores, years == 10)

# nrow(big10)
# [1] 31653


