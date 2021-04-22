import json
import os
import shutil
import unittest

import pandas as pd
from scraper.entities import Account, Entity, EntityGroup


class TestEntities(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        if os.path.isdir('output/accounts'):
            shutil.move('output/accounts', 'output/accounts_bk')

    @classmethod
    def tearDownClass(cls):
        shutil.rmtree('output/accounts')
        if os.path.isdir('output/accounts_bk'):
            shutil.move('output/accounts_bk', 'output/accounts')

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
        account1 = Account(platform='Unicornia',
                           user_name='uni_corn',
                           platform_id='12345',
                           url='url',
                           whatever_else_is_important=True,
                           )
        our_test_entity.load_account(account1)
        account2 = Account(platform='Unicornia',
                           user_name='uni_corn2',
                           platform_id='54321',
                           url='url',
                           whatever_else_is_important=True,
                           )
        our_test_entity.load_account(account2)
        account_data = our_test_entity.get_accounts('Unicornia')
        self.assertIsInstance(account_data, dict)
        self.assertEqual(account_data['accounts'][0],
                         {'platform': 'Unicornia',
                          'user_name': 'uni_corn',
                          'platform_id': '12345',
                          'url': 'url',
                          'reviewed': False,
                          'whatever_else_is_important': True}
                         )

    def test_can_review_account(self):
        our_test_entity = Entity('What A. Name')

        for i in range(3):
            our_test_entity.load_account(Account('platform1', f'user_{i}', f'{i}', 'url'))
            our_test_entity.load_account(Account('platform2', f'user_{i}', f'{i}', 'url'))

        our_test_entity.accept_account(platform='platform2', platform_id='1')

        accounts_1 = our_test_entity.get_accounts('platform1')
        accounts_2 = our_test_entity.get_accounts('platform2')

        self.assertEqual(len(accounts_1['accounts']), 3)
        self.assertEqual(len(accounts_2['accounts']), 3)
        self.assertEqual(accounts_2['accounts'][1]['platform_id'], '1')
        self.assertTrue(accounts_2['accounts'][1]['reviewed'])

    def test_can_save_accounts(self):
        our_test_entity = Entity('What A. Name', id='id')

        for i in range(3):
            our_test_entity.load_account(Account('platform1', f'user_{i}', f'{i}', 'url'))
            our_test_entity.load_account(Account('platform2', f'user_{i}', f'{i}', 'url'))

        our_test_entity.accept_account(platform='platform2', platform_id='1')

        our_test_entity.save_accounts()

        with open('output/accounts/platform1_id.json') as f:
            data = json.load(f)

            self.assertEqual(len(data['accounts']), 3)

        with open('output/accounts/platform2_id.json') as f:
            data = json.load(f)

            self.assertEqual(len(data['accounts']), 3)
            self.assertTrue(data['accounts'][1]['reviewed'])


class TestEntityGroup(unittest.TestCase):

    def tearDown(self):
        if os.path.isdir('test/output'):
            shutil.rmtree('test/output')

    def test_group_init(self):
        entity_group = EntityGroup('test/data/04-12-2020_saarland.csv')
        self.assertEqual(len(entity_group.entities), 51)
        self.assertIsInstance(entity_group.entities[0], Entity)

    def test_save_group(self):
        entity_group = EntityGroup('test/data/04-12-2020_saarland.csv')
        entity_group.save('test/output/test.csv')
        entity_group = EntityGroup('test/output/test.csv')

        self.assertIn('id', entity_group.df.columns)

    def test_group_init_with_id(self):
        entity_group = EntityGroup('test/data/04-12-2020_saarland_with_ids.csv')

        df = pd.read_csv('test/data/04-12-2020_saarland_with_ids.csv')
        id = df['id'][0]

        self.assertEqual(entity_group.entities[0].id, id)

    def test_group_comparison(self):
        entity_group = EntityGroup('test/data/04-12-2020_saarland_with_ids.csv')
        changed_group = EntityGroup('test/data/04-12-2020_saarland_with_change.csv')

        diff = entity_group.compare(changed_group)

        self.assertIsInstance(diff, pd.DataFrame)
        self.assertEqual(len(diff), 4)

    def test_group_comparison_csv(self):
        entity_group = EntityGroup('test/data/04-12-2020_saarland_with_ids.csv')
        changed_group = EntityGroup('test/data/04-12-2020_saarland_with_change.csv')

        out_path = f'{changed_group.origin}.diff'
        diff = entity_group.compare(changed_group, output=out_path)

        diff_read = EntityGroup.read_diff(out_path)

        self.assertIsInstance(diff_read, pd.DataFrame)
        self.assertTrue(diff.equals(diff_read))

        os.remove(out_path)

    def test_group_comparison_with_deleted_row(self):
        entity_group = EntityGroup('test/data/04-12-2020_saarland_with_ids.csv')
        changed_group = EntityGroup('test/data/04-12-2020_saarland_with_deleted_row.csv')

        diff = entity_group.compare(changed_group)

        self.assertIsInstance(diff, pd.DataFrame)
        self.assertEqual(len(diff), 1)
        self.assertEqual(diff['old/new'][0], 'old')

    def test_group_comparison_with_added_row(self):
        entity_group = EntityGroup('test/data/04-12-2020_saarland_with_ids.csv')
        changed_group = EntityGroup('test/data/04-12-2020_saarland_with_added_row.csv')

        diff = entity_group.compare(changed_group)

        self.assertIsInstance(diff, pd.DataFrame)
        self.assertEqual(len(diff), 1)
        self.assertEqual(diff['old/new'][0], 'new')

    def test_group_comparison_with_several_changes(self):
        entity_group = EntityGroup('test/data/04-12-2020_saarland_with_ids.csv')
        changed_group = EntityGroup('test/data/04-12-2020_saarland_with_several_changes.csv')

        diff = entity_group.compare(changed_group)

        self.assertIsInstance(diff, pd.DataFrame)
        self.assertEqual(len(diff), 10)
        self.assertEqual(len(diff['old/new'][diff['old/new'] == 'new']), 5)

    def test_group_comparison_with_several_changes_and_exclusions(self):
        entity_group = EntityGroup(
            'test/data/04-12-2020_saarland_with_ids.csv')
        changed_group = EntityGroup(
            'test/data/04-12-2020_saarland_with_several_changes.csv')

        diff = entity_group.compare(changed_group, exclude_from_comparison=["Fraktion"])

        self.assertIsInstance(diff, pd.DataFrame)
        self.assertLess(len(diff), 10)
        self.assertLess(len(diff['old/new'][diff['old/new'] == 'new']), 5)
