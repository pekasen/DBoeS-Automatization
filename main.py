import requests
import unittest
from bs4 import BeautifulSoup
import pandas as pd
import os
import landtags_urls as urls
import configuration as cfg
from datetime import datetime


class Wikifetcher_landtag:

    def __init__(self):
        self.r = requests.get(urls.sachsenUrl).content

    def get_politicians_landtag_sachsen(self):
        soup_sachsen = BeautifulSoup(self.r, "lxml")
        soup_sachsen1 = soup_sachsen.find_all("table")[2]("tr")
        cols = ""
        # find rows
        for row in soup_sachsen1:
            cols = row.find_all('td')
            cols = [x.text.strip() for x in cols]
            print(cols)

        # Create Base CSV file with the needed headers to add the informarion gathered.
        sachsen_csv_raw = {'Name': [],
						'Birthdate': [],
						'Party': [],
						'Wahlkreis': [],
						'Notes': [],
						'Wikipedia': [],
						}

        datetoday = datetime.today()
        strpdatetoday = datetoday.strftime('%d-%m-%Y')
        df = pd.DataFrame(sachsen_csv_raw, columns= ['Name', 'Birthdate', 'Party', 'Wahlkreis', 'Notes', 'Wikipedia'])
        df.to_csv(r"sachsen_complete" + strpdatetoday + ".csv", index = False, header = True)




bot = Wikifetcher_landtag()
bot.get_politicians_landtag_sachsen()
