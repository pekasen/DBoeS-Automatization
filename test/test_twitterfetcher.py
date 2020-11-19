import os
import unittest

import pandas as pd
import tweepy
from scraper.twitter_fetcher import (OAuthorizer, account_search,
                                     connect_to_twitter)


class TestUserSearch(unittest.TestCase):

    @classmethod
    def setUpClass(self):

        if not os.path.isfile('scraper/twitter_tokens.csv'):
            OAuthorizer()

    def test_auth(self):

        api = connect_to_twitter()
        user = api.verify_credentials()

        self.assertIsInstance(user, tweepy.User)

    def test_search_account(self):

        name = "Markus Söder"
        fields = ['id', 'verified', 'screen_name', 'name', 'description', 'profile_image_url_https']

        result = account_search(name, fields)

        self.assertIsInstance(result, pd.DataFrame)

        for field in fields:
            self.assertIn(field, result.columns)

        self.assertGreater(len(result), 0)

        self.assertIn('Markus_Soeder', result['screen_name'].values)


if __name__ == '__main__':
    unittest.main()
