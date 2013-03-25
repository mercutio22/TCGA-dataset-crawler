# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/topics/items.html

from scrapy.item import Item, Field

class DataSetItem(Item):
    name = Field()
    md5 = Field()
    url = Field()
    level = Field()
    version = Field()

