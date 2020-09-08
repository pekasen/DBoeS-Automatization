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


class Wikifetcher:

    def __init__(self):
        pass

    def get_politicians_landtage(self):
        # Strip Time from Date to add to every csv file created
        datetoday = datetime.today()
        strpdatetoday = datetoday.strftime('%d-%m-%Y')

        # Create a dir for the outputs of all the Landtags csv's
        path_to_landtage = os.getcwd() + '/Outputs_Landtage/'
        if not os.path.exists(path_to_landtage):
            os.makedirs(os.path.dirname(path_to_landtage), exist_ok=True)

        # Scraping the Date from Landtag Sachsen
        getHtmlSachsen = pd.read_html(urls.sachsenUrl)[2]
        getHtmlSachsen.to_csv(path_to_landtage + 'sachsen_complete' + strpdatetoday + '.csv', index = False, header = True)

        # Scraping the Data from the Bürgerschaft Hamburg
        getHtmlHamburg = pd.read_html(urls.hamburgUrl)[2]
        getHtmlHamburg.to_csv(path_to_landtage + 'hamburg_complete' + strpdatetoday + '.csv', index = False, header = True)

        # Scraping the Data from Landtag Baden-Wuertemberg
        getHtmlBaWue = pd.read_html(urls.bawueUrl)[8]
        getHtmlBaWue.to_csv(path_to_landtage + 'bawue_complete' + strpdatetoday + '.csv', index = False, header = True)

        # Scraping the Data from Landtag Mecklenburg-Vorpommern
        getHtmlMeckPom = pd.read_html(urls.meckpomUrl)[2]
        getHtmlSachsen.to_csv(path_to_landtage + 'meckpom_complete' + strpdatetoday + '.csv', index = False, header = True)

        # Scraping the Data from Landtag Brandenburg
        getHtmlBrandenburg = pd.read_html(urls.brandenUrl)[1]
        getHtmlBrandenburg.to_csv(path_to_landtage + 'brandenburg_complete' + strpdatetoday + '.csv', index = False, header = True)

        # Scraping Landtag Berlin
        getHtmlBerlin = pd.read_html(urls.berlinUrl)[0]
        getHtmlBerlin.to_csv(path_to_landtage + 'berlin_complete' + strpdatetoday + '.csv', index = False, header = True)

        # Scraping Landtag Rheinland Pfalz
        getHtmlRheinland = pd.read_html(urls.rheinlandUrl)[2]
        getHtmlRheinland.to_csv(path_to_landtage + 'rheinland_complete' + strpdatetoday + '.csv', index = False, header = True)

        # Scraping Landtag Bayern
        getHtmlBayern = pd.read_html(urls.bayernUrl)[1]
        getHtmlBayern.to_csv(path_to_landtage + 'bayern_complete' + strpdatetoday + '.csv', index = False, header = True)

        # Scraping Thueringen
        getHtmlThueringen = pd.read_html(urls.thueringenUrl)[2]
        getHtmlThueringen.to_csv(path_to_landtage + 'thueringen_complete' + strpdatetoday + '.csv', index = False, header = True)

        # Scraping Bremen
        getHtmlBremen = pd.read_html(urls.bremenUrl)[0]
        getHtmlBremen.to_csv(path_to_landtage + 'bremen_complete' + strpdatetoday + '.csv', index = False, header = True)

        # Scraping Sachsen Anhalt
        getHtmlSachenan = pd.read_html(urls.sachsenanUrl)[2]
        getHtmlSachenan.to_csv(path_to_landtage + 'sachsenanhalt_complete' + strpdatetoday + '.csv', index = False, header = True)

        # Scraping Hessen
        getHtmlHessen = pd.read_html(urls.hessenUrl)[2]
        getHtmlHessen.to_csv(path_to_landtage + 'hessen_complete' + strpdatetoday + '.csv', index = False, header = True)

        # Scraping Niedersachsen
        getHtmlNiedersachs = pd.read_html(urls.niederUrl)[2]
        getHtmlNiedersachs.to_csv(path_to_landtage + 'niedersachs_complete' + strpdatetoday + '.csv', index = False, header = True)

        # Scraping Nordrhein-Westfahlen
        getHtmlNordrhein = pd.read_html(urls.nordrheinUrl)[4]
        getHtmlNordrhein.to_csv(path_to_landtage + 'nordrhein_complete' + strpdatetoday + '.csv', index = False, header = True)

        # Scraping Schleswig Holstein 
        getHtmlSh = pd.read_html(urls.shUrl)[2]
        getHtmlSh.to_csv(path_to_landtage + 'sh_complete' + strpdatetoday + '.csv', index = False, header = True)

        # Scraping Saarland
        getHtmlSaar = pd.read_html(urls.saarUrl)[3]
        getHtmlSaar.to_csv(path_to_landtage + 'saar_complete' + strpdatetoday + '.csv', index = False, header = True)

        # To complete the test we must compile the 16 csv to one and messure its lengh and hope it has 1875 lines! 


bot = Wikifetcher()
bot.get_politicians_landtage()
