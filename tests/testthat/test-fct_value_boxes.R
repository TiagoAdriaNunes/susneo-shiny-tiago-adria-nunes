box_html <- function(box) {
  expect_true(inherits(box, "shiny.tag"))
  expect_equal(box$name, "div")
  as.character(box)
}

empty_energy_data <- function() {
  data.frame(
    site = character(0),
    date = character(0),
    type = character(0),
    value = numeric(0),
    carbon_emission_in_kgco2e = numeric(0)
  )
}

# Efficiency ------------------------------------------------------------------

test_that("create_efficiency_value_box calculates efficiency correctly with valid data", {
  # 1500 consumption / 150 emissions = 10
  data <- data.frame(
    site = c("Site_A", "Site_B"),
    date = c("01-08-2025", "02-08-2025"),
    type = c("Electricity", "Gas"),
    value = c(1000, 500),
    carbon_emission_in_kgco2e = c(100, 50)
  )

  html <- box_html(create_efficiency_value_box(data))

  expect_match(html, "Energy Efficiency Ratio")
  expect_match(html, "10 units/kg CO2e")
  expect_match(html, "speedometer2")
  expect_match(html, "success")
})

test_that("create_efficiency_value_box is 0 when there are no emissions", {
  data <- data.frame(
    site = c("Site_A", "Site_B"),
    date = c("01-08-2025", "02-08-2025"),
    type = c("Electricity", "Gas"),
    value = c(1000, 500),
    carbon_emission_in_kgco2e = c(0, 0)
  )

  expect_match(box_html(create_efficiency_value_box(data)), "0 units/kg CO2e")
})

test_that("create_efficiency_value_box handles empty data", {
  html <- box_html(create_efficiency_value_box(empty_energy_data()))

  expect_match(html, "Energy Efficiency Ratio")
  expect_match(html, "0 units/kg CO2e")
  expect_match(box_html(create_efficiency_value_box(data.frame())), "0 units/kg CO2e")
})

test_that("create_efficiency_value_box formats the ratio", {
  data <- data.frame(
    site = "Site_A", date = "01-08-2025", type = "Electricity",
    value = 1500, carbon_emission_in_kgco2e = 250
  )

  expect_match(box_html(create_efficiency_value_box(data)), "6 units/kg CO2e")
})

# Other boxes -----------------------------------------------------------------

test_that("create_consumption_value_box works correctly", {
  html <- box_html(create_consumption_value_box(make_energy_data()))

  expect_match(html, "Total Energy Consumption")
  expect_match(html, "3,750 units")
  expect_match(html, "lightning-charge")
})

test_that("create_emissions_value_box works correctly", {
  html <- box_html(create_emissions_value_box(make_energy_data()))

  expect_match(html, "Total Carbon Emissions")
  expect_match(html, "375 kg CO2e")
  expect_match(html, "cloud")
})

test_that("create_usage_value_box works correctly", {
  html <- box_html(create_usage_value_box(make_energy_data()))

  expect_match(html, "Average Daily Usage")
  expect_match(html, "1,875 units/day")
  expect_match(html, "calendar3")
})

test_that("create_peak_usage_value_box shows the busiest day", {
  html <- box_html(create_peak_usage_value_box(make_energy_data()))

  expect_match(html, "Peak Daily Usage")
  expect_match(html, "2,950 units")
  expect_match(html, "graph-up")
})

test_that("create_peak_usage_value_box handles empty data", {
  expect_match(box_html(create_peak_usage_value_box(data.frame())), "--")
})

test_that("create_facilities_value_box counts distinct facilities", {
  html <- box_html(create_facilities_value_box(make_energy_data()))

  expect_match(html, "Active Facilities")
  expect_match(html, "3 facilities")
  expect_match(html, "building")
})

test_that("create_facilities_value_box handles empty data", {
  html <- box_html(create_facilities_value_box(empty_energy_data()))

  expect_match(html, "Active Facilities")
  expect_match(html, ">0<")
})

test_that("value boxes show zeros for empty data", {
  expect_match(box_html(create_consumption_value_box(data.frame())), "0 units")
  expect_match(box_html(create_emissions_value_box(data.frame())), "0 kg CO2e")
  expect_match(box_html(create_usage_value_box(data.frame())), "0 units/day")
})
