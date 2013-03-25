# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/topics/items.html

from scrapy.item import Item, Field

class DataSetItem(Item):
    origin = Field()
    sample = Field()
    platform = Field()
    batch = Field()
    version = Field()
    url = Field()

