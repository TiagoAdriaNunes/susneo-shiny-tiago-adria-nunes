
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `{susneo}`

<!-- badges: start -->

<!-- badges: end -->

## Installation

You can install the development version of `{susneo}` like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

## Run

You can launch the application by running:

``` r
susneo::run_app()
```

## About

You are reading the doc about version : 0.0.0.9000

This README has been compiled on the

``` r
Sys.time()
#> [1] "2025-09-16 12:38:17 -03"
```

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ℹ Loading susneo
#> ── R CMD check results ──────────────────────────────────────────────────────────────────────────────────────────────────────── susneo 0.0.0.9000 ────
#> Duration: 37.8s
#> 
#> ❯ checking DESCRIPTION meta-information ... NOTE
#>   License components which are templates and need '+ file LICENSE':
#>     MIT
#> 
#> ❯ checking dependencies in R code ... NOTE
#>   Namespaces in Imports field not imported from:
#>     'DT' 'attempt' 'glue' 'htmltools' 'pkgload'
#>     All declared Imports should be used.
#> 
#> 0 errors ✔ | 0 warnings ✔ | 2 notes ✖
```

``` r
covr::package_coverage()
#> susneo Coverage: 68.57%
#> R/run_app.R: 0.00%
#> R/app_config.R: 100.00%
#> R/app_ui.R: 100.00%
```
