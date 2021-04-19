DBoeS editor
============

This is a R Shiny application to edit the DBoeS dataset. It provides CRUD (create, read, update, delete) functionality to the CSV data of public speakers as well as search hooks to platforms such as Twitter to speed up the research for public social media accounts.

How to start?
---------------

You need R and R-Studio installed.

For Python wrapper functions, python and the respective modules need to be installed.

Further, have all necessary packages installed in your R environment (see `global.R`).

Then, run `RunApp()` in the `./editor` working directory.

Deployment
---------------

1. Check out git repository.
2. Have R installed.
3. Copy credentials template `cp auth_credentials.template.R auth_credentials.R` and edit your access credentials.
4. Create hash password store: `Rscript auth_credentials.R`
5. Start the server `R -e "shiny::runApp(host = 'your.ip.addr.ess', port = yourPortNumber)"`

The necessary packages should be installed on the first run. However, there are sometimes missing libraries on UNIX-like systems which require further installations of libraries on the system before everything starts smoothly (e.g. libsodium-dev).
