from scrapy.spider import BaseSpider
from scrapy.selector import HtmlXPathSelector                                   
from tcgawebcrawler.items import DataSetItem   
import re

class TcgascrapperSpider(BaseSpider):
    name = "tcgaCrawler"
    allowed_domains = ["https://tcga-data.nci.nih.gov/tcgafiles/ftp_auth/"
    "distro_ftpusers/anonymous/tumor/lgg/cgcc/jhu-usc.edu/humanmethylation450"
    "/methylation/"]
    start_urls = (
        'http://www.https://tcga-data.nci.nih.gov/tcgafiles/ftp_auth/'
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
            \.(?P<experiment>.*)  # dot, experimental platform                  
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
                datum['url'] = response.url + link                              
                items.append(datum)
        return items   
