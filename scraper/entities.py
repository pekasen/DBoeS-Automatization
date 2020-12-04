'''
General social media account fetcher classes and functions
'''
from uuid import uuid4


class Entity:
    """An entity is anything that can have an Account on a Platform

    For example, a person (Donald Trump), an organisation (The White House), or a public role (e.g. POTUS).

    Attributes:
        name (str): The given name of the entity
        id (str, optional): A unique identifier. Defaults to generated uuid
    """

    def __init__(self, name, id=None):
        self.name = name

        if id is not None:
            self.id = str(id)
        else:
            self.id = str(uuid4())

        self.accounts = {}

    def load_account(self, platform, user_name, platform_id, url, reviewed=False, **kwargs):
        """Associats an account with the entity.

        An account gets added to self.accounts, which is a dict with platform names as keys and
        lists of Account objects as values.

        Args:
            platform (str): name of the platform
            user_name (str): user/account name on the platform
            platform_id (str): user/account id on the platform,
                should be immutable and unique per platform
            url (str): profile url
            reviewed (bool): whether the account has been accepted as being the correct account
                for this entity. Defaults to `False`
            **kwargs: Further platform specific keyword arguments can be added, but might be ignored

        Raises:
            type: [description]

        Returns:
            type: [description]
        """

        try:
            self.accounts[platform].append(Account(platform, user_name, platform_id, url, reviewed, **kwargs))
        except KeyError:
            self.accounts[platform] = []
            self.accounts[platform].append(Account(platform, user_name, platform_id, url, reviewed, **kwargs))

    def get_accounts(self, platform):
        """Returns associated possible accounts of the entity on a platform.

        Args:
            platform (str): platform name

        Returns:
            list of dicts: a list of dicts in the form of the data attribute of the Account class
        """

        return [account.data for account in self.accounts[platform]]

    def accept_account(self, platform, platform_id):
        """Accepts the reviewed account as the correct one and discards all other accounts loaded
            for this platform, i.e. deletes all other accounts in the list.

        Args:
            platform (str): platform name
            platform_id (str): platform specic account ID (e.g. Twitter user ID)
        """

        for account in self.accounts[platform]:

            if account.data['platform_id'] == platform_id:
                account.data['reviewed'] = True
                verified_account = account

        self.accounts[platform] = [verified_account]


class Account:
    """Represents a single account on a platform.

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

    def __init__(self, platform, user_name, platform_id, url, reviewed, **kwargs):
        self.data = {
            'platform': platform,
            'user_name': user_name,
            'platform_id': platform_id,
            'url': url,
            'reviewed': reviewed
        }
        self.data = {**self.data, **kwargs}
