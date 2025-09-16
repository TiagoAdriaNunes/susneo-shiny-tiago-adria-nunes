test_that("app_server function exists and is callable", {
  # Test that app_server is a function
  expect_true(is.function(app_server))

  # Test that it can be called with mock session
  expect_no_error({
    shiny::testServer(app_server, {
      # Basic test that server function runs without error
      expect_true(TRUE)
    })
  })
})