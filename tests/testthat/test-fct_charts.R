test_that("create_time_series_chart handles empty data", {
  session <- shiny::MockShinySession$new()
  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()
    empty_data <- data.frame()

    chart <- create_time_series_chart(empty_data, dm)
    expect_s3_class(chart, "highchart")
  })
})

test_that("create_time_series_chart creates valid chart with data", {
  session <- shiny::MockShinySession$new()
  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()
    test_data <- data.frame(
      date = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03")),
      site = c("Site A", "Site A", "Site A"),
      type = c("Electricity", "Electricity", "Electricity"),
      value = c(100, 150, 200)
    )

    shiny::isolate(dm$raw_data(test_data))
    shiny::isolate(dm$process_data())
    processed_data <- shiny::isolate(dm$processed_data())

    chart <- create_time_series_chart(processed_data, dm)
    expect_s3_class(chart, "highchart")
  })
})

test_that("create_facility_chart handles empty data", {
  session <- shiny::MockShinySession$new()
  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()
    empty_data <- data.frame()

    chart <- create_facility_chart(empty_data, dm)
    expect_s3_class(chart, "highchart")
  })
})

test_that("create_facility_chart creates valid chart with data", {
  session <- shiny::MockShinySession$new()
  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()
    test_data <- data.frame(
      date = as.Date(c("2024-01-01", "2024-01-01", "2024-01-01")),
      site = c("Site A", "Site B", "Site C"),
      type = c("Electricity", "Electricity", "Electricity"),
      value = c(100, 150, 200)
    )

    shiny::isolate(dm$raw_data(test_data))
    shiny::isolate(dm$process_data())
    processed_data <- shiny::isolate(dm$processed_data())

    chart <- create_facility_chart(processed_data, dm)
    expect_s3_class(chart, "highchart")
  })
})

test_that("create_energy_type_chart handles empty data", {
  session <- shiny::MockShinySession$new()
  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()
    empty_data <- data.frame()

    chart <- create_energy_type_chart(empty_data, dm)
    expect_s3_class(chart, "highchart")
  })
})

test_that("create_energy_type_chart creates valid chart with data", {
  session <- shiny::MockShinySession$new()
  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()
    test_data <- data.frame(
      date = as.Date(c("2024-01-01", "2024-01-01", "2024-01-01")),
      site = c("Site A", "Site A", "Site A"),
      type = c("Electricity", "Gas", "Solar"),
      value = c(100, 150, 200)
    )

    chart <- create_energy_type_chart(test_data, dm)
    expect_s3_class(chart, "highchart")
  })
})

test_that("create_trend_chart handles empty data", {
  session <- shiny::MockShinySession$new()
  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()
    empty_data <- data.frame()

    chart <- create_trend_chart(empty_data, dm)
    expect_s3_class(chart, "highchart")
  })
})

test_that("create_trend_chart creates valid chart with data", {
  session <- shiny::MockShinySession$new()
  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()
    # Create data with enough points for moving average
    dates <- seq(as.Date("2024-01-01"), as.Date("2024-01-14"), by = "day")
    test_data <- data.frame(
      date = rep(dates, each = 1),
      site = rep("Site A", length(dates)),
      type = rep("Electricity", length(dates)),
      value = runif(length(dates), 100, 200)
    )

    shiny::isolate(dm$raw_data(test_data))
    shiny::isolate(dm$process_data())
    processed_data <- shiny::isolate(dm$processed_data())

    chart <- create_trend_chart(processed_data, dm)
    expect_s3_class(chart, "highchart")
  })
})