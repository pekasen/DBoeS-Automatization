import dash
import dash_bootstrap_components as dbc
import dash_core_components as dcc
import dash_html_components as html
import dash_table
import pandas as pd
from dash.dependencies import Input, Output

app = dash.Dash(external_stylesheets=[dbc.themes.SKETCHY])

df = pd.read_csv(
    "https://raw.githubusercontent.com/Leibniz-HBI/DBoeS-Automatization/trying_dash/db/parliamentarians.csv"
    )

sidebar = dbc.Col(
    [
        html.H2("DBÖS", className="display-4"),
        html.Hr(),
        html.P(
            "Datenbank öffentlicher Sprecher", className="lead"
        ),
        dbc.Nav(
            [
                dbc.NavLink("Parlamentarier", href="/page-1", id="page-1-link"),
                dbc.NavLink("Page 2", href="/page-2", id="page-2-link"),
                dbc.NavLink("Page 3", href="/page-3", id="page-3-link"),
            ],
            pills=True,
        ),
    ],
    width='auto'
)

content = dbc.Col(id="page-content", width='auto')

app.layout = dbc.Container(
    dbc.Row([dcc.Location(id="url"), sidebar, content]),
    fluid=True
    )


# this callback uses the current pathname to set the active state of the
# corresponding nav link to true, allowing users to tell see page they are on
@app.callback(
    [Output(f"page-{i}-link", "active") for i in range(1, 4)],
    [Input("url", "pathname")],
)
def toggle_active_links(pathname):
    if pathname == "/":
        # Treat Parlamentarier as the homepage / index
        return True, False, False
    return [pathname == f"/page-{i}" for i in range(1, 4)]


@app.callback(Output("page-content", "children"), [Input("url", "pathname")])
def render_page_content(pathname):
    if pathname in ["/", "/page-1"]:
        return dash_table.DataTable(
            style_data={
                'whiteSpace': 'normal',
                'height': 'auto'
                },
            id='table',
            columns=[{"name": i, "id": i} for i in df.columns],
            data=df.to_dict('records'),
            filter_action='native',
            sort_action='native',
            page_size=10000,
            style_table={'overflowX': 'auto'},
            export_format='csv',
        )

    elif pathname == "/page-2":
        return html.P("This is the content of page 2. Yay!")
    elif pathname == "/page-3":
        return html.P("Oh cool, this is page 3!")
    # If the user tries to reach a different page, return a 404 message
    return dbc.Jumbotron(
        [
            html.H1("404: Not found", className="text-danger"),
            html.Hr(),
            html.P(f"The pathname {pathname} was not recognised..."),
        ]
    )


if __name__ == "__main__":
    app.run_server(debug=True)
