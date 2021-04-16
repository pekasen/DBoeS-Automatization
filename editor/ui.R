tagList(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "hbi.css")
  ),
  dashboardPage(
    title = "DBöS - Datenbank öffentlicher Sprecher",
    # Application Header
    dashboardHeader(
      title = tags$img(src='hbi_logo_small.png', height='35', width='35'),
      dropdownMenuOutput("messageMenu"),
      tags$li(class = "dropdown", style = "padding: 8px;", 
              logoutUI("logout")),
      tags$li(class = "dropdown login-button", 
              a(href = "#", 
                class = "dropdown-toggle",
                'data-toggle' = "dropdown", icon("user"), textOutput("logged_in_user", inline = T)), 
              tags$ul(class = "dropdown-menu login-menu",
                      tags$li(tags$ul(class = "menu",
                                      style = "padding-left:0 !important",
                                      shinyauthr::loginUI(
                                        "login", 
                                        title = "Zum Bearbeiten anmelden",
                                        user_title = "User",
                                        pass_title = "Passwort",
                                        error_message = "User oder Passwort unbekannt!",
                                        cookie_expiry = cookie_expiry)
                                      ),
                              uiOutput("login_rights_info", inline = T)
                              ),
                      )
              )
    ),
    # Application Sidebar
    dashboardSidebar(
      sidebarMenu(
        menuItem("Datenbank", tabName = "database", icon = icon("search")),
        menuItem("Statistiken", tabName = "statistics", icon = icon("signal")),
        menuItem("Dokumentation", tabName = "about", icon = icon("info")),
        menuItem("Änderungen", tabName = "changes", icon = icon("list-alt"))
      )
    ),
    dashboardBody(
      tabItems(
        tabItem(
          tabName = "about",
          fluidRow(
            box(
              width=12,
              h1("Datenbank Öffentlicher Sprecher:innen", align = 'center'),
              p("Hier werden Projektinformationen und eine Dokumentation zur DBöS angezeigt")
            )
          )
        ),
        tabItem(
          tabName = "database",
          fluidRow(
            shinyFeedback::useShinyFeedback(),
            shinyjs::useShinyjs(),
            box(
              width=12,
              h1("Öffentliche Sprecher:innen", align = 'center'),
              dboes_table_module_ui("dboes_table")
            )
          )
        ),
        tabItem(
          tabName = "changes",
          fluidRow(
            box(
              width=12,
              h1("Änderungen", align = 'center'),
              p("Hier werden Änderungen in den automatisch erfassten Daten angezeigt")
            )
          )
        ),
        tabItem(
          tabName = "statistics",
          fluidRow(
            box(
              width=12,
              h1("Statistiken", align = 'center'),
              p("Hier werden Statistiken zu den in der DBöS erfassten Accounts angezeigt.")
            )
          )
        )
      )
    )
  )
)
