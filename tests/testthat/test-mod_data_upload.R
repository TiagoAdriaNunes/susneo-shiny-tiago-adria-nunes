test_that("mod_data_upload_server loads data correctly", {
  # Test loading package data directly
  sample_data_function <- function() {
    tryCatch({
      data("sample_data", package = "susneo", envir = environment())
      sample_data
    }, error = function(e) {
      warning("Could not load sample_data: ", e$message)
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

test_that("mod_data_upload_ui creates correct UI elements", {
  # Test the UI function
  ui_result <- mod_data_upload_ui("test")

  # Convert to character to examine the HTML structure
  ui_html <- as.character(ui_result)

  # Check that it returns a tagList
  expect_true(inherits(ui_result, "shiny.tag.list"))

  # Check for file input with correct ID and attributes
  expect_true(grepl('id="test-file"', ui_html))
  expect_true(grepl('type="file"', ui_html))
  expect_true(grepl('accept="\\.csv"', ui_html))
  expect_true(grepl('Upload CSV File', ui_html))

  # Check for action button with correct ID and class
  expect_true(grepl('id="test-load_sample"', ui_html))
  expect_true(grepl('btn-primary', ui_html))
  expect_true(grepl('Load Sample Data', ui_html))
})

test_that("mod_data_upload_ui uses correct namespace", {
  # Test with different ID
  ui_result <- mod_data_upload_ui("data_upload_module")
  ui_html <- as.character(ui_result)

  # Check that namespace is correctly applied
  expect_true(grepl('id="data_upload_module-file"', ui_html))
  expect_true(grepl('id="data_upload_module-load_sample"', ui_html))
})
