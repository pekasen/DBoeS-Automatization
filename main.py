"""
Main module to run scraping of parlamentarian information from Wikipedia.
"""
import os

import scraper

if __name__ == "__main__":

    if not os.path.isfile('scraper/twitter_tokens.csv'):
        scraper.twitter_fetcher.OAuthorizer()

    fetcher = scraper.WikiFetcher()
    fetcher.fetch_all_parliaments()
