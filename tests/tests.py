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
		# Change to 'true' to prevent a firefox window to be opened
		options.headless = False
		self.driver = webdriver.Firefox(options=options)


	def test_opened_page(self):
		self.driver.get(urls.sachsenUrl)
		# looking for 6. wahleriode in the title using bs4
		self.assertIn('6. Wahlperiode', (self.driver.title))

	def test_find_name_in_table_to_be_scraped(self):
		self.driver.get(urls.sachsenUrl)
		soup = BeautifulSoup(self.driver.page_source, "lxml")
		fetch_tbody = soup.find_all('tbody')[2]
		self.assertTrue('title="Rico Anton"' in str(fetch_tbody.find_all('td')[1]))

	@unittest.expectedFailure
	def test_no_value_error(self):
		with self.assertRaises(ValueError):
			self.driver.get(urls.sachsenUrl)

	@unittest.expectedFailure
	def test_no_type_error(self):
		with self.assertRaises(TypeError):
			self.driver.get(urls.sachsenUrl)

	def tearDown(self):
		self.driver.quit()

bot = testing_wikifetcher_sachsen
if __name__ == '__main__':
	unittest.main()