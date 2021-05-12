**In development. All code and data is to be considered alpha/test-data.**

# DBoeS-Automatization 

### Abstract 

The DBöS (Datenbank öffentlicher Sprecher, Database of Public Speakers) is a data collection and curation project at the Leibniz Institute for Media Resesarch | Hans-Bredow-Institut that aims to contain i.a. all the names of parliamentarians in Germany with their party affiliation and their URLs to online social networks (if available). Our first goal is a minimum viable product ([MVP](https://en.wikipedia.org/wiki/Minimum_viable_product)) to keep this part of the database up to date with names and party affiliations. Other attributes, such as gender or age, introduce further complications and will be added later on a per project need’s basis. 

There are 16 federal states and every one has its own local parliament. Additionally to the local parliamentarian politicians the aim is to add all the politicians that are a member of the Bundestag (The Federal Parliament) and the members of the state governments in order to include all members of the Bundesrat (Federal Council). Each of these parliaments gets elected at different points in time. This adds up to a number of around 2700 names from different parties around Germany that have to be kept up to date several times a year.

Therefore, the objective of this concept is to automate the process of keeping the list updated as far as possible. The scraper part supports a researcher/programme with automating data retrieval/search from different platforms. The editor part is a Shiny application that helps researchers and assistants to keep the data up to date. The db is basically a 'database', for simplicity's and sustainable archival's sake consisting of plain CSVs.

## Basic Installation of the Python parts (TODO: R-parts for editor)

### Cloning this Repo

To clone this repository type:

```
git clone https://github.com/Leibniz-HBI/DBoeS-Automatization.git
```

This will download this repository. You will need to have git installed.
You can find additional information on how to do it here:

[Install Git for any Operation System](https://github.com/git-guides/install-git)

Alternatively you can download a zip folder or clone the repository via the green 'Code' button on the upper right of our repository.

### Enviroment 

1. Install pipenv to create a virtual enviroment. The latest version can be found here:
[pipenv](https://pipenv.readthedocs.io/en/latest)

2. After installing pipenv, navigate to the directory of the application and run:

```
pipenv install
```
This will create a virtual envirement with the credentials that we have provided in
our pipfile. 

After this you can start a shell in the virtual environment with:

```
pipenv shell
```

You can execute a CLI-application-like test/demo script within the shell with:

```
python main.py
```

### Development and Testing

For development purposes we conduct tests before writing functions. 

#### Run all tests

To run all test you can run following command in the shell:

```
python -m unittest -v
```

Run a single test file:

```
python -m unittest -v test/mytest.py
```

#### Writing tests

Create a python file containing unittest with the name `test_*.py` within the `test` directory.

---

This application is programmed as a part of the [Social Media Observatory of the Lebniz Institut of Media research | Hans Bredow Institut](https://leibniz-hbi.github.io/SMO/) 
