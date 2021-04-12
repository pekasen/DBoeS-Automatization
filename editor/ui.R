dashboardPage(
  # Application Title
  dashboardHeader(title = "DBöS"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Datenbank", tabName = "database", icon = icon("search")),
      menuItem("Änderungen", tabName = "changes", icon = icon("list-alt")),
      menuItem("Statistiken", tabName = "statistics", icon = icon("signal"))
    )
  ),
  dashboardBody(
    tabItems(
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

