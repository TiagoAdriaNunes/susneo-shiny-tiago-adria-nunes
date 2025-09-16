
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `{susneo}`

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes/graph/badge.svg)](https://app.codecov.io/gh/TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes)
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
#> [1] "2025-09-16 14:08:53 -03"
```

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ℹ Loading susneo
#> ── R CMD check results ──────────────────────────────────────────────────────────────────────────────────────────────────────── susneo 0.0.0.9000 ────
#> Duration: 43.3s
#> 
#> ❯ checking for missing documentation entries ... WARNING
#>   Undocumented code objects:
#>     'sample_data'
#>   Undocumented data sets:
#>     'sample_data'
#>   All user-level objects in a package should have documentation entries.
#>   See chapter 'Writing R documentation files' in the 'Writing R
#>   Extensions' manual.
#> 
#> ❯ checking for future file timestamps ... NOTE
#>   unable to verify current time
#> 
#> ❯ checking DESCRIPTION meta-information ... NOTE
#>   License components which are templates and need '+ file LICENSE':
#>     MIT
#> 
#> ❯ checking top-level files ... NOTE
#>   Non-standard file/directory found at top level:
#>     'README.html'
#> 
#> ❯ checking dependencies in R code ... NOTE
#>   Namespaces in Imports field not imported from:
#>     'DT' 'attempt' 'glue' 'htmltools' 'pkgload'
#>     All declared Imports should be used.
#> 
#> 0 errors ✔ | 1 warning ✖ | 4 notes ✖
```

``` r
covr::package_coverage()
#> susneo Coverage: 70.00%
#> R/mod_data_upload.R: 0.00%
#> R/app_config.R: 100.00%
#> R/app_ui.R: 100.00%
#> R/run_app.R: 100.00%
```
