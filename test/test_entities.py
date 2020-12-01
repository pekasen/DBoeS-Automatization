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

    def test_can_save_account_details(self):
        our_test_entity = Entity('What A. Name')
        our_test_entity.save_account(platform='Unicornia',
                                     user_name='uni_corn',
                                     platform_id='12345',
                                     whatever_else_is_important=True)
        our_test_entity.save_account(platform='Unicornia',
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
