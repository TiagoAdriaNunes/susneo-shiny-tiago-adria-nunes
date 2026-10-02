test_that("get_primary_color returns valid hex color", {
  color <- get_primary_color()
  expect_type(color, "character")
  expect_length(color, 1)
  expect_match(color, "^#[0-9A-Fa-f]{6}$")
})

test_that("get_chart_formatter_js returns JS function", {
  formatter <- get_chart_formatter_js()
  expect_s3_class(formatter, "JS_EVAL")
})

test_that("set_global_chart_options sets the thousands separator", {
  options_js <- set_global_chart_options()

  expect_s3_class(options_js, "JS_EVAL")
  expect_match(options_js, "Highcharts.setOptions", fixed = TRUE)
  expect_match(options_js, "thousandsSep", fixed = TRUE)
})

test_that("create_empty_chart creates highchart object", {
  chart <- create_empty_chart()
  expect_s3_class(chart, "highchart")
  expect_equal(chart$x$hc_opts$title$text, "No data available")

  chart_with_title <- create_empty_chart("Custom Title")
  expect_s3_class(chart_with_title, "highchart")
  expect_equal(chart_with_title$x$hc_opts$title$text, "Custom Title")
})
