test_that("create_time_series_chart handles empty data", {
  chart <- create_time_series_chart(data.frame())

  expect_s3_class(chart, "highchart")
  expect_equal(chart$x$hc_opts$title$text, "No data available")
})

test_that("create_time_series_chart plots the daily totals", {
  chart <- create_time_series_chart(make_energy_data())

  expect_s3_class(chart, "highchart")
  expect_equal(chart$x$hc_opts$title$text, "Daily Energy Consumption")
  expect_equal(chart$x$hc_opts$series[[1]]$type, "line")
  expect_length(chart$x$hc_opts$series[[1]]$data, 2)
})

test_that("create_facility_chart handles empty data", {
  chart <- create_facility_chart(data.frame())

  expect_s3_class(chart, "highchart")
  expect_equal(chart$x$hc_opts$title$text, "No data available")
})

test_that("create_facility_chart plots one column per facility", {
  chart <- create_facility_chart(make_energy_data())

  expect_s3_class(chart, "highchart")
  expect_equal(chart$x$hc_opts$title$text, "Total Energy Consumption by Facility")
  expect_equal(chart$x$hc_opts$series[[1]]$type, "column")
  expect_length(chart$x$hc_opts$series[[1]]$data, 3)
})

test_that("charts use the shared primary color", {
  expect_equal(create_time_series_chart(make_energy_data())$x$hc_opts$colors, list(get_primary_color()))
  expect_equal(create_facility_chart(make_energy_data())$x$hc_opts$colors, list(get_primary_color()))
})
