#' Linear Model Functions
#'
#' @description Pure functions to fit, summarise and explain the linear model
#' of energy consumption against carbon emissions.

#' Fit a simple linear model
#'
#' @param data Filtered energy data
#' @param x_var Name of the predictor column
#' @param y_var Name of the response column
#'
#' @return An `lm` object, or NULL (with a warning) when the data cannot
#'   support a model: no rows, missing columns, fewer than 3 complete rows, or
#'   no variation in either variable.
#'
#' @noRd
#'
#' @importFrom glue glue
#' @importFrom shiny div h5 strong tags
#' @importFrom stats lm nobs pf reformulate
fit_linear_model <- function(
  data,
  x_var = emissions_column,
  y_var = "value"
) {
  if (nrow(data) == 0) {
    return(NULL)
  }

  if (!all(c(x_var, y_var) %in% names(data))) {
    warning("Specified variables not found in data")
    return(NULL)
  }

  complete <- !is.na(data[[x_var]]) & !is.na(data[[y_var]])
  model_data <- data[complete, , drop = FALSE]

  if (nrow(model_data) < 3) {
    warning("Insufficient data points for linear model (at least 3 are needed)")
    return(NULL)
  }

  if (length(unique(model_data[[x_var]])) < 2 || length(unique(model_data[[y_var]])) < 2) {
    warning("Linear model needs variation in both variables")
    return(NULL)
  }

  tryCatch(
    lm(reformulate(x_var, response = y_var), data = model_data),
    error = function(e) {
      warning("Error fitting linear model: ", conditionMessage(e))
      NULL
    }
  )
}

#' Extract the statistics shown to the user
#'
#' @param model An `lm` object from [fit_linear_model()]
#'
#' @return List with `intercept`, `slope`, `slope_p_value`, `r_squared`,
#'   `adj_r_squared`, `f_statistic`, `p_value` and `n`
#'
#' @noRd
summarise_linear_model <- function(model) {
  # An exact fit is valid data; the R-squared of 1 already tells the user
  model_summary <- suppressWarnings(summary(model))
  coefficients <- model_summary$coefficients
  f <- model_summary$fstatistic

  list(
    intercept = unname(coefficients[1, 1]),
    slope = unname(coefficients[2, 1]),
    slope_p_value = unname(coefficients[2, 4]),
    r_squared = model_summary$r.squared,
    adj_r_squared = model_summary$adj.r.squared,
    f_statistic = unname(f[1]),
    p_value = unname(pf(f[1], f[2], f[3], lower.tail = FALSE)),
    n = nobs(model)
  )
}

#' Explain a p-value in plain language
#'
#' @param p_value Numeric p-value
#'
#' @return String completing "This relationship is ..."
#' @noRd
describe_significance <- function(p_value) {
  if (is.na(p_value)) {
    "could not be assessed - not enough data"
  } else if (p_value < 0.001) {
    "highly significant (p < 0.001) - very strong evidence of a real relationship"
  } else if (p_value < 0.01) {
    "significant (p < 0.01) - strong evidence of a real relationship"
  } else if (p_value < 0.05) {
    "significant (p < 0.05) - evidence of a real relationship"
  } else {
    paste0(
      "not significant (p = ", round(p_value, 3), ") - insufficient evidence of a real relationship. ",
      "This could be due to random chance, small sample size, or no actual relationship exists"
    )
  }
}

#' Explain an R-squared value in plain language
#'
#' @param r_squared Numeric between 0 and 1
#'
#' @return One-sentence description of the model fit
#' @noRd
describe_model_fit <- function(r_squared) {
  if (r_squared >= 0.7) {
    "The model explains the data very well."
  } else if (r_squared >= 0.5) {
    "The model explains the data reasonably well."
  } else if (r_squared >= 0.3) {
    "The model explains some of the variation in the data."
  } else {
    "The model explains little of the variation in the data."
  }
}

#' Build the model summary table
#'
#' @param model_stats List from [summarise_linear_model()]
#'
#' @return Data frame with `Metric`, `Value` and `Interpretation`
#' @noRd
build_model_summary_table <- function(model_stats) {
  data.frame(
    Metric = c(
      "Intercept",
      "CO2 Coefficient",
      "R-squared",
      "Adjusted R-squared",
      "F-statistic",
      "Model p-value",
      "Observations"
    ),
    Value = c(
      round(model_stats$intercept, 3),
      round(model_stats$slope, 3),
      round(model_stats$r_squared, 4),
      round(model_stats$adj_r_squared, 4),
      round(model_stats$f_statistic, 2),
      format(model_stats$p_value, scientific = TRUE, digits = 3),
      model_stats$n
    ),
    Interpretation = c(
      "Energy consumption when CO2 = 0",
      "Energy change per 1 kg CO2 increase",
      "Proportion of variance explained",
      "Adjusted for model complexity",
      "Overall model significance test",
      "Chance of a fit this strong if there were no real relationship",
      "Number of data points used"
    )
  )
}

#' Build the plain-language interpretation
#'
#' @param model_stats List from [summarise_linear_model()]
#'
#' @return Shiny tag with a short explanation of the results
#'
#' @noRd
create_model_interpretation <- function(model_stats) {
  relationship <- if (model_stats$slope > 0) "positive" else "negative"
  slope_rounded <- round(model_stats$slope, 2)
  r_sq_percent <- round(model_stats$r_squared * 100, 1)
  slope_sig <- describe_significance(model_stats$slope_p_value)

  div(
    h5("What do these numbers mean?"),
    tags$ul(
      tags$li(
        strong("Relationship: "),
        glue(
          "There is a {relationship} relationship between CO2 emissions and energy consumption."
        )
      ),
      tags$li(
        strong(glue("Slope ({slope_rounded}): ")),
        glue(
          "For every 1 kg increase in CO2 emissions, ",
          "energy consumption changes by {slope_rounded} units on average."
        )
      ),
      tags$li(
        strong("Statistical Significance: "),
        glue("This relationship is {slope_sig}.")
      ),
      tags$li(
        strong(glue("Model Fit (R\u00b2={r_sq_percent}%): ")),
        describe_model_fit(model_stats$r_squared)
      )
    )
  )
}
