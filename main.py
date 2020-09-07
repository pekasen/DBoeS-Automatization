import requests
import unittest
from bs4 import BeautifulSoup
import pandas as pd
import os
import landtags_urls as urls
import configuration as cfg
from datetime import datetime
import ssl
ssl._create_default_https_context = ssl._create_unverified_context


class Wikifetcher_landtag:

    def __init__(self):
        pass

    def get_politicians_landtag_sachsen(self):
        gethtmlsachsen = pd.read_html(sachsenUrl)[2]
        # print(gethtmlsachsen)
        datetoday = datetime.today()
        strpdatetoday = datetoday.strftime('%d-%m-%Y')
        gethtmlsachsen.to_csv(r'sachsen_complete' + strpdatetoday + '.csv', index = True, header = True)       

    # def get politicians_landtag_hamburg
    #     gethtmlhamburg = pd.read_html(r)




bot = Wikifetcher_landtag()
bot.get_politicians_landtag_sachsen()
