#####
# brands.R
# 07/18/2017
# from the original data grabs all the brand names from the product_group_code identifiers of interest and their subgroups
#

library(data.table)
products <- fread("~/nielsen_extracts/RMS/Master_Files/Latest/products.tsv", integer64="character")
products <- subset(products, products$upc_ver_uc == 1) # only use version 1

exclude <- read.csv("~/src/purchase-analysis/excluded-20170720.csv", stringsAsFactors=F)

drinks <- c(1508, 507, 2506, 1503, 1006, 1020) # aka product_group_code
names(drinks) <- c("non-carbonated", "juice", "milk", "carbonated", "coffee", "tea")

units.tbl <- data.frame()

for (drink in drinks) {
    print(drink)

    product_group <- subset(products, product_group_code == drink)
    pmcodes <- names(table(product_group$product_module_code))

    pmcodes <- pmcodes[!(pmcodes %in% subset(exclude, product_group_code == drink)$product_module_code)] # exclude 

    unitct <- list()
    for (pmcode in pmcodes) {
    	print(paste0("    ", pmcode)) # debug
    	pmcode.sub <- subset(product_group, product_module_code == pmcode)
	
	unitct[[ pmcode ]] <- table(pmcode.sub$size1_units)
	
	# writes the output as product_group_code then product_module_code
    	brands <- names(table(pmcode.sub$brand_descr))
    	write.csv(brands, file=paste0("~/src/purchase-analysis/data/brands/brands-", drink, "-", pmcode, ".txt"), quote=F, row.names=F)
    }
    
    units <- names(table(products$size1_units))
    units <- as.matrix( units[units != ""] )
    for (ct in unitct) { units <- merge(units, as.matrix(ct), all.x=T, by.x=1, by.y="row.names") }
    units[is.na(units)] <- 0
    colnames(units) <- c("Units", pmcodes)

    write.csv(units, file=paste0("~/src/purchase-analysis/data/units/units-", drink, ".txt"), quote=F, row.names=F)
}
