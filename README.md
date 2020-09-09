# DBoeS-Automatization 

### Abstract 

The DBöS (Datenbank öffentlicher Sprecher) contains i.a. all the names of parliamentarians in Germany with their party affiliation and their URLs to online social Networks (if available). Our first goal is a minimum viable product ([MVP](https://en.wikipedia.org/wiki/Minimum_viable_product)) to keep this part of the database up to date with names and party affiliations. Other attributes, such as gender or age, introduce further complications and will be added later on a per project need’s basis. 

There are 16 federal states and every one has its own local parliament. Additionally to the local parliamentarian politicians the aim is to add all the politicians that are a member of the Bundestag (The Federal Parliament) and the members of the state governments in order to include all members of the Bundesrat (Federal Council). Each of these parliaments gets elected at different points in time. This adds up to a number of around 2700 names from different parties around Germany that have to be kept up to date several times a year.

Therefore, the objective of this concept is to automate the process of keeping the list updated as far as possible. We are planning to program 3 modules that should support researchers in the future. We conceptualise the different steps that are needed below.


### About

The bot will gather all the names of the  german parliamentarian politicians and scrape them into CSV files.
There are 16 Bundesläner in Germany. Additional to this the Bundestag and Bundesrat is formed.
This makes 18 Sites to be scraped with a concluding number of around 2700 names. We will use wikipedia as a source,
since it provides complete tables with the needed information. 

## Basic Installation

### Enviroment 

1. Install pipenv to create a virtual enviroment. The latest version can be found here:
[pipenv](https://pipenv.readthedocs.io/en/latest)

2. After installing pipenv, navigate to the directory of the application and run:

```
pipenv install
```
This will create a virtual envirement with the credentials that we have provided in
our pipfile. 

After this you can start a shell with:

```
pipenv shell
```

You can execute the application within the shell with:

```
python main.py
```

### Development and Testing
For development purposes we conduct tests before writing functions. 
To run a test you can run following command in the shell:

```
python test/test.py
```

This application is programmed as a part of the [Social Media Observatory of the Lebniz Institut of Media research | Hans Bredow Institut](https://leibniz-hbi.github.io/SMO/) 