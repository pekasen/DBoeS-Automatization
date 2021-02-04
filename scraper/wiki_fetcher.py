"""
Functionality to scrape parliamentarian information from Wikipedia pages.
"""
import logging
import os
from datetime import datetime

import requests
import pandas as pd
import bs4 as bs

from .schema import schema, schema_map
from .urls import parliaments

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s')

WIKI_BASE_URL = "https://de.wikipedia.org"
columns_for_link_extraction = ['Name', 'Mitglied des Landtages', 'Bild', 'Foto']


class WikiFetcher:
    """
    Class to scrape parliamentarian information from Wikipedia pages.
    """

    def __init__(self):
        pass

    def parse_table(self, parsed_table):
        header = [th.text.strip() for th in parsed_table.find_all('th')]
        data = []
        for row in parsed_table.find_all('tr'):
            # clean for hidden data
            for tag in row.select('[style~="display:none"]'):
                tag.decompose()
            # skip headeer
            if not row.find('td'):
                continue
            # iterate over cells
            item = []
            for col_i, td in enumerate(row.find_all('td')):
                text = td.text.strip()
                if header[col_i] in columns_for_link_extraction:
                    # add link, if there is any
                    if td.find('a'):
                        if text:
                            text += '|'
                        link = WIKI_BASE_URL + td.a['href']
                    else:
                        link = ''
                    text += link
                item.append(text)
            data.append(item)
        df = pd.DataFrame(data, columns=header)
        return df

    def get_politicians(self, wiki_url):
        req = requests.get(wiki_url)
        html_source = req.content
        soup = bs.BeautifulSoup(html_source, 'lxml')
        # read html tables from url
        html_tables = soup.find_all('table')
        # heuristic: assume largest table to contain all parlamentarians
        rows_per_table = [len(t.find_all('tr')) for t in html_tables]
        politicians_table_index = rows_per_table.index(max(rows_per_table))
        largest_table = html_tables[politicians_table_index]
        # extract data
        politicians_table = self.parse_table(largest_table)
        # unify schema
        politicians_table = self.clean_table(politicians_table, schema, url=wiki_url)
        # return table and table index for logging purposes
        return politicians_table, politicians_table_index

    def clean_table(self, table, schema_list, url=''):
        for column_name in schema_map:
            table.rename(
                columns={column_name: schema_map[column_name]},
                inplace=True
            )
        try:
            # split Name into Name and Wikipedia-URL
            table[['Name', 'Wikipedia-URL']] = table['Name'].str.split("|", expand=True)
            table = table[schema_list]
        except KeyError as e:
            raise KeyError(f"{schema_list} for {url} not in {table.columns.values}. Edit schema.py.") from e
        return table

    def fetch_all_parliaments(self):
        # Strip Time from Date to add to every csv file created
        datetoday = datetime.today()
        strpdatetoday = datetoday.strftime('%d-%m-%Y')

        # Create a dir for the outputs of all the Landtags csv's
        output_path = os.getcwd() + f'/output/parliaments/{strpdatetoday}/'
        if not os.path.exists(output_path):
            os.makedirs(os.path.dirname(output_path), exist_ok=True)

        for parliament, parliament_data in parliaments.items():
            logging.info("Fetching parliament of %s", parliament_data["name"])
            politicians_table, table_index = self.get_politicians(
                parliament_data["url"])
            logging.info(
                "Retrieved %d entries from table %d",
                politicians_table.shape[0],
                table_index
            )
            politicians_table.to_csv(
                output_path + parliament + ".csv",
                index=False,
                header=True
            )


if __name__ == "__main__":
    fetcher = WikiFetcher()
    fetcher.fetch_all_parliaments()
