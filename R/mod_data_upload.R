#' data_upload UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList fileInput actionButton
mod_data_upload_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fileInput(ns("file"),
      label = "Upload CSV File",
      accept = c(".csv")
    ),
    actionButton(ns("load_sample"),
      label = "Load Sample Data",
      class = "btn-primary"
    )
  )
}

#' data_upload Server Functions
#'
#' @param id Module ID
#' @return data_manager instance
#' @noRd
#' @importFrom shiny moduleServer observe observeEvent showNotification
mod_data_upload_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Create data manager instance
    dm <- data_manager$new()

    # Load sample data on initialization
    observe({
      dm$load_sample_data()
    })

    # Handle sample data button
    observeEvent(input$load_sample, {
      if (dm$load_sample_data()) {
        showNotification(
          "Sample data reloaded successfully",
          type = "success",
          duration = 3
        )
      } else {
        showNotification(
          "Failed to load sample data",
          type = "error",
          duration = 5
        )
      }
    })

    # Handle file upload
    observeEvent(input$file, {
      req(input$file)

      if (dm$load_uploaded_data(input$file$datapath)) {
        showNotification(
          "File uploaded successfully",
          type = "success",
          duration = 3
        )
      } else {
        showNotification(
          "Failed to upload file. Please check the format.",
          type = "error",
          duration = 5
        )
      }
    })

    # Return the data manager instance
    dm
  })
}
