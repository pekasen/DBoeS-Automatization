from __future__ import unicode_literals

import csv
import os
import webbrowser

import pandas as pd
import tweepy as tp
from entities import Account, Entity, EntityGroup

from .credentials import twitter_api_key, twitter_api_secret_key


def connect_to_twitter():
    tokens = pd.read_csv('scraper/twitter_tokens.csv')
    access_token, access_token_secret = tokens['token'][0], tokens['secret'][0]

    auth = tp.OAuthHandler(twitter_api_key, twitter_api_secret_key)
    auth.set_access_token(access_token, access_token_secret)

    api = tp.API(auth)

    return api


def account_search(name, fields):

    api = connect_to_twitter()

    users = api.search_users(name)

    df = pd.DataFrame(columns=fields)

    for user in users:
        row = {}
        for field in fields:
            row[field] = getattr(user, field)

        df = df.append(row, ignore_index=True)

    return df


class OAuthorizer():
    def __init__(self):
        ctoken, csecret = twitter_api_key, twitter_api_secret_key
        auth = tp.OAuthHandler(ctoken, csecret)

        try:
            redirect_url = auth.get_authorization_url()
        except tp.TweepError as e:
            if '"code":32' in e.reason:
                raise tp.TweepError("""Failed to get the request token. Perhaps the Consumer Key
                and / or secret in your 'keys.json' is incorrect?""")
            else:
                raise e

        webbrowser.open(redirect_url)
        token = auth.request_token["oauth_token"]
        verifier = input("Please enter Verifier Code: ")
        auth.request_token = {'oauth_token': token,
                              'oauth_token_secret': verifier}
        try:
            auth.get_access_token(verifier)
        except tp.TweepError as e:
            if "Invalid oauth_verifier parameter" in e.reason:
                raise tp.TweepError("""Failed to get access token! Perhaps the
                                    verifier you've entered is wrong.""")
            else:
                raise e

        if not os.path.isfile('scraper/twitter_tokens.csv'):
            with open('scraper/twitter_tokens.csv', 'a', newline='') as f:
                writer = csv.writer(f)
                writer.writerow(["token", "secret"])
            f.close()

        with open('scraper/twitter_tokens.csv', 'a', newline='') as f:
            writer = csv.writer(f)
            writer.writerow([auth.access_token, auth.access_token_secret])
        f.close()
