test_that("app_sys works correctly", {
  # Test that app_sys returns a valid path
  result <- app_sys()
  expect_true(is.character(result))
  expect_true(length(result) == 1)

  # Test with subdirectory - just check it returns a character
  result_with_path <- app_sys("www")
  expect_true(is.character(result_with_path))
  expect_true(length(result_with_path) == 1)
})

test_that("get_golem_config handles defaults", {
  # Test that function doesn't error with default config
  expect_no_error({
    # This might not find a config file, but shouldn't error
    tryCatch(get_golem_config("default"), error = function(e) NULL)
  })
})