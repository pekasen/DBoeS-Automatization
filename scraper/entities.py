'''
General social media account fetcher classes and functions
'''
import json
import os
from uuid import uuid4

import pandas as pd

from schema import schema


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

        self.df = pd.read_csv(path, dtype=str)
        self.origin = path
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

    def compare(self, entitygroup, output=None, exclude_from_comparison=None):
        '''Compare self with other EntityGroup

        Args:
            entitygroup: Other EntityGroup object
            output (str): path for CSV output. Defaults to `None`.
            exclude_from_comparison (list[str]): list of columns to exclude from comparisons, cannot contain "Name"

        Returns:
            diff (pandas.DataFrame): DataFrame containing differing rows only with columns
              - 'id_x' and 'id_y' with uuids of old and new rows respectively
              - 'old/new' indicating whether row is in old or new DataFrame
            If `output` is set, saves diff to csv at output path.
        '''

        old = self.df
        new = entitygroup.df

        if isinstance(exclude_from_comparison, list):
            assert "Name" not in exclude_from_comparison
            columns = [
                column for column in schema if column not in exclude_from_comparison]
            old = old[columns]
            new = new[columns]
        else:
            columns = schema

        # outer merge on all fields in schema
        # if differences, indicate, if row is in old (left) or new (right) DataFrame
        diff = old.merge(new, on=columns, how='outer', indicator=True)

        # delete rows that are in both DFs
        diff = diff[diff['_merge'] != "both"]

        # create new column 'old/new' instead of indicator column called '_merge'
        diff['old/new'] = diff['_merge'].map({'left_only': 'old', 'right_only': 'new'})
        del diff['_merge']

        # sort dataframe by name
        diff = diff.sort_values(by='Name', ignore_index=True)

        if output is not None and len(diff) > 0:
            diff.to_csv(output)

        return diff

    @classmethod
    def read_diff(cls, path):
        diff = pd.read_csv(path, index_col=0)
        return diff
