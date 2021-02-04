"""
Main module to run scraping of parlamentarian information from Wikipedia.
"""
import os
import shutil
import sys
from datetime import datetime
from random import randint

import pandas as pd
import scraper
from scraper import twitter_fetcher
from scraper.entities import EntityGroup
from scraper.twitter_fetcher import EntityOnTwitter


datetoday = datetime.today()
strpdatetoday = datetoday.strftime('%d-%m-%Y')


def test_input(test, number_of_choices=0):
    if not test:
        return input()
    else:
        select = randint(0, number_of_choices - 1)
        print(select)
        return select


if __name__ == "__main__":

    try:
        if sys.argv[1] == 'test':
            test = True
            if os.path.isdir('output'):
                shutil.move('output', 'output_bk')
    except IndexError:
        test = False

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
    for file in os.listdir(f'output/parliaments/{strpdatetoday}'):
        files[i] = file
        print(f'[{i}]', file)
        i += 1

    print("Checking for changes in parliamentarian lists.")

    new_path = f'output/parliaments/{strpdatetoday}/{file}'

    for file in os.listdir('db/parliaments/'):
        old_parliament = EntityGroup(f'db/parliaments/{file}')
        new_parliament = EntityGroup(new_path)

        difference = old_parliament.compare(new_parliament, output=new_path)

        if len(difference) != 0:
            print(f"Difference found in {file}")
            print(difference)

    print('\nPlease select a file by number to retrieve Twitter accounts:')

    select = test_input(test, i)

    parliament = EntityGroup(f'output/{files[int(select)]}')
    print(parliament.df[['Name', 'id']])

    print('\nPlease select a row to retrieve Twitter Accounts:')

    select = test_input(test, len(parliament.df))

    name = parliament.df['Name'][int(select)]
    id = parliament.df['id'][int(select)]

    print(f'Retrieving possible accounts for {name} with id {id}.')

    twitter_entity = EntityOnTwitter(name, id)

    twitter_entity.search_accounts()

    if len(twitter_entity.twitter_accounts) > 0:

        print('I found the following accounts:')

        account_number = 0
        for account in twitter_entity.twitter_accounts:
            print(f'Account {account_number}:')
            for key in account.data:
                print(f'\t{key}:\n\t\t{account.data[key]}')
            account_number += 1

        print('If there is a correct one, please accept with account number:')

        select = test_input(test, account_number)

        if select != '':
            correct_account = twitter_entity.twitter_accounts[int(select)]
            twitter_entity.accept_account(correct_account.data['platform_id'])

        twitter_entity.save_accounts()
    else:
        print('No Twitter accounts found.')

    if test:
        shutil.rmtree('output')
        if os.path.isdir('output_bk'):
            shutil.move('output_bk', 'output')
