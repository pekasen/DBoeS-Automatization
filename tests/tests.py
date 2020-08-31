from selenium import webdriver
from selenium.webdriver.firefox.options import Options
import unittest
from bs4 import BeautifulSoup
import pandas as pd
import os
import urllist as urls


class testing_wikifetcher_sachsen(unittest.TestCase):

	def setUp(self):
		self.r = requests.get(urls.sachsenURL)

	def test_find_name_in_table_to_be_scraped(self):
		soup = BeutifulSoup(self.r.content, "lxml")
		fetch_body = soup.find_all('tbody')[2]
		self.assertTrue('"title="Rico Anton"' in str(fetch_tbody.find_all('td')[1]))

	@unittest.expectedFailure
	def test_no_value_error(self):
		with self.assertRaises(ValueError):
			self.driver.get(urls.sachsenUrl)

	@unittest.expectedFailure
	def test_no_type_error(self):
		with self.assertRaises(TypeError):
			self.driver.get(urls.sachsenUrl)

bot = testing_wikifetcher_sachsen
if __name__ == '__main__':
	unittest.main()