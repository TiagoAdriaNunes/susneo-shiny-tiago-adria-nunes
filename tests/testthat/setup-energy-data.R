# Small datasets shared by several test files. This is a setup file (not helper-*.R) because
# Config/testthat/load-all sets helpers = FALSE, which skips helper files when testing from source.

# Five rows, two days, three sites, three energy types
make_energy_data <- function() {
  data.frame(
    site = c("Site_A", "Site_A", "Site_B", "Site_B", "Site_C"),
    date = as.Date(c("2025-01-01", "2025-01-02", "2025-01-01", "2025-01-02", "2025-01-01")),
    type = c("Electricity", "Gas", "Electricity", "Water", "Electricity"),
    value = c(1000, 500, 750, 300, 1200),
    carbon_emission_in_kgco2e = c(100, 50, 75, 30, 120)
  )
}

# Same shape as make_energy_data() but a single energy type
make_single_type_data <- function() {
  data <- make_energy_data()
  data$type <- "Electricity"
  data
}
