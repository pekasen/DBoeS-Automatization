"""
List of German Wikipedia pages to extract parliamentarian information from.
Index points to table indices (running id) where to find information on the page.
"""
BASE = "https://de.wikipedia.org/wiki/"
parliaments = {
    "sachsen": {
        "name": "Sachsen",
        "url": BASE + "Liste_der_Mitglieder_des_S%C3%A4chsischen_Landtags_(6._Wahlperiode)",
        "index": 2
    },
    "hamburg": {
        "name": "Hamburg",
        "url": BASE + "Liste_der_Mitglieder_der_Hamburgischen_B%C3%BCrgerschaft_(22._Wahlperiode)",
        "index": 2
    },
    "bawue": {
        "name": "Baden-Württemberg",
        "url": BASE + "Liste_der_Mitglieder_des_Landtags_von_Baden-W%C3%BCrttemberg_(16._Wahlperiode)",
        "index": 8
    },
    "mcpomm": {
        "name": "Mecklenburg-Vorpommern",
        "url": BASE + "Liste_der_Mitglieder_des_Landtages_Mecklenburg-Vorpommern_(7._Wahlperiode)",
        "index": 2
    },
    "brandenburg": {
        "name": "Brandenburg",
        "url": BASE + "Liste_der_Mitglieder_des_Landtags_Brandenburg_(7._Wahlperiode)",
        "index": 1
    },
    "berlin": {
        "name": "Berlin",
        "url": BASE + "Liste_der_Mitglieder_des_Abgeordnetenhauses_von_Berlin_(18._Wahlperiode)",
        "index": 0
    },
    "thueringen": {
        "name": "Thüringen",
        "url": BASE + "Liste_der_Mitglieder_des_Th%C3%BCringer_Landtags_(7._Wahlperiode)",
        "index": 2
    },
    "bremen": {
        "name": "Bremen",
        "url": BASE + "Liste_der_Mitglieder_der_Bremischen_B%C3%BCrgerschaft_(20._Wahlperiode)",
        "index": 0
    },
    "sachsen-anhalt": {
        "name": "Sachsen-Anhalt",
        "url": BASE + "Liste_der_Mitglieder_des_Landtages_Sachsen-Anhalt_(7._Wahlperiode)",
        "index": 2
    },
    "bayern": {
        "name": "Bayern",
        "url": BASE + "Liste_der_Mitglieder_des_Bayerischen_Landtags_(18._Wahlperiode)",
        "index": 1
    },
    "rlp": {
        "name": "Rheinland-Pfalz",
        "url": BASE + "Liste_der_Mitglieder_des_Landtages_Rheinland-Pfalz_(17._Wahlperiode)",
        "index": 2
    },
    "hessen": {
        "name": "Hessen",
        "url": BASE + "Liste_der_Mitglieder_des_Hessischen_Landtags_(20._Wahlperiode)",
        "index": 2
    },
    "niedersachsen": {
        "name": "Niedersachsen",
        "url": BASE + "Liste_der_Mitglieder_des_Nieders%C3%A4chsischen_Landtages_(18._Wahlperiode)",
        "index": 2
    },
    "nrw": {
        "name": "Nordrhein-Westfalen",
        "url": BASE + "Liste_der_Mitglieder_des_Landtages_Nordrhein-Westfalen_(17._Wahlperiode)",
        "index": 4
    },
    "sh": {
        "name": "Schleswig-Holstein",
        "url": BASE + "Liste_der_Mitglieder_des_Landtages_Schleswig-Holstein_(19._Wahlperiode)",
        "index": 2
    },
    "saarland": {
        "name": "Saarland",
        "url": BASE + "Liste_der_Mitglieder_des_Landtages_des_Saarlandes_(16._Wahlperiode)",
        "index": 3
    },
    "bundestag": {
        "name": "Bundestag",
        "url": BASE + "Liste_der_Mitglieder_des_Deutschen_Bundestages_(19._Wahlperiode)",
        "index": 3
    },
    "eu": {
        "name": "EU-Parlament",
        "url": BASE + "Liste_der_deutschen_Abgeordneten_zum_EU-Parlament_(2019%E2%80%932024)",
        "index": 1
    }
}
