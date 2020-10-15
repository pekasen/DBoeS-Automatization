import unittest
import requests

from scraper.urls import parliaments
from scraper.wiki_fetcher import WikiFetcher


def url_ok(url):
    req = requests.head(url)
    return req.status_code == 200


class TestParliamentList(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        for _, parliament_data in parliaments.items():
            if not url_ok(parliament_data["url"]):
                raise FileNotFoundError("Website not available: %s" % parliament_data["url"])

    def test_a_number_of_parliaments(self):
        self.assertEqual(len(parliaments), 17)  # 16 Landtage + 1 Bundestag

    def test_b_extracted_parlamentarians(self):
        fetcher = WikiFetcher()

        schema = ['Name', 'Fraktion']
        for _, parliament_data in parliaments.items():
            politicians_table, table_index = fetcher.get_politicians(parliament_data["url"])
            # expect at least 50 politicians per parliament
            n_tab = len(politicians_table.index)

            self.assertGreaterEqual(n_tab, 50, "Extracted only %d entries from table %d at %s" % (
                n_tab, table_index, parliament_data["url"]))

            table_schema = list(politicians_table.columns)

            self.assertEqual(
                len(schema), len(table_schema),
                f"Schema {table_schema} (table {table_index}) doesn't match {schema}."
            )

            self.assertListEqual(
                schema, table_schema,
                f"Schema {table_schema} (table {table_index}) doesn't match {schema}."
            )


if __name__ == '__main__':
    unittest.main()
