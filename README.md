SUSNEO Energy Dashboard
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

# SUSNEO Energy Dashboard

> A comprehensive Shiny application for energy consumption analysis and
> visualization

<!-- badges: start -->

[![CI](https://github.com/TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes/workflows/CI/badge.svg)](https://github.com/TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes/actions)
[![Codecov test
coverage](https://codecov.io/gh/TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes/graph/badge.svg)](https://app.codecov.io/gh/TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes)
[![R-CMD-check](https://github.com/TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes/workflows/R-CMD-check/badge.svg)](https://github.com/TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes/actions)
<!-- badges: end -->

## Overview

SUSNEO is an interactive energy dashboard built with R Shiny that
provides comprehensive analysis and visualization of energy consumption
data. The application features:

- **Interactive Charts**: Time series, facility comparisons, and energy
  type distributions
- **KPI Metrics**: Real-time calculation of consumption, emissions, and
  efficiency ratios
- **Advanced Filtering**: Date ranges, facilities, and energy types
- **Responsive Design**: Modern UI with bslib and Bootstrap
- **Data Management**: CSV upload functionality with sample data

## Installation

### Prerequisites

Make sure you have R (\>= 4.0.0) installed on your system.

### Install from GitHub

``` r
# Install from GitHub using devtools
if (!require(devtools)) install.packages("devtools")
devtools::install_github("TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes")

# Or using pak (recommended)
if (!require(pak)) install.packages("pak")
pak::pak("TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes")
```

### Install Dependencies

The package will automatically install required dependencies:

``` r
# Core dependencies
install.packages(c(
  "shiny", "bslib", "bsicons", "DT", "highcharter",
  "dplyr", "lubridate", "R6", "htmlwidgets"
))
```

## Quick Start

### Launch the Application

``` r
# Load the package
library(susneo)

# Run the Shiny application
run_app()
```

### Using Sample Data

The application includes sample energy consumption data for
demonstration:

``` r
# Access sample data
data("sample_data", package = "susneo")
head(sample_data)
```

### Data Format

Your CSV files should include these columns:

- `id`: Unique identifier
- `site`: Facility/location name
- `date`: Date in DD-MM-YYYY format
- `type`: Energy type (Electricity, Gas, Water, etc.)
- `value`: Energy consumption value
- `carbon_emission_in_kgco2e`: Carbon emissions (optional)

## Features

### Dashboard Components

- **KPI Cards**: Display key metrics including total consumption,
  emissions, daily averages, efficiency ratios, peak usage, and facility
  counts
- **Time Series Chart**: Interactive line chart showing energy
  consumption trends over time
- **Facility Comparison**: Column chart comparing total energy usage
  across different facilities
- **Data Table**: Detailed summary table with filtering and sorting
  capabilities

### Data Management

- **CSV Upload**: Import your own energy consumption data
- **Sample Data**: Built-in demonstration dataset
- **Data Validation**: Automatic validation of required columns and data
  types
- **Date Processing**: Flexible date parsing supporting multiple formats

### Filtering & Interactivity

- **Date Range Selection**: Filter data by custom date periods
- **Facility Selection**: Multi-select filtering by facility/site
- **Energy Type Selection**: Filter by specific energy types
- **Real-time Updates**: All charts and metrics update dynamically

## Usage Examples

### Basic Usage

``` r
# Start the application
susneo::run_app()

# The app will open in your default browser
# Use "Load Sample Data" to see the demo
```

### Working with Custom Data

``` r
# Prepare your data with required columns
my_data <- data.frame(
  id = 1:100,
  site = rep(c("Building_A", "Building_B"), 50),
  date = seq(as.Date("2024-01-01"), by = "day", length.out = 100),
  type = rep(c("Electricity", "Gas"), 50),
  value = rnorm(100, 1000, 200),
  carbon_emission_in_kgco2e = rnorm(100, 50, 10)
)

# Save as CSV and upload through the app interface
write.csv(my_data, "my_energy_data.csv", row.names = FALSE)
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
    │   ├── fct_*.R                # Business logic functions
    │   ├── utils_*.R              # Utility functions
    │   └── class_data_manager.R   # Data management class
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

**Version**: 0.0.0.9000 **Compiled**: 2025-09-17 20:41:24.908783

## Development Status

    #> **Package**: Development version loaded ✅
    #> ✔ | F W  S  OK | Context
    #> ⠏ |          0 | app_config                                                                                           ✔ |          5 | app_config
    #> ⠏ |          0 | app_server                                                                                           ⠙ |          2 | app_server                                                                                           ✔ |          3 | app_server
    #> ⠏ |          0 | app_ui                                                                                               ⠋ |          1 | app_ui                                                                                               ✔ |          5 | app_ui
    #> ⠏ |          0 | data-manager                                                                                         ⠧ |          8 | data-manager                                                                                         ⠹ |         13 | data-manager                                                                                         ✔ |         15 | data-manager
    #> ⠏ |          0 | fct_value_boxes                                                                                      ⠇ |          9 | fct_value_boxes                                                                                      ⠼ |         15 | fct_value_boxes                                                                                      ✔ |         21 | fct_value_boxes
    #> ⠏ |          0 | formatting-functions                                                                                 ⠇ |          9 | formatting-functions                                                                                 ⠴ |         16 | formatting-functions                                                                                 ⠼ |         25 | formatting-functions                                                                                 ⠼ |         35 | formatting-functions                                                                                 ✔ |         44 | formatting-functions
    #> ⠏ |          0 | kpi-calculations                                                                                     ⠴ |          6 | kpi-calculations                                                                                     ⠙ |         12 | kpi-calculations                                                                                     ⠇ |         19 | kpi-calculations                                                                                     ✔ |         22 | kpi-calculations
    #> ⠏ |          0 | mod_data_upload                                                                                      ⠸ |          4 | mod_data_upload                                                                                      ⠋ |         11 | mod_data_upload                                                                                      ✔ |         17 | mod_data_upload
    #> ⠏ |          0 | mod_kpi_cards                                                                                        ⠧ |          8 | mod_kpi_cards                                                                                        ⠸ |         14 | mod_kpi_cards                                                                                        ⠋ |         21 | mod_kpi_cards                                                                                        ✔ |         30 | mod_kpi_cards
    #> ⠏ |          0 | run_app                                                                                              ✔ |          4 | run_app
    #> 
    #> ══ Results ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
    #> Duration: 2.9 s
    #> 
    #> [ FAIL 0 | WARN 0 | SKIP 0 | PASS 166 ]
    #> 
    #> You rock!
    #> **Tests**: All tests passing ✅
    #> **Coverage**: See CI badges for coverage status
    #> **CI Status**: See badges above for current build status
    #> **Issues**: Check [GitHub Issues](https://github.com/TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes/issues)

### Package Coverage

``` r
covr::package_coverage()
#> susneo Coverage: 44.41%
#> R/fct_charts.R: 0.00%
#> R/utils_charts.R: 0.00%
#> R/fct_value_boxes.R: 23.08%
#> R/mod_kpi_cards.R: 48.44%
#> R/mod_data_upload.R: 52.00%
#> R/mod_dashboard.R: 53.79%
#> R/class_data_manager.R: 55.00%
#> R/app_config.R: 100.00%
#> R/app_server.R: 100.00%
#> R/app_ui.R: 100.00%
#> R/run_app.R: 100.00%
#> R/utils_formatting.R: 100.00%
```

### Recent Updates

- ✅ Comprehensive test suite with 170+ tests
- ✅ CI/CD pipeline with multi-platform testing
- ✅ Code coverage tracking
- ✅ Automated linting and code quality checks
- ✅ Documentation with pkgdown
- ✅ Sample data and example usage

### Known Issues

- ⚠️ Namespace conflicts between shiny and DT packages (minor warnings)
- 📝 Check [Issues
  page](https://github.com/TiagoAdriaNunes/susneo-shiny-tiago-adria-nunes/issues)
  for current status

### Roadmap

- [ ] Enhanced data visualization options
- [ ] Export functionality for charts and reports
- [ ] Advanced filtering and aggregation features
- [ ] Performance optimizations for large datasets
