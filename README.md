
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SUSNEO Energy Dashboard

> A comprehensive Shiny application for energy consumption analysis and
> visualization

<!-- badges: start -->

[![CI](https://github.com/TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes/workflows/CI/badge.svg)](https://github.com/TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes/actions)
[![codecov](https://codecov.io/github/TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes/graph/badge.svg?token=C76NX21FLR)](https://codecov.io/github/TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes)
[![R-CMD-check](https://github.com/TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes/workflows/R-CMD-check/badge.svg)](https://github.com/TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes/actions)
<!-- badges: end -->

## Live Demo

**Try the live application**:
<https://tiagoadrianunes.shinyapps.io/susneo-shiny-app/>

## Overview

SUSNEO Energy Dashboard is an interactive energy dashboard built with R
Shiny that provides comprehensive analysis and visualization of energy
consumption data.

The application features:

- **Interactive Charts**: Time series and facility comparison charts
- **Linear Model Analysis**: CO2 emissions vs energy consumption
  correlation with statistical interpretation
- **KPI Metrics**: Real-time calculation of consumption, emissions, and
  efficiency ratios
- **Advanced Filtering**: Date ranges, facilities, and energy types
- **Responsive Design**: Modern UI with bslib and Bootstrap
- **Data Management**: Loads the dataset shipped in the package’s
  `data/` folder and cleans it automatically

## Installation

### Prerequisites

Make sure you have R (\>= 4.1.0) installed on your system.

### Install from GitHub

``` r
# Install from GitHub using devtools
if (!require(devtools)) install.packages("devtools")
devtools::install_github("TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes")

# Or using pak (recommended)
if (!require(pak)) install.packages("pak")
pak::pak("TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes")
```

## Quick Start

### Launch the Application

``` r
# Load the package
library(susneoEnergyDashboard)

# Run the Shiny application
run_app()
```

### Using Sample Data

The application includes sample energy consumption data for
demonstration:

``` r
# Access sample data
data("sample_data", package = "susneoEnergyDashboard")
head(sample_data)
```

### Data Format

The dashboard reads the `sample_data` dataset from the package’s `data/`
folder (`data/sample_data.csv`). It has these columns:

- `id`: Unique identifier
- `site`: Facility/location name
- `date`: Date in DD-MM-YYYY format
- `type`: Energy type (Electricity, Gas, Water, etc.)
- `value`: Energy consumption value
- `carbon_emission_in_kgco2e`: Carbon emissions (optional)

Things to know about the data:

- **Dates are read day first.** A numeric date such as `03-04-2025` is
  read as 3 April (DD-MM-YYYY); layouts such as `2025-04-03` are
  accepted too.
- **Unusable rows are dropped** when the data is loaded: rows with an
  unreadable date or a non-numeric `value`. A missing
  `carbon_emission_in_kgco2e` counts as 0.
- **`value` has no unit.** Electricity, gas, water and the other types
  are measured in different units. When a selection mixes energy types
  the dashboard shows a warning, because the totals, charts and the
  linear model add those values together as they are. Select a single
  energy type for a like-for-like comparison.

## Features

### Dashboard Components

- **KPI Cards**: Display key metrics including total consumption,
  emissions, daily averages, efficiency ratios, peak usage, and facility
  counts
- **Time Series Chart**: Interactive line chart showing energy
  consumption trends over time
- **Facility Comparison**: Column chart comparing total energy usage
  across different facilities
- **Linear Model Analysis**: Statistical analysis of CO2 emissions vs
  energy consumption relationship with:
  - Interactive scatter plot with regression line
  - Model summary table (coefficients, R-squared, F-statistic)
  - Plain-language interpretation of statistical significance
  - Relationship strength and direction analysis
- **Data Table**: Detailed summary table with filtering and sorting
  capabilities
- **Mixed-units warning**: Shown above the KPI cards whenever the
  selection combines several energy types

### Data Management

- **Sample Data**: Built-in dataset loaded from the package’s `data/`
  folder
- **Data Cleaning**: Dates are parsed and values checked; unusable rows
  are dropped
- **Date Processing**: Flexible date parsing supporting multiple
  formats; ambiguous numeric dates are read day first (DD-MM-YYYY)

### Filtering & Interactivity

- **Date Range Selection**: Filter data by custom date periods
- **Facility Selection**: Multi-select filtering by facility/site
- **Energy Type Selection**: Filter by specific energy types
- **Real-time Updates**: All charts and metrics update dynamically

## Usage Examples

### Basic Usage

``` r
# Start the application
susneoEnergyDashboard::run_app()

# The app opens in your default browser and shows the sample data
```

## Development

### Building from Source

``` r
# Clone the repository
git clone https://github.com/TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes.git
cd susneo-shiny-tiago-adria-nunes

# Install development dependencies
devtools::install_deps(dependencies = TRUE)

# Load and test
devtools::load_all()
devtools::test()

# Run the app in development mode
devtools::load_all()
run_app()
```

### Package Structure

    susneo/
    ├── R/                          # R source code
    │   ├── app_*.R                # App configuration
    │   ├── mod_*.R                # Shiny modules
    │   ├── fct_*.R                # Business logic as pure functions (data, charts, KPIs, linear model)
    │   └── utils_*.R              # Utility functions
    ├── data/                      # Package data
    ├── tests/                     # Unit tests
    ├── inst/                      # Package assets
    └── .github/workflows/         # CI/CD configuration

## Contributing

1.  Fork the repository
2.  Create a feature branch (`git checkout -b feature/amazing-feature`)
3.  Commit your changes (`git commit -m 'Add amazing feature'`)
4.  Push to the branch (`git push origin feature/amazing-feature`)
5.  Open a Pull Request

## License

This project is licensed under the MIT License.

## Version Info

**Version**: 0.0.1 **Compiled**: 2026-10-02 01:00:24.645816

## Development Status

    #> Package: Development version loaded ✅
    #> ✔ | F W  S  OK | Context
    #> ⠏ |          0 | app_config                                                     ⠸ |          4 | app_config                                                     ✔ |          5 | app_config
    #> ⠏ |          0 | app_server                                                     ⠙ |          2 | app_server                                                     ⠸ |          4 | app_server                                                     ✔ |          5 | app_server
    #> ⠏ |          0 | app_ui                                                         ⠋ |          1 | app_ui                                                         ⠴ |          6 | app_ui                                                         ⠇ |          9 | app_ui                                                         ✔ |          9 | app_ui [2.1s]
    #> ⠏ |          0 | data                                                           ⠼ |          5 | data                                                           ⠹ |         13 | data                                                           ✔ |         16 | data
    #> ⠏ |          0 | fct_charts                                                     ⠹ |          3 | fct_charts                                                     ⠇ |          9 | fct_charts                                                     ⠹ |         13 | fct_charts                                                     ✔ |         14 | fct_charts
    #> ⠏ |          0 | fct_data                                                       ⠹ |          3 | fct_data                                                       ⠇ |          9 | fct_data                                                       ⠸ |         14 | fct_data                                                       ⠏ |         20 | fct_data                                                       ⠸ |         24 | fct_data                                                       ⠇ |         29 | fct_data                                                       ⠸ |         34 | fct_data                                                       ⠇ |         39 | fct_data                                                       ⠸ |         44 | fct_data                                                       ⠧ |         48 | fct_data                                                       ⠹ |         53 | fct_data                                                       ✔ |         54 | fct_data [1.2s]
    #> ⠏ |          0 | fct_linear_model                                               ⠸ |          4 | fct_linear_model                                               ⠦ |          7 | fct_linear_model                                               ⠹ |         13 | fct_linear_model                                               ⠧ |         18 | fct_linear_model                                               ⠇ |         29 | fct_linear_model                                               ⠧ |         38 | fct_linear_model                                               ⠴ |         46 | fct_linear_model                                               ✔ |         47 | fct_linear_model
    #> ⠏ |          0 | fct_value_boxes                                                ⠦ |          7 | fct_value_boxes                                                ⠙ |         12 | fct_value_boxes                                                ⠧ |         18 | fct_value_boxes                                                ⠹ |         23 | fct_value_boxes                                                ⠋ |         31 | fct_value_boxes                                                ⠋ |         41 | fct_value_boxes                                                ⠧ |         48 | fct_value_boxes                                                ⠸ |         54 | fct_value_boxes                                                ⠏ |         60 | fct_value_boxes                                                ⠦ |         67 | fct_value_boxes                                                ⠹ |         73 | fct_value_boxes                                                ✔ |         74 | fct_value_boxes [1.4s]
    #> ⠏ |          0 | formatting-functions                                           ⠼ |          5 | formatting-functions                                           ⠙ |         12 | formatting-functions                                           ⠇ |         19 | formatting-functions                                           ⠼ |         25 | formatting-functions                                           ⠙ |         32 | formatting-functions                                           ✔ |         36 | formatting-functions
    #> ⠏ |          0 | mod_dashboard                                                  ⠋ |          1 | mod_dashboard                                                  ⠹ |          3 | mod_dashboard                                                  ⠦ |          7 | mod_dashboard                                                  ⠦ |         17 | mod_dashboard                                                  ⠧ |         18 | mod_dashboard                                                  ⠇ |         19 | mod_dashboard                                                  ⠏ |         20 | mod_dashboard                                                  ⠋ |         21 | mod_dashboard                                                  ⠹ |         23 | mod_dashboard                                                  ⠸ |         24 | mod_dashboard                                                  ⠼ |         25 | mod_dashboard                                                  ⠧ |         28 | mod_dashboard                                                  ⠇ |         29 | mod_dashboard                                                  ⠏ |         30 | mod_dashboard                                                  ✔ |         30 | mod_dashboard [7.6s]
    #> ⠏ |          0 | mod_kpi_cards                                                  ⠦ |          7 | mod_kpi_cards                                                  ⠼ |         15 | mod_kpi_cards                                                  ⠦ |         17 | mod_kpi_cards                                                  ⠹ |         23 | mod_kpi_cards                                                  ⠸ |         24 | mod_kpi_cards                                                  ⠼ |         25 | mod_kpi_cards                                                  ✔ |         30 | mod_kpi_cards [1.2s]
    #> ⠏ |          0 | mod_linear_model                                               ⠦ |          7 | mod_linear_model                                               ⠧ |          8 | mod_linear_model                                               ⠸ |         14 | mod_linear_model                                               ⠧ |         18 | mod_linear_model                                               ⠙ |         22 | mod_linear_model                                               ⠹ |         23 | mod_linear_model                                               ⠼ |         25 | mod_linear_model                                               ⠇ |         29 | mod_linear_model                                               ⠙ |         32 | mod_linear_model                                               ✔ |         33 | mod_linear_model [1.3s]
    #> ⠏ |          0 | run_app                                                        ✔ |          4 | run_app
    #> ⠏ |          0 | utils_charts                                                   ⠏ |         10 | utils_charts                                                   ✔ |         11 | utils_charts
    #> 
    #> ══ Results ═════════════════════════════════════════════════════════════════════
    #> Duration: 17.8 s
    #> 
    #> [ FAIL 0 | WARN 0 | SKIP 0 | PASS 368 ]
    #> Tests: All tests passing ✅
    #> Coverage: See CI badges for coverage status
    #> CI Status: See badges above for current build status

### Package Coverage

``` r
covr::package_coverage()
#> susneoEnergyDashboard Coverage: 99.58%
#> R/fct_linear_model.R: 98.20%
#> R/mod_linear_model.R: 99.03%
#> R/app_config.R: 100.00%
#> R/app_server.R: 100.00%
#> R/app_ui.R: 100.00%
#> R/fct_charts.R: 100.00%
#> R/fct_data.R: 100.00%
#> R/fct_value_boxes.R: 100.00%
#> R/mod_dashboard.R: 100.00%
#> R/mod_kpi_cards.R: 100.00%
#> R/run_app.R: 100.00%
#> R/utils_charts.R: 100.00%
#> R/utils_formatting.R: 100.00%
```

### Recent Updates

#### Version 0.0.1

- **Fixed**: the linear model no longer fails when emissions do not
  vary; it needs at least 3 complete rows, and the p-value explanation
  is corrected
- **Fixed**: large round totals are no longer shown in scientific
  notation (for example `1e+06`)
- **Added**: warning when a selection mixes energy types (they can use
  different units)
- **Changed**: the data layer is now plain functions (`fct_data.R`,
  `fct_linear_model.R`) instead of an R6 class, and all package code
  uses `importFrom` instead of `pkg::fn`
- **Removed**: the CSV upload and “Load Sample Data” code, which was
  never reachable from the app, and the energy type pie chart and trend
  chart, which were never displayed

#### Version 0.0.0.9010

- **Linear Model Analysis**: New statistical analysis module for CO2
  emissions vs energy consumption
  - Interactive scatter plot with regression line visualization
  - Comprehensive model summary table with statistical metrics
  - Plain-language interpretation of results and significance levels
  - Modular architecture following best practices
  - Full test coverage with realistic data scenarios

#### Previous Updates

- Comprehensive test suite with 320+ tests
- Enhanced module test coverage (dashboard, KPI cards, data upload,
  linear model)
- CI/CD pipeline with multi-platform testing
- Code coverage tracking
- Automated linting and code quality checks
- Documentation with pkgdown
- Sample data and example usage
- Resolved namespace conflicts and import issues
- Adjusted the Value Boxes

### Known Issues

- Check [Issues
  page](https://github.com/TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes/issues)
  for current status

### Roadmap

- [x] Linear model analysis for CO2 vs energy correlation ✅
  (v0.0.0.9010)
- [ ] Enhanced data visualization options
- [ ] Export functionality for charts and reports
- [ ] Advanced statistical models (multiple regression, time series
  analysis)
- [ ] Advanced filtering and aggregation features
- [ ] Performance optimizations for large datasets
