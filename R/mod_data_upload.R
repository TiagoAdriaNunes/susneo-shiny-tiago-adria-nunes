#' data_upload UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_data_upload_ui <- function(id) {
  ns <- NS(id)
  tagList(

  )
}
    
#' data_upload Server Functions
#'
#' @noRd
mod_data_upload_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    sample_data <- reactive({
      tryCatch({
        read.csv("data/sample_data.csv", stringsAsFactors = FALSE)
      }, error = function(e) {
        warning("Could not load data/sample_data.csv: ", e$message)
        data.frame()
      })
    })

    return(sample_data)
  })
}
