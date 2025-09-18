test_that("get_chart_colors returns expected colors", {
  colors <- get_chart_colors()
  expect_type(colors, "character")
  expect_true(length(colors) >= 1)
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", colors)))
})

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

test_that("create_empty_chart creates highchart object", {
  chart <- create_empty_chart()
  expect_s3_class(chart, "highchart")

  chart_with_title <- create_empty_chart("Custom Title")
  expect_s3_class(chart_with_title, "highchart")
})

test_that("get_chart_tooltip_config returns proper structure", {
  config <- get_chart_tooltip_config("Test: {point.y}")
  expect_type(config, "list")
  expect_true("pointFormat" %in% names(config))
  expect_equal(config$pointFormat, "Test: {point.y}")
})

test_that("get_chart_axis_config returns proper structure", {
  config <- get_chart_axis_config("Test Axis")
  expect_type(config, "list")
  expect_true("title" %in% names(config))
  expect_equal(config$title$text, "Test Axis")

  config_with_formatter <- get_chart_axis_config("Test", get_chart_formatter_js())
  expect_true("labels" %in% names(config_with_formatter))
})

test_that("get_standard_chart_config returns complete configuration", {
  config <- get_standard_chart_config(
    title = "Test Chart",
    x_axis_title = "X Axis",
    y_axis_title = "Y Axis",
    tooltip_format = "Value: {point.y}"
  )

  expect_type(config, "list")
  expect_true(all(c("title", "x_axis", "y_axis", "tooltip", "color") %in% names(config)))
  expect_equal(config$title, "Test Chart")
  expect_equal(config$x_axis$title$text, "X Axis")
  expect_equal(config$y_axis$title$text, "Y Axis")
  expect_equal(config$tooltip$pointFormat, "Value: {point.y}")

  # Test with custom color
  config_custom <- get_standard_chart_config(
    title = "Test", x_axis_title = "X", y_axis_title = "Y",
    tooltip_format = "Test", color = "#FF0000"
  )
  expect_equal(config_custom$color, "#FF0000")
})
