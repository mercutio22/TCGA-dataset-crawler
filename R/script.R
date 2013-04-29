#!/usr/bin/env Rscript
library(stringr)

#TODO: put this whole section into build.tcga.dataframe function with a 'folder' argument
#the final dataframe should have 217 columns vs 450k rows

#use gzfile instead?
setwd('../tcgawebcrawler/datafiles')
TARs = list.files('.', pattern='*.tar.gz$', full.names=TRUE)
decompress = function(filepath) { system(paste('tar xzvf', filepath,  '-C .')) }
sapply(TARs, decompress)

pattern = 'TCGA-([0-9A-Z]{2})-([0-9A-Z]{4})-(0[0-9]|[1][0-9])([A-Z])-(0[0-9]|[1-9][0-9])([DGHRTWX])-([0-9A-Z]{4})-(\\d{2})'
#TODO: get each matching group into a manifest file
#i.e.: r = str_match(file, pattern); institution = r[2]; pcode =r[5]
files = (list.files(pattern=pattern, full.names=TRUE, recursive=TRUE) )
manifest = data.frame() # will hold metadata
mcolumns = c('Basename','TSS','Participant', 'Sample', 'Vial', 'Portion', 'Analyte', 'Plate', 'Center')
merged = data.frame() #each patient sample's methylation beta value will be added to this
for (file in files) {
    patient = str_extract(file, pattern)
    metadata = as.data.frame(str_match_all(file, pattern))        
    colnames(metadata) = mcolumns
    manifest = rbind.data.frame(manifest, metadata)
    if ( length(merged) == 0) {
        #a regular expression to extract the sample patient code
        dataframe = read.table(file, sep='\t', skip=1, header=TRUE)
        colnames(dataframe)[2] = patient
        merged=dataframe[,c(1,3,4,5,2)]
    }
    else {
        dataframe = read.table(file, sep='\t', skip=1, header=TRUE)
        colnames(dataframe)[2] = patient
        #merged = cbind(merged, dataframe[2])
        merged = merge(merged, dataframe[,1:2], by='Composite.Element.REF')
    }
} 
merged$sd = apply(merged[,5:ncol(merged)],sd)

