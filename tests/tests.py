import requests 
import unittest
import sys
from bs4 import BeautifulSoup
import pandas as pd
import os
import sys
import os
sys.path.insert(0, os.getcwd())
import main



class testing_wikifetcher_landtag(unittest.TestCase):

	def test_get_politicians_landtag_sachsen(self):
		tmp = main.Wikifetcher_landtag()
		count_politicians = tmp.get_politicians_landtag_sachsen()
		self.assertEquals(count_politicians, 126)


bot = testing_wikifetcher_landtag
if __name__ == '__main__':
	unittest.main()
