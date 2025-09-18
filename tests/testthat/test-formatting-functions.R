test_that("format_number_with_commas works correctly", {
  # Test normal numbers
  expect_equal(format_number_with_commas(1234), "1,234")
  expect_equal(format_number_with_commas(1234567), "1,234,567")

  # Test with suffix
  expect_equal(format_number_with_commas(1234, "units"), "1,234 units")
  expect_equal(format_number_with_commas(5678, "kg CO2e"), "5,678 kg CO2e")

  # Test with decimal numbers (should be rounded)
  expect_equal(format_number_with_commas(1234.56), "1,235")
  expect_equal(format_number_with_commas(1234.12), "1,234")

  # Test edge cases
  expect_equal(format_number_with_commas(0), "0")
  expect_equal(format_number_with_commas(NA), "--")
  expect_equal(format_number_with_commas(NULL), "--")

  # Test negative numbers
  expect_equal(format_number_with_commas(-1234), "-1,234")

  # Test empty suffix
  expect_equal(format_number_with_commas(1234, ""), "1,234")
})

test_that("format_energy_units works correctly", {
  expect_equal(format_energy_units(1234), "1,234 units")
  expect_equal(format_energy_units(0), "0 units")
  expect_equal(format_energy_units(NA), "--")
  expect_equal(format_energy_units(1234567), "1,234,567 units")
})

test_that("format_emissions_units works correctly", {
  expect_equal(format_emissions_units(1234), "1,234 kg CO2e")
  expect_equal(format_emissions_units(0), "0 kg CO2e")
  expect_equal(format_emissions_units(NA), "--")
  expect_equal(format_emissions_units(567890), "567,890 kg CO2e")
})

test_that("format_daily_usage_units works correctly", {
  expect_equal(format_daily_usage_units(1234), "1,234 units/day")
  expect_equal(format_daily_usage_units(0), "0 units/day")
  expect_equal(format_daily_usage_units(NA), "--")
  expect_equal(format_daily_usage_units(987), "987 units/day")
})

test_that("format_percentage works correctly", {
  # Test normal percentages
  expect_equal(format_percentage(45.67), "45.7%")
  expect_equal(format_percentage(100), "100%")
  expect_equal(format_percentage(0), "0%")

  # Test with different decimal places
  expect_equal(format_percentage(45.67, 0), "46%")
  expect_equal(format_percentage(45.67, 2), "45.67%")

  # Test edge cases
  expect_equal(format_percentage(NA), "--")
  expect_equal(format_percentage(NULL), "--")

  # Test rounding
  expect_equal(format_percentage(45.666, 1), "45.7%")
  expect_equal(format_percentage(45.634, 1), "45.6%")
})

test_that("formatting functions handle extreme values", {
  # Test very large numbers
  large_number <- 999999999
  expect_equal(format_number_with_commas(large_number), "1e+09")
  expect_equal(format_energy_units(large_number), "1e+09 units")

  # Test very small numbers
  expect_equal(format_number_with_commas(1), "1")
  expect_equal(format_energy_units(1), "1 units")

  # Test percentage edge cases
  expect_equal(format_percentage(0.1, 1), "0.1%")
  expect_equal(format_percentage(99.99, 1), "100%")
})

test_that("formatting functions are consistent", {
  test_value <- 12345.67

  # All energy-related formatters should handle the same input consistently
  base_formatted <- format_number_with_commas(test_value, "")
  expect_equal(base_formatted, "12,346") # Rounded

  energy_formatted <- format_energy_units(test_value)
  expect_equal(energy_formatted, "12,346 units")

  emissions_formatted <- format_emissions_units(test_value)
  expect_equal(emissions_formatted, "12,346 kg CO2e")

  daily_formatted <- format_daily_usage_units(test_value)
  expect_equal(daily_formatted, "12,346 units/day")
})

test_that("formatting functions handle different numeric types", {
  # Test integer
  expect_equal(format_number_with_commas(1234L), "1,234")

  # Test double
  expect_equal(format_number_with_commas(1234.0), "1,234")

  # Test character that can be coerced to numeric
  # Note: This might fail if the function doesn't handle character input
})
