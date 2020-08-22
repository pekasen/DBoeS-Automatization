from selenium import webdriver
from selenium.webdriver.firefox.options import Options
import unittest
from bs4 import BeautifulSoup
import pandas as pd
import os
import urllist as urls


class testing_wikifetcher_sachsen(unittest.TestCase):

	def setUp(self):
		options = Options()
		options.headless = False
		self.driver = webdriver.Firefox(options=options)

	def test_opened_page(self):
		self.driver.get(urls.sachsenUrl)
		self.assertIn('6. Wahlperiode', (self.driver.title))

	def tearDown(self):
		self.driver.quit()

bot = testing_wikifetcher_sachsen()
if __name__ == '__main__':
	unittest.main()