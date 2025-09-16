#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Call data upload module and get reactive data
  data_reactive <- mod_data_upload_server("data_upload")

  # Call dashboard module with data from upload module
  mod_dashboard_server("energy_dashboard", data_reactive)
}
