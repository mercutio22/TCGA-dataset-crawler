#!/usr/bin/env Rscript
library(stringr)

#TODO: put this whole section into build.tcga.dataframe function with a 'folder' argument

TARs = list.files('../tcgawebcrawler/datafiles/', pattern='*.tar.gz$', full.names=TRUE)
decompress = function(filepath) { system(paste('tar xzvf', filepath,  '-C ../tcgawebcrawler/datafiles/')) }
sapply(TARs, decompress)
getfolder = function(fname) { return(as.character(strsplit(fname, '.tar.gz')))} 
folders = as.character(lapply(TARs, getfolder))

build.batch.dataframe = function(folder) {
    files = (list.files(folder, pattern='*TCGA*', full.names=TRUE) )
    merged = data.frame() #each patient sample's methylation beta value will be added to this
    for (file in files) {
        #a regular expression to extract the sample patient code
        patient = str_extract(file, "TCGA-(\\d+)-(\\d+)-(\\d+[A-Z]+)-(\\d+[A-Z]+)-(\\d+)-(\\d+)")
        dataframe = read.table(files, sep='\t', skip=1, header=TRUE)
        #TODO: merge data frames
    } 
} 





