from selenium import webdriver
from selenium.webdriver.firefox.options import Options
import unittest
from bs4 import BeautifulSoup
import pandas as pd
import os
import urllist as urls
import configuration as cfg

class wikifetcher_sachsen:

    def __init__(self):
        options = Options()
        options.headless = False
        self.driver = webdriver.Firefox(options=options)

    def get_politicians_landtag_sachsen(self):
    	self.driver.get(urls.sachsenUrl)
    	soup_sachsen = BeautifulSoup(self.driver.page_source, "lxml")
    	soup_sachsen1 = soup_sachsen.find_all("tbody")[2]
    	soup_sachsen2 = soup_sachsen1.find_all("tr")
    	for row in soup_sachsen2:
    		cols = row.find_all('td')
    		cols = [x.text.strip() for x in cols]
    		print(cols)

    def quit(self):
        self.driver.quit()


bot = wikifetcher_sachsen()
bot.get_politicians_landtag_sachsen()
bot.quit()
