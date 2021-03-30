from __future__ import unicode_literals

import csv
import os
import webbrowser

import pandas as pd
import tweepy as tp

from credentials import twitter_api_key, twitter_api_secret_key
from entities import Account, Entity, EntityGroup

tokens_cache_file = os.path.join(
    os.path.dirname(__file__), "twitter_tokens.csv")


def connect_to_twitter():
    tokens = pd.read_csv(tokens_cache_file)
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


class TwitterAccount(Account):

    def __init__(self, user_name, platform_id, profile_name, verified, description, profile_image_url):
        super().__init__(
            platform='Twitter',
            user_name=user_name,
            platform_id=platform_id,
            url=f'https://twitter.com/{user_name}',
            reviewed=False,
            profile_name=profile_name,
            verified=verified,
            description=description,
            profile_image_url=profile_image_url
        )


class EntityOnTwitter(Entity):

    def __init__(self, name, id=None):
        super().__init__(name, id=None)

        self.accounts['Twitter'] = []

    @property
    def twitter_accounts(self):
        return self.accounts['Twitter']

    def search_accounts(self):
        """Searches for accounts with query "{self.name}" on Twitter and loads them into the Entity.
        """
        account_df = account_search(self.name, fields=['screen_name',
                                                       'id',
                                                       'name',
                                                       'verified',
                                                       'description',
                                                       'profile_image_url_https']
                                    )
        for i, row in account_df.iterrows():
            account = TwitterAccount(row['screen_name'],
                                     str(row['id']),
                                     row['name'],
                                     row['verified'],
                                     row['description'],
                                     row['profile_image_url_https'])

            self.load_account(account)

    def accept_account(self, twitter_id):
        super().accept_account('Twitter', platform_id=twitter_id)


class TwitterEntityGroup(EntityGroup):

    def check_accounts(self, output=None):
        '''checks, based on Twitter user ID, whether accounts in group have changed or have been deleted

        Args:
            output (str): path for CSV output. Defaults to `None`.

        Returns:
            diff (pandas.DataFrame): DataFrame containing differences with column `old/new`
            indicating whether row is in old or new data. If account not reachable, only `old` row will be given.
            If `output` is set, saves diff to csv at output path.
        '''

        df = self.df

        user_ids = list(
            df['SM_Twitter_id'].dropna().drop_duplicates().values
        )

        api = connect_to_twitter()

        response_df = pd.DataFrame(
            columns=['SM_Twitter_id', 'SM_Twitter_user'])

        for i in range(int(len(user_ids)/100) + 1):

            user_batch = user_ids[i*100:i*100+100]
            response = api.lookup_users(user_ids=user_batch)

            for user in response:
                response_df = response_df.append(
                    {'SM_Twitter_id': user.id_str,
                     'SM_Twitter_user': user.screen_name},
                    ignore_index=True)

        old = df[['SM_Twitter_id', 'SM_Twitter_user']]
        new = response_df

        old['SM_Twitter_user'] = old['SM_Twitter_user'].str.lower()
        new['SM_Twitter_user'] = new['SM_Twitter_user'].str.lower()

        # outer merge on all fields in schema
        # if differences, indicate, if row is in old (left) or new (right) DataFrame
        diff = old.merge(new, on=['SM_Twitter_id', 'SM_Twitter_user'], how='outer', indicator=True)

        # delete rows that are in both DFs
        diff = diff[diff['_merge'] != "both"]

        # create new column 'old/new' instead of indicator column called '_merge'
        diff['old/new'] = diff['_merge'].map(
            {'left_only': 'old', 'right_only': 'new'})
        del diff['_merge']

        diff = diff.dropna()
        diff['SM_Twitter_id'] = diff['SM_Twitter_id'].astype(int)
        diff = diff.sort_values(by='SM_Twitter_id', ignore_index=True)

        diff['SM_Twitter_id'] = diff['SM_Twitter_id'].astype(int)

        if output is not None and len(diff) > 0:
            diff.to_csv(output, float_format='{:f}'.format)

        return diff


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

        if not os.path.isfile(tokens_cache_file):
            with open(tokens_cache_file, 'a', newline='') as f:
                writer = csv.writer(f)
                writer.writerow(["token", "secret"])
            f.close()

        with open(tokens_cache_file, 'a', newline='') as f:
            writer = csv.writer(f)
            writer.writerow([auth.access_token, auth.access_token_secret])
        f.close()
