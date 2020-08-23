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


    def quit(self):
        self.driver.quit()


bot = wikifetcher_sachsen()
bot.get_politicians_landtag_sachsen()
bot.quit()
