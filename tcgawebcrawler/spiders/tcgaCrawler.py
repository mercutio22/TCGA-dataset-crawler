from scrapy.spider import BaseSpider
from scrapy.selector import HtmlXPathSelector                                   
from tcgawebcrawler.items import DataSetItem   
import re

class TcgascrapperSpider(BaseSpider):
    name = "tcgaCrawler"
    allowed_domains = ["tcga-data.nci.nih.gov/"]
    start_urls = (
        'https://tcga-data.nci.nih.gov/tcgafiles/ftp_auth/'
        'distro_ftpusers/anonymous/tumor/lgg/cgcc/jhu-usc.edu/'
        'humanmethylation450/methylation/',
        )

    def parse(self, response):                                                  
        hxs = HtmlXPathSelector(response)                                       
        #all interesting link hrefs starts with "jhu-usc"                       
        links = hxs.select('//a[starts-with(@href, "jhu-usc")]')                
        #I am interested only in the hrefs so drop text, tags, etc              
        links = links.select('@href')                                           
        items = [] #this list will store all datasets                           
        pattern = re.compile("""                                                
            ^(?P<origin>.*)          # it always starts by lab name followed by 
            _(?P<sample>[A-Z]+)   # undeline, sample type in capitals           
            \.(?P<platform>.*)  # dot, experimental platform                  
            \.Level_3  # dot, level. I want level 3: processed data             
            \.(?P<batch>\d+)      # dot, batch number                           
            \.(?P<version>\d+\.\d+)          # dot, version number              
            \.tar\.gz$""",                                                      
            re.VERBOSE #allows commenting a regular expression                  
            )
        for link in links:                                                      
            match = pattern.match(link.extract())                               
            if match:                                                           
                #get all the info                                               
                datum = DataSetItem(**match.groupdict())                        
                #adding the the url for future reference                        
                datum['url'] = response.url + link.extract()
                items.append(datum)
        
        # order by batch and keep only most updated version items:
        items.sort(key=lambda item: 
                ( float(item['batch']), -float(item['version']) ) 
            )
        batches = set()
        # iterate a 'items' copy and remove the obsolete items for each batch
        for item in items[:]:  # 
            if item['batch'] in batches:
                items.remove(item)
            else:
                batches.add(item['batch'])
        return items   
