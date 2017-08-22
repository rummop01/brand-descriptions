#####
# aggregate.R
# 08/08/2017
#

options(scipen=999) # turn off scientific notation

library(data.table)

drinks <- c(1508, 507, 2506, 1503, 1006, 1020) # aka product_group_code
names(drinks) <- c("non-carbonated", "juice", "milk", "carbonated", "coffee", "tea")

allfiles <- paste0("~/src/purchase-analysis/data/reduce/", list.files("~/src/purchase-analysis/data/reduce/"))
alldata <- list()

for (i in 1:length(drinks)) {
    subdrinks <- allfiles[grep(paste0("reduce-", sprintf("%04d", drinks[i])), allfiles)]

    data <- data.frame()

    for (drink in subdrinks) {
    	print(paste("Loading", drink))

	tmp <- fread(drink, integer64="character", verbose=F)
	#tmp <- fread(drink, integer64="character", verbose=T, colClasses=list( Date=c("week_end"),
	#numeric=c("product_group_code","product_module_code","store_zip3","volume","sales"),character=c("channel_code","fips_state_descr")))

	tmp$week_end <- as.Date(tmp$week_end)
	tmp$product_group_code <- as.numeric(tmp$product_group_code)
	tmp$product_module_code <- as.numeric(tmp$product_module_code)
	tmp$store_zip3 <- as.numeric(tmp$store_zip3)
	tmp$volume <- as.numeric(tmp$volume)
	tmp$sales <- as.numeric(tmp$sales)

    	data <- rbind(data, tmp)
    }
    
    alldata[[i]] <- data
}
#saveRDS(alldata, file="~/src/purchase-analysis/rds/alldata.rds")

annual <- lapply(alldata, function(x) { print(head(x)); return( aggregate(x[, c("volume", "sales")], x[, c("week_end")], FUN=sum) ) } )
weekly <- annual
vweekly <- lapply(weekly, function(x) { x$week_end <- as.Date(format(x$week_end, format="%m-%d"), format="%m-%d"); return(x) } )
#saveRDS(annual, file="~/src/purchase-analysis/rds/annual.rds")
#saveRDS(weekly, file="~/src/purchase-analysis/rds/weekly.rds")
