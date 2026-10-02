test_that("app_server function exists and is callable", {
  expect_true(is.function(app_server))

  expect_no_error(
    shiny::testServer(app_server, {
      expect_true(TRUE)
    })
  )
})

test_that("app_server serves the sample data from the data folder to the dashboard", {
  shiny::testServer(app_server, {
    data <- energy_data()

    expect_equal(nrow(data), nrow(sample_data))
    expect_s3_class(data$date, "Date")
  })
})
