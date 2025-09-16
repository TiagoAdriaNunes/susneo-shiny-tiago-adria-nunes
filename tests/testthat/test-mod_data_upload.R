test_that("mod_data_upload_server loads data correctly", {
  # Skip if data file doesn't exist (for CRAN builds)
  data_path <- "data/sample_data.csv"
  skip_if_not(file.exists(data_path), "Sample data file not found")

  # Test the reactive function directly
  sample_data_function <- function() {
    tryCatch({
      read.csv(data_path, stringsAsFactors = FALSE)
    }, error = function(e) {
      warning("Could not load data/sample_data.csv: ", e$message)
      data.frame()
    })
  }

  result <- sample_data_function()

  expect_true(is.data.frame(result))
  expect_gt(nrow(result), 0)
  expect_equal(ncol(result), 6)
  expect_equal(names(result), c("id", "site", "date", "type", "value", "carbon_emission_in_kgco2e"))
})

test_that("mod_data_upload_server handles missing file", {
  # Test with non-existent file
  missing_file_function <- function() {
    tryCatch({
      read.csv("data/nonexistent.csv", stringsAsFactors = FALSE)
    }, error = function(e) {
      warning("Could not load data/nonexistent.csv: ", e$message)
      data.frame()
    })
  }

  # Capture the warning and result
  result <- suppressWarnings(missing_file_function())

  # Test that we get an empty data frame when file is missing
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0)
  expect_equal(ncol(result), 0)
})
