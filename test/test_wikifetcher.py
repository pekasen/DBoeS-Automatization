import requests 
import unittest
import sys
from bs4 import BeautifulSoup
import pandas as pd
import os
import sys
import os

from scraper.urls import parliaments
from scraper.WikiFetcher import Wikifetcher

class TestParliamentList(unittest.TestCase):

	def url_ok(self, url):
		r = requests.head(url)
		return r.status_code == 200

	def test_a_number_of_parliaments(self):
		self.assertEqual(len(parliaments), 17) # 16 Landtage + 1 Bundestag 

	def test_b_wikipage_availability(self):
		for _, parliament_data in parliaments.items():
			self.assertTrue(self.url_ok(parliament_data["url"]), "Website not available: %s" % parliament_data["url"])

	def test_c_extracted_parlamentarians(self):
		fetcher = Wikifetcher()
		for _, parliament_data in parliaments.items():
			politicians_table, table_index = fetcher.get_politicians(parliament_data["url"])
			# expect at least 50 politicians per parliament
			n = len(politicians_table.index)
			self.assertGreaterEqual(n, 50, "Extracted only %d entries from table %d at %s" % (n, table_index, parliament_data["url"]))

if __name__ == '__main__':
	unittest.main()
