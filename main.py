"""
Main module to run scraping of parlamentarian information from Wikipedia.
"""
import os

import pandas as pd
import scraper
from scraper import twitter_fetcher

if __name__ == "__main__":

    if not os.path.isfile('scraper/twitter_tokens.csv'):
        twitter_fetcher.OAuthorizer()

    fetcher = scraper.WikiFetcher()
    fetcher.fetch_all_parliaments()

    print("The following files have been generated:\n")

    files = {}
    i = 0
    for file in os.listdir('output'):
        files[i] = file
        print(f'[{i}]', file)
        i += 1

    print(files)

    print('\nPlease select a file by number to retrieve Twitter accounts:')

    select = input()

    df = pd.read_csv(f'output/{files[int(select)]}')
    print(df)

    print('\nPlease select a row to retrieve Twitter Accounts:')

    select = input()

    print('Retrieving possible accounts for', df['Name'][int(select)])
