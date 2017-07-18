#####
# brands.R
# 07/18/2017
# from the original data grabs all the brand names from the product_group_code identifiers of interest and their subgroups
#

library(data.table)
products <- fread("~/nielsen_extracts/RMS/Master_Files/Latest/products.tsv", integer64="character")
products <- subset(products, products$upc_ver_uc == 1) # only use version 1

drinks <- c(1508, 507, 2506, 1503, 1006, 1020)
names(drinks) <- c("non-carbonated", "juice", "milk", "carbonated", "coffee", "tea")

for (drink in drinks) {
    print(drink)

    product_group <- subset(products, product_group_code == drink)
    pmcodes <- names(table(product_group$product_module_code))

    for (pmcode in pmcodes) {
    	brands <- names(table(subset(product_group, product_module_code == pmcode)$brand_descr))

	# writes the output as product_group_code then product_module_code
    	write.csv(brands, file=paste0("~/src/purchase-analysis/data/brands-", drink, "-", pmcode, ".txt"), quote=F, row.names=F)
    }
}
