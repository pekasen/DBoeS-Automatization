'''
General social media account fetcher classes and functions
'''
from uuid import uuid4


class Entity:

    def __init__(self, name, id=None):
        self.name = name

        if id is not None:
            self.id = str(id)
        else:
            self.id = str(uuid4())

        self.accounts = {}

    def save_account(self, platform, user_name, platform_id, reviewed=False, **kwargs):
        try:
            self.accounts[platform].append(Account(platform, user_name, platform_id, reviewed, **kwargs))
        except KeyError:
            self.accounts[platform] = []
            self.accounts[platform].append(Account(platform, user_name, platform_id, reviewed, **kwargs))

    def get_accounts(self, platform):
        return [account.data for account in self.accounts[platform]]

    def accept_account(self, platform, platform_id):

        for account in self.accounts[platform]:

            if account.data['platform_id'] == platform_id:
                account.data['reviewed'] = True
                verified_account = account

        self.accounts[platform] = [verified_account]


class Account:

    def __init__(self, platform, user_name, platform_id, reviewed, **kwargs):
        self.data = {
            'platform': platform,
            'user_name': user_name,
            'platform_id': platform_id,
            'reviewed': reviewed
        }
        self.data = {**self.data, **kwargs}
