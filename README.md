# DBoeS-Automatization

### Abstract 

This application aims to automate the parts of the "Datenbank öffentlicher Sprecher" (DBöS).
The DBöS gathers information of different public speakers on social media. 
These include also politicians on whom we will concenrate in out application

### About

The bot will gather all the names of the politicians and scrape them into CSV files.
There are 17 Bundesläner in Germany. Additional to this the Bundestag is formed.
This makes 18 Sites to be scraped with a concluding number of around 2700 names.

### Basic Installation

## Enviroment 

1. Install pipenv to create a virtual enviroment. The latest version can be found here
https://pipenv.readthedocs.io/en/latest

2. After installing pipenv, navigate to the directory of the application and run:

```
pipenv install
```
This will create a virtual envirement with the credentials that we habe provided in
our pipfile. 

After this you can start a shell with:

```
pipenv shell
```

You can execute the application within the shell with:

```
python main.py
```
