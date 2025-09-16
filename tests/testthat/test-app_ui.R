test_that("app_ui returns valid HTML", {
  # Test that app_ui creates proper HTML structure
  ui_result <- app_ui(request = NULL)

  expect_s3_class(ui_result, "shiny.tag.list")
  expect_true(length(ui_result) > 0)
})

test_that("golem_add_external_resources creates head tags", {
  # Test external resources function
  resources <- golem_add_external_resources()

  expect_s3_class(resources, "shiny.tag")
  expect_equal(resources$name, "head")
  expect_true(length(resources$children) > 0)
})