make_model_data <- function() {
  data.frame(
    date = as.Date("2024-01-01") + 0:5,
    site = rep(c("Site A", "Site B"), 3),
    type = "Electricity",
    value = c(8156, 96086, 12805, 46952, 75316, 40284),
    carbon_emission_in_kgco2e = c(28, 79, 62, 75, 1, 53)
  )
}

# fit_linear_model ------------------------------------------------------------

test_that("fit_linear_model fits value against emissions", {
  data <- make_model_data()
  model <- fit_linear_model(data)

  expect_s3_class(model, "lm")
  expect_equal(nobs(model), 6)
  expect_equal(
    unname(coef(model)),
    unname(coef(lm(value ~ carbon_emission_in_kgco2e, data = data)))
  )
})

test_that("fit_linear_model accepts other variables", {
  data <- make_model_data()
  data$other <- c(1, 3, 2, 5, 4, 7)

  model <- fit_linear_model(data, x_var = "other", y_var = "value")
  expect_named(coef(model), c("(Intercept)", "other"))
})

test_that("fit_linear_model ignores rows with missing values", {
  data <- make_model_data()
  data$value[1] <- NA
  data$carbon_emission_in_kgco2e[2] <- NA

  expect_equal(nobs(fit_linear_model(data)), 4)
})

test_that("fit_linear_model returns NULL when there is nothing to model", {
  expect_null(fit_linear_model(data.frame()))
  expect_warning(
    expect_null(fit_linear_model(data.frame(value = 1:5))),
    "not found"
  )
})

test_that("fit_linear_model needs at least three complete rows", {
  data <- make_model_data()

  expect_warning(expect_null(fit_linear_model(data[1:2, ])), "Insufficient data")

  data$value[3:6] <- NA
  expect_warning(expect_null(fit_linear_model(data)), "Insufficient data")
})

test_that("fit_linear_model needs variation in both variables", {
  constant_x <- make_model_data()
  constant_x$carbon_emission_in_kgco2e <- 5
  expect_warning(expect_null(fit_linear_model(constant_x)), "variation")

  constant_y <- make_model_data()
  constant_y$value <- 100
  expect_warning(expect_null(fit_linear_model(constant_y)), "variation")
})

# summarise_linear_model ------------------------------------------------------

test_that("summarise_linear_model reports the statistics of the fit", {
  model <- fit_linear_model(make_model_data())
  model_summary <- summary(model)
  stats <- summarise_linear_model(model)

  expect_equal(stats$intercept, unname(coef(model)[1]))
  expect_equal(stats$slope, unname(coef(model)[2]))
  expect_equal(stats$slope_p_value, unname(model_summary$coefficients[2, 4]))
  expect_equal(stats$r_squared, model_summary$r.squared)
  expect_equal(stats$adj_r_squared, model_summary$adj.r.squared)
  expect_equal(stats$n, 6)
  # With one predictor the F test and the slope t test have the same p-value
  expect_equal(stats$p_value, stats$slope_p_value)
})

# Plain-language helpers ------------------------------------------------------

test_that("describe_significance matches the p-value thresholds", {
  expect_match(describe_significance(0.0005), "^highly significant \\(p < 0.001\\)")
  expect_match(describe_significance(0.005), "^significant \\(p < 0.01\\)")
  expect_match(describe_significance(0.03), "^significant \\(p < 0.05\\)")
  expect_match(describe_significance(0.1), "^not significant \\(p = 0.1\\)")
  expect_match(describe_significance(NA_real_), "could not be assessed")
})

test_that("describe_model_fit matches the R-squared thresholds", {
  expect_match(describe_model_fit(0.8), "very well")
  expect_match(describe_model_fit(0.7), "very well")
  expect_match(describe_model_fit(0.6), "reasonably well")
  expect_match(describe_model_fit(0.4), "some of the variation")
  expect_match(describe_model_fit(0.2), "little of the variation")
})

# Output builders -------------------------------------------------------------

test_that("build_model_summary_table has one row per statistic", {
  stats <- summarise_linear_model(fit_linear_model(make_model_data()))
  table <- build_model_summary_table(stats)

  expect_named(table, c("Metric", "Value", "Interpretation"))
  expect_equal(
    table$Metric,
    c("Intercept", "CO2 Coefficient", "R-squared", "Adjusted R-squared",
      "F-statistic", "Model p-value", "Observations")
  )
  expect_equal(table$Value[table$Metric == "Observations"], "6")
  expect_equal(table$Value[table$Metric == "CO2 Coefficient"], as.character(round(stats$slope, 3)))
})

test_that("build_model_summary_table does not describe the p-value as the chance the model is wrong", {
  stats <- summarise_linear_model(fit_linear_model(make_model_data()))
  table <- build_model_summary_table(stats)

  p_value_row <- table$Interpretation[table$Metric == "Model p-value"]
  expect_false(grepl("due to chance", p_value_row))
  expect_match(p_value_row, "no real relationship")
})

test_that("create_model_interpretation explains direction, slope, significance and fit", {
  stats <- list(
    intercept = 10, slope = 2.5, slope_p_value = 0.0004, r_squared = 0.82,
    adj_r_squared = 0.8, f_statistic = 50, p_value = 0.0004, n = 20
  )
  html <- as.character(create_model_interpretation(stats))

  expect_match(html, "positive relationship")
  expect_match(html, "changes by 2.5 units")
  expect_match(html, "highly significant")
  expect_match(html, "82%")
  expect_match(html, "explains the data very well")

  stats$slope <- -1
  expect_match(as.character(create_model_interpretation(stats)), "negative relationship")
})

test_that("summarise_linear_model accepts an exact fit without warnings", {
  data <- make_model_data()
  data$value <- data$carbon_emission_in_kgco2e * 10

  stats <- NULL
  expect_no_warning(stats <- summarise_linear_model(fit_linear_model(data)))
  expect_equal(stats$r_squared, 1)
})
