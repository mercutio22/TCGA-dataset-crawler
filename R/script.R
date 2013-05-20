#!/usr/bin/env Rscript
library(stringr)
library(heatmap.plus)


#TODO: put this whole section into build.tcga.dataframe function with a 'folder' argument
#the final dataframe should have 217 columns vs 450k rows

#use gzfile instead?
setwd('../tcgawebcrawler/datafiles')
#TARs = list.files('.', pattern='*.tar.gz$', full.names=TRUE)
#decompress = function(filepath) { system(paste('tar xzvf', filepath,  '-C .')) }
#sapply(TARs, decompress)

#a regular expression to extract the sample patient code
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
#intersect(names(merged), as.character(subset(manifest, Sample!="01")))
#setdiff(names(merged), as.character(subset(manifest, Sample!="01")$Basename))

unfactor = function(x){
    levels(x)[x]
}

SamplesNC = as.numeric(unfactor(manifest$Sample)) #make a copy of the manifest file, keeping the original as character.
#excludes normals and controls, see https://wiki.nci.nih.gov/display/TCGA/TCGA+barcode
TumorMethylation = merged[,5:ncol(merged)] #ignore the preamble
TumorMethylation = TumorMethylation[merged[3] != 'X' | merged[3] != 'Y',] #removes chromosome X or Y probes
tumorFilter = SamplesNC < 10
TumorMethylation = TumorMethylation[,tumorFilter] 
TumorMethylation$sd = apply(TumorMethylation, 1 ,sd, na.rm=TRUE)

svg('hist.svg') #starts a new svg plotting device
histogram <- hist(TumorMethylation$sd, breaks=200)
dev.off()#closes the plotting device

# based on the 'bimodal histogram' we choose to plot only the most differentiated genes as defines by a cut-off value
# which by turn is based on the extrapolation of line leading to the leftmost peak. ##Not very clear, ask Houtan.
# all files saved in tcga.rdata save(file='tcga.rdata',manifest,SamplesNC,SigTumorMethylation,TumorMethylation,pattern)
cutoff = 0.3 #
SigTumorMethylation=TumorMethylation[which(TumorMethylation$sd > cutoff),]
SigTumorMethylation = TumorMethylation[-ncol(TumorMethylation)# removing the sd column] 
# now for plotting the heatmap part:

svg('heat.png')
hmp <- heatmap.plus(
                   as.matrix(SigTumorMethylation),
                   na.rm=TRUE,
                   scale='none',
                   #col=jet.colors(75),
                   symkey=FALSE,
                   density.info="none",
                   trace="none",
                   Rowv=TRUE,
                   Colv=NA,
                   cexRo=1,
                   cexcol=0.6,
                   keysize=1,
                   dendrogram=c("png"),
                   labRow=NA,
                   main=paste('TCGA LGG', ncol(SigTumorMethylation), 'samples', nrow(SigTumorMethylation), 'probes'),
)
dev.off()
