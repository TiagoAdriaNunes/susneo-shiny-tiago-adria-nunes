test_that("run_app returns a shiny app object", {
  # Test that run_app creates a proper shiny app
  app <- run_app()

  expect_s3_class(app, "shiny.appobj")
  expect_true(is.function(app$httpHandler))
})

test_that("run_app accepts parameters", {
  # Test with custom options
  app <- run_app(options = list(port = 3838))

  expect_s3_class(app, "shiny.appobj")

  # Test with enableBookmarking
  app_bookmarking <- run_app(enableBookmarking = "server")

  expect_s3_class(app_bookmarking, "shiny.appobj")
})
