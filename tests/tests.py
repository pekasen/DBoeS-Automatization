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



class testing_wikifetcher(unittest.TestCase):

	def test_get_politicians_landtage(self):
		wikifetch = main.Wikifetcher()
		complete_number_of_landtags_politicians = wikifetch.get_politicians_landtage()
		self.assertEquals(complete_number_of_landtags_politicians, 1875) # result 


bot = testing_wikifetcher()
if __name__ == '__main__':
	unittest.main()
