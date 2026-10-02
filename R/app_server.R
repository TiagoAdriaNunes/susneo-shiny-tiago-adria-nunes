#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @noRd
#'
#' @importFrom shiny reactive
app_server <- function(input, output, session) {
  # The app works on the data shipped in the package's data/ folder
  energy_data <- reactive(load_sample_data())

  mod_dashboard_server("energy_dashboard", energy_data)
}
