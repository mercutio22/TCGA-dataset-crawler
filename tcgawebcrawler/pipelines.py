# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES settingh# See: http://doc.scrapy.org/topics/item-pipeline.html

import subprocess
import os.path
import hashlib

def md5sum(filename):
    m = hashlib.md5()
    with open(filename) as data:
        m.update(data.read())
        return m.hexdigest()

class GetAndVerify(object):

    def process_item(self, item, spider):
        """ Downloads file and compares md5sum """
        
        url = item['url']
        outfile= os.path.join('datafiles', os.path.basename(url))
        #subprocess.call(['wget', '-O', os.path.join('datafiles/', outfile), url,
        #])
        subprocess.call(['aria2c', url, '-o', outfile, '-x', '5', '-j', '5'])
        md5file = outfile + '.md5'
        md5url = url + '.md5'
        subprocess.call(['wget', '-O', md5url, md5url])
        #subprocess.call(['md5sum', '-c', md5])
        calculatedMD5 = md5sum(outfile)
        with open(md5file) as md5info:
            actualMD5, filename = md5info.readline().split()
        if actualMD5 != calculatedMD5:
            self.process_item(item, spider)   
        return item
