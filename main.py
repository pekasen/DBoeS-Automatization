"""
Main module to run scraping of parlamentarian information from Wikipedia.
"""
import os

import pandas as pd
import scraper
from scraper import twitter_fetcher
from scraper.entities import EntityGroup
from scraper.twitter_fetcher import EntityOnTwitter

if __name__ == "__main__":

    # show all contents of a dataframe
    pd.set_option('display.max_rows', None)
    pd.set_option('display.max_columns', None)
    pd.set_option('display.width', None)
    pd.set_option('display.max_colwidth', -1)

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

    print('\nPlease select a file by number to retrieve Twitter accounts:')

    select = input()

    parliament = EntityGroup(f'output/{files[int(select)]}')
    print(parliament.df[['Name', 'id']])

    print('\nPlease select a row to retrieve Twitter Accounts:')

    select = input()

    name = parliament.df['Name'][int(select)]
    id = parliament.df['id'][int(select)]

    print(f'Retrieving possible accounts for {name} with id {id}.')

    twitter_entity = EntityOnTwitter(name, id)

    twitter_entity.search_accounts()

    print('I found the following accounts:')

    for account in twitter_entity.twitter_accounts:
        print('Account:')
        for key in account.data:
            print(f'\t{key}:\n\t\t{account.data[key]}')
