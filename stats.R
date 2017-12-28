
library(data.table)

beverages <- read.csv("~/src/purchase-analysis/beverage-groupings-20170821.csv", stringsAsFactors=F)

allfiles <- list()
storefiles <- c()
years <- c(2006:2015)
for (i in 1:length(years)) {
    allfiles[[i]] <- paste0("~/nielsen_extracts/RMS/", years[i], "/Movement_Files/", sprintf("%04d", beverages$product_group_code), "_", years[i], "/", sprintf("%04d", beverages$product_module_code), "_", years[i], ".tsv")
    storefiles <- c(storefiles, paste0("~/nielsen_extracts/RMS/", years[i], "/Annual_Files/stores_", years[i], ".tsv"))
}

allstores <- list()
for (i in 1:length(storefiles)) {
    print(paste("loading", storefiles[i]))
    allstores[[i]] <- fread(storefiles[i], integer64="character", verbose=F)
}

stores <- c()
#stores.2006 <- c()
for (i in 1:length(allfiles)) {
    print(paste("processing", years[i]))

    for (drinks in allfiles[[i]]) {
    	for (drink in drinks) {
            print(paste("loading", drink))

            tmp <- fread(drink, integer64="character", verbose=F)
	    
	    stores <- unique(c(stores, tmp$store_code_uc))
	}
    }
}

allstores.bak <- allstores
allstores <- lapply(allstores.bak, function(x) { return(subset(x, store_code_uc %in% stores)) } )

stores.master <- allstores[[1]]
for (i in allstores) {
    newstores <- setdiff(i$store_code_uc, stores.master$store_code_uc)
    stores.master <- rbind(stores.master, subset(i, store_code_uc %in% newstores))
}
stores.master <- stores.master[, c("store_code_uc", "store_zip3", "channel_code")]