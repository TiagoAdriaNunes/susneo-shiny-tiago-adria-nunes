#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @importFrom shiny tagList useBusyIndicators
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Set global Highcharts options for number formatting
    shiny::tags$script(htmlwidgets::JS(
      "
      Highcharts.setOptions({
        lang: {
          thousandsSep: ','
        }
      });
    "
    )),
    # Set global date picker locale to US format
    shiny::tags$script(
      "
      $.fn.datepicker.defaults.format = 'mm/dd/yyyy';
      $.fn.datepicker.defaults.language = 'en';
    "
    ),
    # Enable busy indicators
    useBusyIndicators(spinners = TRUE, pulse = TRUE, fade = TRUE),
    # Your application UI logic
    mod_dashboard_ui("energy_dashboard")
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @importFrom shiny tags
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "SUSNEO Energy Dashboard"
    ),
    # Add responsive value box styles
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "responsive-value-boxes.css"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
