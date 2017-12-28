#####
# plot.R
#

#annual <- readRDS(file="~/src/purchase-analysis/rds/annual.rds")
#weekly <- readRDS(file="~/src/purchase-analysis/rds/weekly.rds")

#drinks <- c(1508, 507, 2506, 1503, 1006, 1020) # aka product_group_code
#names(drinks) <- c("non-carbonated", "juice", "milk", "carbonated", "coffee", "tea")

library(data.table)
# read in all data beverage categories with covariates
alldatabev <- readRDS(file="~/src/purchase-analysis/rds/alldatabev.rds")
alldatabev <- lapply(alldatabev, as.data.table)

# subset so only data without covariates
alldata <- lapply(alldatabev, function(x) { return( x[, c("week_end", "volume", "sales")] ) } )

# reduce to annual and weekly figures
aggregate(x[, c("week_end", "volume", "sales")], as.list(x[, c("week_end")]), FUN=sum)
annual <- lapply(alldatabev, function(x) { print(head(x)); return( aggregate(x[, c("week_end", "volume", "sales")], as.list(x[, c("week_end")]), FUN=sum) ) } )


for (i in 1:length(alldata)) {
    png(filename=paste0("~/src/purchase-analysis/figures/volume-annual-", drinks[i], ".png"), width=1024, height=768)
    plot((volume/10^9) ~ week_end, data=annual[[i]], frame.plot=F, type='l', xlab="Time", ylab=expression(paste("Volume (", 10^9, " Ounces)")), main=paste0(names(drinks)[i], " (", drinks[i], ") Volume Purchased vs Time"), las=1)
    dev.off()

    png(filename=paste0("~/src/purchase-analysis/figures/sales-annual-", drinks[i], ".png"), width=1024, height=768)
    plot((sales/10^6) ~ week_end, data=annual[[i]], frame.plot=F, type='l', xlab="Time", ylab="Sales ($ Million)", main=paste0(names(drinks)[i], " (", drinks[i], ") Sales Generated vs Time"), las=1)
    dev.off()

    png(filename=paste0("~/src/purchase-analysis/figures/volume-weekly-", drinks[i], ".png"), width=1024, height=768)
    plot((volume/10^9) ~ week_end, data=weekly[[i]], frame.plot=F, type='p', pch=20, xlab="Time", ylab=expression(paste("Volume (", 10^9, " Ounces)")), main=paste0(names(drinks)[i], " (", drinks[i], ") Volume Purchased vs Time"), las=1)
    dev.off()

    png(filename=paste0("~/src/purchase-analysis/figures/sales-weekly-", drinks[i], ".png"), width=1024, height=768)
    plot((sales/10^6) ~ week_end, data=weekly[[i]], frame.plot=F, type='p', pch=20, xlab="Time", ylab="Sales ($ Million)", main=paste0(names(drinks)[i], " (", drinks[i], ") Sales Generated vs Time"), las=1)
    dev.off()
}
