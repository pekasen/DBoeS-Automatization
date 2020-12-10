'''
General social media account fetcher classes and functions
'''
import json
import os
from uuid import uuid4

import pandas as pd


class Entity:
    """An entity is anything that can have an Account on a platform

    For example, a person (Donald Trump), an organisation (The White House), or a public role (e.g. POTUS).

    Attributes:
        name (str): The given name of the entity
        id (str, optional): A unique identifier. Defaults to generated uuid.
    """

    def __init__(self, name, id=None):
        self.name = name

        if id is not None:
            self.id = str(id)
        else:
            self.id = str(uuid4())

        self.accounts = {}

    def load_account(self, account):
        """Associates an account with the entity.

        An account gets added to self.accounts, which is a dict with platform names as keys and
        lists of Account objects as values.

        Args:
            account (Account object): the account to be associated
        """

        platform = account.data['platform']

        try:
            self.accounts[platform].append(account)
        except KeyError:
            self.accounts[platform] = []
            self.accounts[platform].append(account)

    def get_accounts(self, platform):
        """Returns associated possible accounts of the entity on a platform.

        Args:
            platform (str): platform name

        Returns:
            dict:
                containing:
                    'id': the unique entity id
                    'name': the given entity name
                    'platform': the platform name
                    'accounts': list of dicts in the form of the data attribute of the Account class
        """

        return {'id': self.id,
                'name': self.name,
                'platform': platform,
                'accounts': [account.data for account in self.accounts[platform]]}

    def accept_account(self, platform, platform_id):
        """Accepts the reviewed account as the correct one.

        Args:
            platform (str): platform name
            platform_id (str): platform specic account ID (e.g. Twitter user ID)
        """

        for account in self.accounts[platform]:

            if account.data['platform_id'] == platform_id:
                account.data['reviewed'] = True

    def save_accounts(self):
        '''Saves possible accounts of the entity in a file

        Saves to JSONs in 'output/accounts/{platform}_{entity_id}' in the format of Entity.get_accounts return.
        '''

        output_path = os.getcwd() + '/output/accounts/'
        if not os.path.exists(output_path):
            os.makedirs(os.path.dirname(output_path))

        for platform in self.accounts:
            accounts_data = self.get_accounts(platform)
            with open(f'output/accounts/{platform}_{self.id}.json', 'w') as file:
                json.dump(accounts_data, file)


class Account:
    """Represents a single account on a platform. Represented in entity and platform related JSONs.

    Args:
        platform (str): platform name
        user_name (str): account/user name
        platform_id (str): user/account id on the platform,
            should be immutable and unique per platform
        url (str): profile url
        reviewed (bool): whether the account has been accepted as being the correct account
            for this entity. Defaults to `False`
        **kwargs: Further platform specific keyword arguments can be added, but might be ignored
    """

    def __init__(self, platform, user_name, platform_id, url, reviewed=False, **kwargs):
        self.data = {
            'platform': platform,
            'user_name': user_name,
            'platform_id': platform_id,
            'url': url,
            'reviewed': reviewed
        }
        self.data = {**self.data, **kwargs}


class EntityGroup:
    '''Group of Entities, e.g. a parliament, represented as a CSV on disk.
    '''
    def __init__(self, path):

        self.df = pd.read_csv(path)
        if 'id' not in self.df.columns:
            self.entities = [Entity(name) for name in self.df['Name'].values]
            self.df['id'] = [entity.id for entity in self.entities]
        else:
            self.entities = [Entity(name, id) for (name, id) in self.df[['Name', 'id']].values]

    def save(self, path):
        dir = os.path.dirname(path)
        if not os.path.exists(dir):
            os.makedirs(dir)

        self.df.to_csv(path, index=False)
