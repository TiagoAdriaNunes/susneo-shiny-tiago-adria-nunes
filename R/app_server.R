#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @noRd
#'
#' @importFrom shiny reactive
app_server <- function(input, output, session) {
  # The app works on the data shipped in the package's data/ folder
  data_manager <- reactive(EnergyDataManager$new())

  mod_dashboard_server("energy_dashboard", data_manager)
}
