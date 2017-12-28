#####
# model.R
# 08/13/2017
#

library(plyr) # join is faster than merge

### first load acs/cov data

### this section for pre-processing my acs covariates file
#acs <- readRDS(file="~/src/purchase-analysis/model/acs.rds") # this is for my version without BMI from 2015
#for (i in 1:length(acs)) {
#    colnames(acs[[i]])[1] <- "store_zip3"
#    rownames(acs[[i]]) <- 1:nrow(acs[[i]])
#
#    var <- colnames(acs[[i]])[2]
#    tmp <- aggregate(acs[[i]][, 2], acs[[i]][, c(1, 3)], FUN=mean)
#    colnames(tmp)[3] <- var
#
#    acs[[i]] <- tmp
#}
#
#adj <- acs[[1]]
#for (i in 2:length(acs)) {
#    print(paste("merging", colnames(acs[[i]])[3]))
#    
#    adj <- join(adj, acs[[i]], by=c("store_zip3", "year"), type="full")
#}   
#saveRDS(adj, file="~/src/purchase-analysis/model/adjust.rds")

### pasquale made the list long so now just read and process
acs <- read.csv("~/src/purchase-analysis/model/covariates_long_0615.csv", stringsAsFactors=F) # using pasquale's long list e-mailed

# read in all data sets to merge with acs/cov data
alldata <- readRDS(file="~/src/purchase-analysis/rds/alldata.rds")

drinks <- c(1508, 507, 2506, 1503, 1006, 1020) # aka product_group_code
#names(drinks) <- c("non-carbonated", "juice", "milk", "carbonated", "coffee", "tea")
names(drinks) <- drinks # set names to value itself

names(alldata) <- names(drinks)

# merge alldata with covariates

alldatacov <- list() # back when we were using my acs file
for (i in 1:length(alldata)) {
    print(paste("merging with covariates for", drinks[i]))

    alldata[[i]]$year <- as.numeric(format(alldata[[i]]$week_end, '%Y'))
    #alldatacov[[i]] <- join(alldata[[i]], adj, type="left", by=c("store_zip3", "year")) # using my acs which is a list called adj
    alldatacov[[i]] <- join(alldata[[i]], acs, type="left", by=c("store_zip3", "year")) # using my acs which is a list called adj
}
names(alldatacov) <- names(alldata)
#saveRDS(alldatacov, file="~/src/purchase-analysis/rds/alldatacov.rds")

# now load the current list of beverages and groupings from the google sheet
beverages <- read.csv("~/src/purchase-analysis/beverage-groupings-20170821.csv", stringsAsFactors=F)
beverages$beverage_category <- gsub(" ", "_", beverages$beverage_category)

bevcat <- unique(beverages$beverage_category)

alldatabev <- list()
for (i in 1:length(bevcat)) {
    print(paste("subsetting", bevcat[i]))

    base <- NULL
    category <- subset(beverages, beverage_category == bevcat[i])
    for (j in 1:nrow(category)) {
    	print(paste(j, "of", nrow(category)))

    	if (is.null(base)) {
    	   base <- subset(alldatacov[[ toString(category$product_group_code[j]) ]], product_module_code == category$product_module_code[j])
	} else {
	   base <- rbind(base, subset(alldatacov[[ toString(category$product_group_code[j]) ]], product_module_code == category$product_module_code[j]) )
	}
	print(paste("    adding", category$product_group_code[j], "-", category$product_module_code[j]))
	print(paste("now at", nrow(base), "rows"))
    }
    print(paste("appending", nrow(base), "total rows"))
    alldatabev[[i]] <- base     
}
names(alldatabev) <- bevcat
#saveRDS(alldatabev, file="~/src/purchase-analysis/rds/alldatabev.rds")

for (i in 1:length(alldatabev)) {
    print(paste("saving", bevcat[i]))
    write.table(alldatabev[[i]], file=paste0("~/src/purchase-analysis/data/beverage-categories/", bevcat[i], ".csv"), quote=F, sep=",", row.names=F)
}

# now actual modeling

#1 unadjusted everything
allunadj.s <- list()
allunadj.v <- list()
for (i in 1:length(alldatabev)) {
    print(paste("modeling", names(alldatabev)[i]))

    allunadj.s[[i]] <- lm(sales  ~ week_end, data=alldatabev[[i]])
    allunadj.v[[i]] <- lm(volume ~ week_end, data=alldatabev[[i]])
}
names(allunadj.s) <- names(alldatabev)
names(allunadj.v) <- names(alldatabev)
#saveRDS(allunadj.s, file="~/src/purchase-analysis/rds/allunadj.s.rds")
#saveRDS(allunadj.v, file="~/src/purchase-analysis/rds/allunadj.v.rds")

#2 adjusted everything
alladj.s <- list()
alladj.v <- list()
for (i in 1:length(alldatabev)) {
    print(paste("modeling", names(alldatabev)[i]))

    alladj.s[[i]] <- lm(sales  ~ week_end + bmi + medhhinc + pct_female + pct_inlaborforce + pct_lsHS + pct_nhwhite + popcount, data=alldatabev[[i]])
    alladj.v[[i]] <- lm(volume ~ week_end + bmi + medhhinc + pct_female + pct_inlaborforce + pct_lsHS + pct_nhwhite + popcount, data=alldatabev[[i]])
}
names(alladj.s) <- names(alldatabev)
names(alladj.v) <- names(alldatabev)
#saveRDS(alladj.s, file="~/src/purchase-analysis/rds/alladj.s.rds")
#saveRDS(alladj.v, file="~/src/purchase-analysis/rds/alladj.v.rds")
