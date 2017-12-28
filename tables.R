###
# tables.R
# 

library(data.table)

alldatabev <- readRDS(file="~/src/purchase-analysis/rds/alldatabev.rds")
alldatabev <- lapply(alldatabev, as.data.table)

# get average total weekly sales and volume across groupings
annual <- lapply(alldatabev, function(x) { aggregate(x[, c("volume", "sales")], x[, c("year")], FUN=mean) } )
medhhinc <- lapply(alldatabev, function(x) { aggregate(x[, c("volume", "sales")], x[, c("year", "medhhinc_tert")], FUN=mean) } )
store_code <- lapply(alldatabev, function(x) { aggregate(x[, c("volume", "sales")], x[, c("year", "channel_code")], FUN=mean) } )

# plot said groupings
annual.w <- lapply(alldatabev, function(x) { aggregate(x[, c("volume", "sales")], x[, c("week_end")], FUN=sum) } )
medhhinc.w <- lapply(alldatabev, function(x) { aggregate(x[, c("volume", "sales")], x[, c("week_end", "medhhinc_tert")], FUN=sum) } )
store_code.w <- lapply(alldatabev, function(x) { aggregate(x[, c("volume", "sales")], x[, c("week_end", "channel_code")], FUN=sum) } )

# save plots to file
png(filename="~/src/purchase-analysis/figures/volume-master.png", width=1024, height=768)
plot(volume/(10^9) ~ week_end, data=annual.w[[1]], type='l', frame.plot=F, las=1,
            main="Total Volume vs. Time", xlab="Time", ylab=expression(paste("Volume (", 10^9, " Ounces)")),
            ylim=c( min(unlist(lapply(annual.w, function(x) { return(min(x$volume)) }))) / (10^9),
                    max(unlist(lapply(annual.w, function(x) { return(max(x$volume)) }))) / (10^9)
                  )
    )
for (i in 1:length(annual.w)) {
    points(annual.w[[i]]$week_end, annual.w[[i]]$volume / (10^9), type='l', col=rainbow(6)[i])
}
legend("bottomleft", legend=names(annual.w), col=rainbow(6), lty=1, box.lty=0)
dev.off()

png(filename="~/src/purchase-analysis/figures/sales-master.png", width=1024, height=768)
plot(sales/(10^6) ~ week_end, data=annual.w[[1]], type='l', frame.plot=F, las=1,
	    main="Total Sales vs. Time", xlab="Time", ylab=expression(paste("Sales (", 10^6, " USD)")),
	    ylim=c( min(unlist(lapply(annual.w, function(x) { return(min(x$sales)) }))) / (10^6),
	    	    max(unlist(lapply(annual.w, function(x) { return(max(x$sales)) }))) / (10^6)
	          )
    )
for (i in 1:length(annual.w)) {
    points(annual.w[[i]]$week_end, annual.w[[i]]$sales / (10^6), type='l', col=rainbow(6)[i])
}
legend("bottomleft", legend=names(annual.w), col=rainbow(6), lty=1, box.lty=0)
dev.off()
