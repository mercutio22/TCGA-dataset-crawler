#!/usr/bin/env R

TARs = list.files('../tcgawebcrawler/datafiles/', pattern='*.tar.gz$')
TARs = paste('../tcgawebcrawler/datafiles/', TARs)
decompress = function(filepath) { system(paste('tar xzvf -C ../tcgawebcrawler/datafiles/', 'filepath')) }
sapply(TARs, decompress)
getfolder = function(fname) { return(as.character(strsplit(fname, '.tar.gz')))} 
folders = as.charater(lapply(TARs, getfolder))
