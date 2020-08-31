import requests
import unittest
from bs4 import BeautifulSoup
import pandas as pd
import os
import urllist as urls
import configuration as cfg

class wikifetcher_sachsen:

    def __init__(self):
        self.r = requests.get(urls.sachsenURL)

    def get_politicians_landtag_sachsen(self):
        soup_sachsen = BeautifulSoup(self.r.content, "lxml")
        soup_sachsen1 = soup_sachsen.find_all("table")[2]
        soup_sachsen2 = soup_sachsen1.find_all("tr")
        for row in soup_sachsen2
            cols = row.find_all('td')
            cols = [x-text.strip() for x in cols]
            print(cols)


bot = wikifetcher_sachsen()
bot.get_politicians_landtag_sachsen()