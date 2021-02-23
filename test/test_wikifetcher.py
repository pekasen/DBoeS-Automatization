import unittest
import warnings
import requests
from scraper.schema import schema
from scraper.urls import parliaments
from scraper.wiki_fetcher import WikiFetcher


def url_ok(url):
    """
    Check if server at remote URL answers ok
    """
    req = requests.head(url)
    return req.status_code == 200


class TestParliamentList(unittest.TestCase):
    """
    Check for extracted content from Wikipedia
    """

    @classmethod
    def setUpClass(cls):
        fetcher = WikiFetcher()
        cls.politicians_tables = {}
        for _, parliament_data in parliaments.items():
            if not url_ok(parliament_data["url"]):
                raise FileNotFoundError("Website not available: %s" % parliament_data["url"])
            cls.politicians_tables[parliament_data['name']] = fetcher.get_politicians(parliament_data["url"])

    def test_a_number_of_parliaments(self):
        """
        Test if 16 Landtage + 1 Bundestag + 1 EU-Parlament are extracted
        """
        self.assertEqual(len(parliaments), 18)

    def test_b_extracted_parlamentarians(self):
        """
        Test if at least 50 politicians per parliament are extracted
        """
        for _, parliament_data in parliaments.items():
            politicians_table, table_index = self.politicians_tables[parliament_data['name']]
            n_tab = len(politicians_table.index)

            self.assertGreaterEqual(n_tab, 50, "Extracted only %d entries from table %d at %s" % (
                n_tab, table_index, parliament_data["url"]))

    def test_c_table_columns(self):
        """
        Test if extracted tables comply with defined schema
        """
        for _, parliament_data in parliaments.items():
            politicians_table, table_index = self.politicians_tables[parliament_data['name']]

            table_schema = list(politicians_table.columns)

            self.assertEqual(
                len(schema), len(table_schema),
                f"Schema {table_schema} (table {table_index}) doesn't match {schema}."
            )

            self.assertListEqual(
                schema, table_schema,
                f"Schema {table_schema} (table {table_index}) doesn't match {schema}."
            )

    def test_d_wiki_urls(self):
        """
        Test if at least 50% of all person entries per parliament have a Wikipedia URL and an image URL
        """
        for _, parliament_data in parliaments.items():
            politicians_table, _ = self.politicians_tables[parliament_data['name']]

            n_link = 0
            n_image = 0
            for _, item in politicians_table.iterrows():
                if not item["Wikipedia-URL"]:
                    warnings.warn(f'No Wikipedia-URL for {item["Name"]} in {parliament_data["name"]}')
                else:
                    n_link += 1
                if not item["Bild"]:
                    warnings.warn(f'No Image-URL for {item["Name"]} in {parliament_data["name"]}')
                else:
                    n_image += 1

            self.assertGreaterEqual(
                n_link / len(politicians_table), 0.5,
                f'Less than 50% Wikipedia URLs extracted for {parliament_data["name"]}'
            )
            self.assertGreaterEqual(
                n_image / len(politicians_table), 0.5,
                f'Less than 50% Image URLs extracted for {parliament_data["name"]}'
            )


if __name__ == '__main__':
    unittest.main()
