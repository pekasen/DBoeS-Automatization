import os
import unittest

import pandas as pd
import tweepy
from scraper.credentials import twitter_api_key, twitter_api_secret_key
from scraper.twitter_fetcher import OAuthorizer, account_search


class TestUserSearch(unittest.TestCase):

    @classmethod
    def setUpClass(self):

        if not os.path.isfile('scraper/twitter_tokens.csv'):
            OAuthorizer()

    def test_auth(self):
        tokens = pd.read_csv('scraper/twitter_tokens.csv')
        access_token, access_token_secret = tokens['token'][0], tokens['secret'][0]

        auth = tweepy.OAuthHandler(twitter_api_key, twitter_api_secret_key)
        auth.set_access_token(access_token, access_token_secret)

        api = tweepy.API(auth)
        user = api.verify_credentials()

        self.assertIsInstance(user, tweepy.User)

    def test_search_account(self):

        name = "Markus Söder"
        fields = ['id', 'verified', 'screen_name', 'name', 'description', 'profile_image_url_https']

        result = account_search(name)

        self.assertIsInstance(result, pd.DataFrame)

        for field in fields:
            self.assertIn(field, result.columns)

        self.assertGreater(len(result), 0)

        self.assertIn('Markus_Soeder', result['screen_name'].values)


if __name__ == '__main__':
    unittest.main()
