gpg --quiet --batch --yes --decrypt --passphrase="$GPG_PASSPHRASE" \
--output scraper/credentials.py .github/credentials/credentials.py.gpg

gpg --quiet --batch --yes --decrypt --passphrase="$GPG_PASSPHRASE" \
--output scraper/twitter_tokens.csv .github/credentials/twitter_tokens.csv.gpg
