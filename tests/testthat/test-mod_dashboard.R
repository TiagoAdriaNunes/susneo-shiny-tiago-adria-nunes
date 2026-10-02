full_range <- function() as.Date(c("2025-01-01", "2025-01-02"))

# UI --------------------------------------------------------------------------

test_that("mod_dashboard_ui creates proper UI structure", {
  ui <- mod_dashboard_ui("test")
  # bslib::page_sidebar returns a bslib_page object, which inherits from shiny.tag.list
  expect_s3_class(ui, "bslib_page")
  expect_s3_class(ui, "shiny.tag.list")
})

test_that("mod_dashboard_ui has correct sidebar structure", {
  ui_html <- as.character(mod_dashboard_ui("test"))

  expect_true(grepl('id="test-date_range"', ui_html))
  expect_true(grepl('id="test-facilities"', ui_html))
  expect_true(grepl('id="test-energy_types"', ui_html))
  expect_true(grepl('id="test-reset_filters"', ui_html))
})

test_that("mod_dashboard_ui contains all main components", {
  ui_html <- as.character(mod_dashboard_ui("dashboard"))

  expect_match(ui_html, "Date Range")
  expect_match(ui_html, "Facilities")
  expect_match(ui_html, "Energy Types")
  expect_match(ui_html, "Reset Filters")
  expect_match(ui_html, "Energy Consumption Over Time")
  expect_match(ui_html, "Energy Usage by Facility")
  expect_match(ui_html, "Data Summary")

  # Submodules and the mixed-units warning
  expect_match(ui_html, 'id="dashboard-kpi_cards-total_consumption_box"', fixed = TRUE)
  expect_match(ui_html, 'id="dashboard-linear_model-scatter_plot"', fixed = TRUE)
  expect_match(ui_html, 'id="dashboard-mixed_units_note"', fixed = TRUE)
})

# Server ----------------------------------------------------------------------

test_that("mod_dashboard_server returns the data filtered by the inputs", {
  data <- make_energy_data()

  testServer(mod_dashboard_server, args = list(data_manager = reactive(EnergyDataManager$new(data))), {
    session$setInputs(date_range = full_range(), facilities = NULL, energy_types = NULL)
    session$elapse(600)
    expect_equal(nrow(session$returned()), 5)

    session$setInputs(facilities = "Site_A")
    session$elapse(600)
    expect_equal(unique(session$returned()$site), "Site_A")

    session$setInputs(energy_types = "Gas")
    session$elapse(600)
    expect_equal(session$returned()$value, 500)

    session$setInputs(date_range = as.Date(c("2025-01-01", "2025-01-01")))
    session$elapse(600)
    expect_equal(nrow(session$returned()), 0)
  })
})

test_that("mod_dashboard_server stays silent when there is no data", {
  testServer(mod_dashboard_server, args = list(data_manager = reactive(EnergyDataManager$new(data.frame()))), {
    session$setInputs(date_range = full_range())
    session$elapse(600)

    expect_error(session$returned(), class = "shiny.silent.error")
    expect_error(output$time_series_plot, class = "shiny.silent.error")
  })
})

test_that("mod_dashboard_server follows changes in the data", {
  data_manager <- reactiveVal(EnergyDataManager$new(make_energy_data()))

  testServer(mod_dashboard_server, args = list(data_manager = data_manager), {
    session$setInputs(date_range = full_range())
    session$elapse(600)
    expect_equal(nrow(session$returned()), 5)

    data_manager(EnergyDataManager$new(make_energy_data()[1:2, ]))
    session$flushReact()
    session$elapse(600)
    expect_equal(nrow(session$returned()), 2)
  })
})

test_that("mod_dashboard_server renders the charts and the summary table", {
  data <- make_energy_data()

  testServer(mod_dashboard_server, args = list(data_manager = reactive(EnergyDataManager$new(data))), {
    session$setInputs(date_range = full_range())
    session$elapse(600)

    expect_match(output$time_series_plot, "Daily Energy Consumption")
    expect_match(output$facility_comparison, "Total Energy Consumption by Facility")
    expect_match(output$data_table, "Total Consumption")
  })
})

test_that("mod_dashboard_server warns when the selection mixes energy types", {
  data <- make_energy_data()

  testServer(mod_dashboard_server, args = list(data_manager = reactive(EnergyDataManager$new(data))), {
    session$setInputs(date_range = full_range(), facilities = NULL, energy_types = NULL)
    session$elapse(600)
    expect_match(output$mixed_units_note$html, "combines 3 energy types")

    session$setInputs(energy_types = "Electricity")
    session$elapse(600)
    expect_error(output$mixed_units_note, class = "shiny.silent.error")
  })
})

test_that("mod_dashboard_server handles the reset button", {
  data <- make_energy_data()

  expect_no_error(
    testServer(mod_dashboard_server, args = list(data_manager = reactive(EnergyDataManager$new(data))), {
      session$setInputs(date_range = full_range(), facilities = "Site_A", energy_types = "Gas")
      session$setInputs(reset_filters = 1)
    })
  )
})
