test_that("mod_kpi_cards_extended_ui creates correct UI structure", {
  # Test the extended UI function
  ui_result <- mod_kpi_cards_extended_ui("test_kpi")

  # Check that it returns a tagList
  expect_true(inherits(ui_result, "shiny.tag.list"))

  # Convert to character to examine the HTML structure
  ui_html <- as.character(ui_result)

  # Check for primary KPI boxes (first row)
  expect_true(grepl('id="test_kpi-total_consumption_box"', ui_html))
  expect_true(grepl('id="test_kpi-total_emissions_box"', ui_html))
  expect_true(grepl('id="test_kpi-avg_daily_usage_box"', ui_html))

  # Check for secondary KPI boxes (second row)
  expect_true(grepl('id="test_kpi-peak_usage_box"', ui_html))
  expect_true(grepl('id="test_kpi-efficiency_box"', ui_html))
  expect_true(grepl('id="test_kpi-facilities_count_box"', ui_html))

  # Check that there are output elements with correct class
  expect_true(grepl('class="shiny-html-output"', ui_html))
})

test_that("mod_kpi_cards_extended_ui uses correct namespace", {
  # Test with different module ID
  ui_result <- mod_kpi_cards_extended_ui("dashboard_kpis")
  ui_html <- as.character(ui_result)

  # Check that namespace is correctly applied to all elements
  expect_true(grepl('id="dashboard_kpis-total_consumption_box"', ui_html))
  expect_true(grepl('id="dashboard_kpis-total_emissions_box"', ui_html))
  expect_true(grepl('id="dashboard_kpis-avg_daily_usage_box"', ui_html))
  expect_true(grepl('id="dashboard_kpis-peak_usage_box"', ui_html))
  expect_true(grepl('id="dashboard_kpis-efficiency_box"', ui_html))
  expect_true(grepl('id="dashboard_kpis-facilities_count_box"', ui_html))
})

test_that("mod_kpi_cards_extended_ui has correct layout structure", {
  ui_result <- mod_kpi_cards_extended_ui("test")

  # Check that we have a tagList with 2 elements (two layout_columns)
  expect_true(inherits(ui_result, "shiny.tag.list"))
  expect_equal(length(ui_result), 2)

  # Check that each element in the tagList is a bslib-layout-columns
  expect_true(all(sapply(ui_result, function(x) x$name == "bslib-layout-columns")))

  # Check that each layout has children (bslib creates 5 children including grid spacing)
  expect_true(length(ui_result[[1]]$children) > 0)  # First row has children
  expect_true(length(ui_result[[2]]$children) > 0)  # Second row has children

  # Check that we have the expected number of uiOutput elements in the HTML
  ui_html <- as.character(ui_result)
  uiOutput_count <- length(gregexpr('class="shiny-html-output"', ui_html)[[1]])
  expect_equal(uiOutput_count, 6)  # 6 KPI boxes total
})

test_that("mod_kpi_cards_ui creates correct basic UI structure", {
  # Test the basic UI function
  ui_result <- mod_kpi_cards_ui("basic_kpi")

  # Check that it returns a single bslib-layout-columns element
  expect_true(inherits(ui_result, "shiny.tag"))
  expect_equal(ui_result$name, "bslib-layout-columns")

  # Check that it has children (bslib creates 5 children including grid spacing)
  expect_true(length(ui_result$children) > 0)

  # Convert to character and check for the three basic KPI boxes
  ui_html <- as.character(ui_result)
  expect_true(grepl('id="basic_kpi-total_consumption_box"', ui_html))
  expect_true(grepl('id="basic_kpi-total_emissions_box"', ui_html))
  expect_true(grepl('id="basic_kpi-avg_daily_usage_box"', ui_html))

  # Should NOT contain extended KPI boxes
  expect_false(grepl('id="basic_kpi-peak_usage_box"', ui_html))
  expect_false(grepl('id="basic_kpi-efficiency_box"', ui_html))
  expect_false(grepl('id="basic_kpi-facilities_count_box"', ui_html))

  # Check that we have exactly 3 uiOutput elements
  uiOutput_count <- length(gregexpr('class="shiny-html-output"', ui_html)[[1]])
  expect_equal(uiOutput_count, 3)
})
