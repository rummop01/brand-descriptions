
tmp <- read.csv("acs_brfss_0615.csv", stringsAsFactors=F)
colnames(tmp)[grep("tert", colnames(tmp))] <- paste0("tert_medhhinc_", sprintf("%02d", 6:15))

groups <- c("bmi", "medhhinc", "pct_female", "pct_inlaborforce", "pct_lsHS", "pct_nhwhite", "popcount", "tert_medhhinc")
tmp.adj <- list()

for (i in 1:length(groups)) {
    print(groups[i])

    tmp.sub <- tmp[, c(which(colnames(tmp) == "ZIP_3_DIGIT"), grep(paste0("^", groups[i]), colnames(tmp)))]
    index <- grep(groups[i], colnames(tmp.sub))

    tmp.complete <- data.frame(ZIP_3_DIGIT=NA, var=NA, year=NA)
    for (j in index) {
    	tmp.year <- tmp.sub[, c("ZIP_3_DIGIT", colnames(tmp.sub)[j])]
    	tmp.year <- unique(tmp.year[complete.cases(tmp.year), ])

       	x <- colnames(tmp.year)[2]
    	if (nrow(tmp.year) > 0) {
       	   tmp.year$year <- as.numeric(paste0("20", substr(x, nchar(x)-1, nchar(x))))
       	   colnames(tmp.year)[2] <- "var"

       	   tmp.complete <- rbind(tmp.complete, tmp.year)
    	} else {
       	   print(paste(x, "has no entries?!"))
    	}
    }
    colnames(tmp.complete)[2] <- groups[i]
    tmp.adj[[i]] <- tmp.complete[-1, ]
}

names(tmp.adj) <- groups

#tmp.new <- tmp.adj[[1]]
#for (i in 2:length(tmp.adj)) {
#    print(paste("merging", groups[i]))
#    tmp.new <- merge(tmp.new, tmp.adj[[i]], by=c("ZIP_3_DIGIT", "year"), all=T)    
#}

for (i in 1:length(tmp.adj)) {
    write.csv(tmp.adj[[i]], file=paste0("~/src/purchase-analysis/model/adjust-", groups[i], ".csv"), row.names=F, quote=F)
}

saveRDS(tmp.adj, file="~/src/purchase-analysis/model/acs.rds")
