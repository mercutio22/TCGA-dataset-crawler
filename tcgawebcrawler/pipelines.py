# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES settingh# See: http://doc.scrapy.org/topics/item-pipeline.html

import subprocess
import os
import hashlib

def md5sum(filename):
    m = hashlib.md5()
    with open(filename, 'rb') as data:
        while True:
            block = data.read(8192)
            if not block:
                break
            m.update(block)
    return m.hexdigest()

class GetAndVerify(object):

    def process_item(self, item, spider):
        """ Downloads file and compares md5sum """
        
        url = item['url']
        if not os.path.exists('datafiles/'):
            os.makedirs('datafiles/')
        outfile= os.path.join('datafiles', os.path.basename(url))
        #subprocess.call(['wget', '-O', os.path.join('datafiles/', outfile), url,
        #])
        #aria2 is faster then wget, so we do that:
        a = subprocess.Popen(['aria2c', url, '-o', outfile, '-x', '5', '-j', '5'])
        a.wait()
        md5file = outfile + '.md5'
        md5url = url + '.md5'
        a = subprocess.Popen(['wget', '-O', md5file, md5url])
        a.wait()
        #subprocess.call(['md5sum', '-c', md5])
        calculatedMD5 = md5sum(outfile)
        with open(md5file) as md5info:
            actualMD5, filename = md5info.readline().split()
            if actualMD5 != calculatedMD5:
                os.remove(outfile)
                self.process_item(item, spider)   
        return item
