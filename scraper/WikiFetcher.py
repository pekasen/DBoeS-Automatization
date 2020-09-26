import requests
import unittest
from bs4 import BeautifulSoup
import pandas as pd
import os
from datetime import datetime
import ssl
ssl._create_default_https_context = ssl._create_unverified_context

import logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s')

from .urls import parliaments

class Wikifetcher:

    def __init__(self):
        pass

    def get_politicians(self, wiki_url, table_index):
        wiki_html = pd.read_html(wiki_url)
        politicians_table = wiki_html[table_index]
        return politicians_table

    def fetch_all_parliaments(self):
        # Strip Time from Date to add to every csv file created
        datetoday = datetime.today()
        strpdatetoday = datetoday.strftime('%d-%m-%Y')

        # Create a dir for the outputs of all the Landtags csv's
        output_path = os.getcwd() + '/output/'
        if not os.path.exists(output_path):
            os.makedirs(os.path.dirname(output_path), exist_ok=True)

        for parliament, parliament_data in parliaments.items():
            logging.info("Fetching parliament of %s" % parliament_data["name"])
            politicians_table = self.get_politicians(parliament_data["url"], parliament_data["index"])
            logging.info("Retrieved %d entries" % politicians_table.shape[0])
            politicians_table.to_csv(output_path + strpdatetoday + "_" + parliament + ".csv", index = False, header = True)

if __name__ == "__main__":
    fetcher = Wikifetcher()
    fetcher.fetch_all_parliaments()
