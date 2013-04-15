#!/usr/bin/env Rscript

TARs = list.files('../tcgawebcrawler/datafiles/', pattern='*.tar.gz$', full.names=TRUE)
decompress = function(filepath) { system(paste('tar xzvf', filepath,  '-C ../tcgawebcrawler/datafiles/')) }
sapply(TARs, decompress)
getfolder = function(fname) { return(as.character(strsplit(fname, '.tar.gz')))} 
folders = as.charater(lapply(TARs, getfolder))
