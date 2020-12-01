import unittest

from scraper.entities import Entity


class TestEntities(unittest.TestCase):

    def test_name(self):
        our_test_entity = Entity('What A. Name')
        self.assertIsInstance(our_test_entity.name, str)

    def test_can_assign_id(self):
        our_test_entity = Entity('What A. Name', id=1)
        self.assertIsInstance(our_test_entity.id, str)

    def test_can_generate_id(self):
        our_test_entity = Entity('What A. Name')
        self.assertIsInstance(our_test_entity.id, str)

    def test_can_load_account_details(self):
        our_test_entity = Entity('What A. Name')
        our_test_entity.load_account(platform='Unicornia',
                                     user_name='uni_corn',
                                     platform_id='12345',
                                     whatever_else_is_important=True)
        our_test_entity.load_account(platform='Unicornia',
                                     user_name='uni_corn2',
                                     platform_id='54321',
                                     whatever_else_is_important=True)
        account_data = our_test_entity.get_accounts('Unicornia')
        self.assertIsInstance(account_data, list)
        self.assertEqual(account_data[0], {'platform': 'Unicornia',
                                           'user_name': 'uni_corn',
                                           'platform_id': '12345',
                                           'reviewed': False,
                                           'whatever_else_is_important': True}
                         )

    def test_can_review_account(self):
        our_test_entity = Entity('What A. Name')

        for i in range(3):
            our_test_entity.load_account('platform1', f'user_{i}', f'{i}')
            our_test_entity.load_account('platform2', f'user_{i}', f'{i}')

        our_test_entity.accept_account(platform='platform2', platform_id='1')

        accounts_1 = our_test_entity.get_accounts('platform1')
        accounts_2 = our_test_entity.get_accounts('platform2')

        self.assertEqual(len(accounts_1), 3)
        self.assertEqual(len(accounts_2), 1)
        self.assertEqual(accounts_2[0]['platform_id'], '1')
        self.assertTrue(accounts_2[0]['reviewed'])
