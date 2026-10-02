box_ids <- c(
  "total_consumption_box", "total_emissions_box", "avg_daily_usage_box",
  "peak_usage_box", "efficiency_box", "facilities_count_box"
)

test_that("mod_kpi_cards_ui creates the six KPI outputs", {
  ui_result <- mod_kpi_cards_ui("test_kpi")
  ui_html <- as.character(ui_result)

  expect_true(inherits(ui_result, "shiny.tag.list"))
  for (box_id in box_ids) {
    expect_true(grepl(paste0('id="test_kpi-', box_id, '"'), ui_html, fixed = TRUE), info = box_id)
  }
  expect_equal(length(gregexpr('class="shiny-html-output"', ui_html)[[1]]), 6)
})

test_that("mod_kpi_cards_ui uses correct namespace", {
  ui_html <- as.character(mod_kpi_cards_ui("dashboard_kpis"))

  for (box_id in box_ids) {
    expect_true(grepl(paste0('id="dashboard_kpis-', box_id, '"'), ui_html, fixed = TRUE), info = box_id)
  }
})

test_that("mod_kpi_cards_ui lays out two rows of three cards", {
  ui_result <- mod_kpi_cards_ui("test")

  expect_equal(length(ui_result), 2)
  expect_true(all(vapply(ui_result, function(x) {
    x$name == "div" && "bslib_fragment" %in% class(x)
  }, logical(1))))
})

test_that("mod_kpi_cards_server renders each KPI from the filtered data", {
  data <- make_energy_data()

  testServer(mod_kpi_cards_server, args = list(filtered_data = reactive(data)), {
    expect_match(output$total_consumption_box$html, "3,750 units")
    expect_match(output$total_emissions_box$html, "375 kg CO2e")
    expect_match(output$avg_daily_usage_box$html, "1,875 units/day")
    expect_match(output$peak_usage_box$html, "2,950 units")
    expect_match(output$efficiency_box$html, "10 units/kg CO2e")
    expect_match(output$facilities_count_box$html, "3 facilities")
  })
})

test_that("mod_kpi_cards_server updates when the data changes", {
  filtered_data <- reactiveVal(make_energy_data())

  testServer(mod_kpi_cards_server, args = list(filtered_data = filtered_data), {
    expect_match(output$total_consumption_box$html, "3,750 units")

    filtered_data(make_energy_data()[1:2, ])
    session$flushReact()
    expect_match(output$total_consumption_box$html, "1,500 units")
  })
})

test_that("mod_kpi_cards_server shows zeros for empty data", {
  testServer(mod_kpi_cards_server, args = list(filtered_data = reactive(data.frame())), {
    expect_match(output$total_consumption_box$html, "0 units")
    expect_match(output$total_emissions_box$html, "0 kg CO2e")
    expect_match(output$avg_daily_usage_box$html, "0 units/day")
    expect_match(output$peak_usage_box$html, "--")
    expect_match(output$efficiency_box$html, "0 units/kg CO2e")
    expect_match(output$facilities_count_box$html, ">0<")
  })
})
