"""
Main module to run scraping of parlamentarian information from Wikipedia.
"""
import scraper

if __name__ == "__main__":
    fetcher = scraper.WikiFetcher()
    fetcher.fetch_all_parliaments()
