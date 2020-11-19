from __future__ import unicode_literals

import csv
import os
import webbrowser

import tweepy as tp

from .credentials import twitter_api_key, twitter_api_secret_key


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
