# based  on: https://github.com/Nv7-GitHub/googlesearch

from collections import Counter
import re
import pandas as pd
from requests import get
from bs4 import BeautifulSoup

def search(term, num_results=10, lang="de"):
    usr_agent = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) '
                      'Chrome/61.0.3163.100 Safari/537.36'}

    def fetch_results(search_term, number_results, language_code):
        escaped_search_term = "site:facebook.com " + search_term.replace(' ', '+')

        google_url = 'https://www.google.com/search?q={}&num={}&hl={}'.format(escaped_search_term, number_results+1,
                                                                              language_code)
        response = get(google_url, headers=usr_agent)
        response.raise_for_status()

        return response.text

    def parse_results(raw_html):
        soup = BeautifulSoup(raw_html, 'html.parser')
        result_block = soup.find_all('div', attrs={'class': 'g'})
        for result in result_block:
            link = result.find('a', href=True)
            title = result.find('h3')
            if link and title:
                yield link['href']

    fb_regex = re.compile(r'.+facebook.com/(public/)?([^/]+)/?$')
    username_regex = re.compile(r'[a-zA-Z0-9.]{5,50}$')
    html = fetch_results(term, num_results, lang)

    accounts = []
    fb_urls = list(parse_results(html))

    # count usernames and keep urls in reversed order (best ranked last)
    usernames = []
    username_to_url = {}
    fb_urls.reverse()
    for url in fb_urls:
        res = fb_regex.search(url)
        if res:
            # https://graph.facebook.com/{user_id}}/picture?type=square
            user_candidate = res.group(2)
            if username_regex.match(user_candidate):
                usernames.append(user_candidate)
                username_to_url[user_candidate] = url
    counter = Counter(usernames)
    
    # output most common usernames first
    for u, n in counter.most_common():
        accounts.append((username_to_url[u], u, n))

    # convert to pandas df for export
    df = pd.DataFrame(accounts)
    df.columns = ["url", "username", "n"]
    return df

if __name__ == "__main__":
    # print some example search results
    print(search("Alice Weidel"))
    print(search("Metin Hakverdi"))
    print(search("Turgut Altug"))
    print(search("Wolfgang Albers"))
    print(search("Özlem Ünsal"))