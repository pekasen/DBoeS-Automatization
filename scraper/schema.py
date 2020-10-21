# Configure schema: 'Column_name': ['List', 'of', 'synonyms']

columns_with_synonyms = {
    'Name': ['Mitglied des Landtages'],
    'Fraktion': ['Partei'],
    'Wahlkreis': ['Landtagswahlkreis der Direktkandidaten',
                  'Landtagswahlkreis',
                  'Wahlkreis/Liste',
                  ],
    'Kommentar': ['Anmerkung',
                  'Anmerkungen',
                  'Bemerkungen',
                  ],
}


# Automatically generate schema and synonym map for scraper (dev only)

schema = [column for column in columns_with_synonyms.keys()]

schema_map = {}

for column in columns_with_synonyms.keys():
    for synonym in columns_with_synonyms[column]:
        schema_map[synonym] = column
