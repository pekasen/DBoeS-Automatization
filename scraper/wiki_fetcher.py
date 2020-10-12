"""
Functionality to scrape parliamentarian information from Wikipedia pages.
"""
import os
from datetime import datetime

import logging
import pandas as pd

from .urls import parliaments

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s')

class WikiFetcher:
    """
    Class to scrape parliamentarian information from Wikipedia pages.
    """

    def __init__(self):
        pass

    def get_politicians(self, wiki_url):
        # read html tables from url
        html_tables = pd.read_html(wiki_url)
        # heuristic: assume largest table as table containing all parlamentarians
        html_tables_lengths = [len(table.index) for table in html_tables]
        politicians_table_index = html_tables_lengths.index(
            max(html_tables_lengths))
        politicians_table = html_tables[politicians_table_index]
        # return table and table index for logging purposes
        return politicians_table, politicians_table_index

    def fetch_all_parliaments(self):
        # Strip Time from Date to add to every csv file created
        datetoday = datetime.today()
        strpdatetoday = datetoday.strftime('%d-%m-%Y')

        # Create a dir for the outputs of all the Landtags csv's
        output_path = os.getcwd() + '/output/'
        if not os.path.exists(output_path):
            os.makedirs(os.path.dirname(output_path), exist_ok=True)

        for parliament, parliament_data in parliaments.items():
            logging.info("Fetching parliament of %s", parliament_data["name"])
            politicians_table, table_index = self.get_politicians(
                parliament_data["url"])
            logging.info("Retrieved %d entries from table %d",
                politicians_table.shape[0],
                table_index)
            politicians_table.to_csv(
                output_path + strpdatetoday + "_" + parliament + ".csv", index=False, header=True)


if __name__ == "__main__":
    fetcher = WikiFetcher()
    fetcher.fetch_all_parliaments()
