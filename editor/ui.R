dashboardPage(
  # Application Title
  dashboardHeader(title = "DBöS"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Listen", tabName = "lists", icon = icon("search")),
      menuItem("Änderungen", tabName = "changes", icon = icon("list-alt")),
      menuItem("Statistiken", tabName = "stats", icon = icon("signal"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "lists",
        fluidRow(
          shinyFeedback::useShinyFeedback(),
          shinyjs::useShinyjs(),
          box(
            width=12,
            h1("Listen", align = 'center'),
            dboes_table_module_ui("dboes_table")
          )
        )
      ),
      tabItem(
        tabName = "changes",
        fluidRow(
          box(
            h1("Änderungen", align = 'center')
          )
        )
      ),
      tabItem(
        tabName = "stats",
        fluidRow(
          box(
            h1("Statistiken", align = 'center')
          )
        )
      )
    )
  )
)

