// -------------------------------------------------------------------------- //
// Do file: 02_Descriptive_Analysis
// Description: Performs an exploratory analysis to describe the sample
//
// Author: José M. Cueto
// Date: June 3, 2024
// -------------------------------------------------------------------------- //

clear all
set more off
capture log close

cd "C:\Users\cueto\Dropbox (Personal)\TFG\Replication"

**# Data

use "Data\Panel.dta", clear

**# Descriptive statistics

log using "Log\Descriptive_Statistics.log", replace

by male work, sort: sum age exper basic intermediate advanced married good_health children hwage nincome

log close

**# Wage gap at different quantiles

preserve

* Quantiles

foreach gen in 0 1 {
	
    tempvar temp_hwage
	
    gen `temp_hwage' = hwage if male == `gen'
	
    foreach pct in 10 50 90 {
        bysort year: egen p`pct'_`gen' = pctile(`temp_hwage'), p(`pct')
    }
	
    drop `temp_hwage'
}

* Wage gap at different quantiles

foreach p in 10 50 90 {
	
	gen gap_`p' = (p`p'_1 / p`p'_0 - 1)*100
	
}

collapse (mean) gap_10 gap_50 gap_90, by(year)

* Table

log using "Log\Observed_Wage_Gap.log", replace

list, clean

log close

restore
