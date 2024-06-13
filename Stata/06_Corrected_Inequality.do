// -------------------------------------------------------------------------- //
// Do file: 06_Corrected_Inequality
// Description: Computes corrected measures of wage and gender inequality
//
// Author: José M. Cueto
// Date: May 5, 2024
// -------------------------------------------------------------------------- //

clear all
set more off
capture log close

cd "C:\Users\cueto\Dropbox (Personal)\TFG\Replication"

**# Data

use "Data\Quantiles.dta", clear

**# Corrected wage gap

* Corrected quantiles

foreach q of numlist 1/9 {
	
    preserve

	keep if quantile == `q'

	twoway (line corrected_q_females year, lcolor("235 65 50")) ///
		   (line uncorrected_q_females year, lcolor("235 65 50") lpattern(dash)) ///
		   (line corrected_q_males year, lcolor("65 135 245")) ///
		   (line uncorrected_q_males year, lcolor("65 135 245") lpattern(dash)), ///
		   graphregion(color(white)) xtitle("Year") ytitle("Hourly wage") ///
		   xlabel(2017(1)2023) legend(off)
		   
		   *legend(size(small) cols(2) order(1 3 2 4) ///
		   *lab(1 "Corrected women") lab(2 "Observed women") ///
		   *lab(3 "Corrected men") lab(4 "Observed men"))

	graph export "Figures\Quantile_`q'th.png", replace

	restore
	
}

* Uncorrected and corrected wage gap

preserve

keep if quantile == 3 | quantile == 5 | quantile == 7

table year quantile, stat(mean u_wage_gap c_wage_gap)

restore

** Corrected level of wage inequality

preserve

* Uncorrected and corrected quantiles

keep if quantile == 1 | quantile == 9

local varlist "u_q_males c_q_females u_q_females c_q_males"

foreach var of local varlist {
	
    forvalues i = 1/9 {
		
        gen `var'_`i' = `var'[_n + `i']
		
    }
	
}

* Inequality measures

gen uncorrected_m = u_q_males_9 / u_q_males_1
gen uncorrected_f = u_q_females_9 / u_q_females_1

gen corrected_m = c_q_males_9 / c_q_males_1
gen corrected_f = c_q_females_9 / c_q_females_1

drop if quantile == 9

* Table

log using "Log\Corrected_Wage_Inequality.log", replace

table year, stat(mean uncorrected_f corrected_f uncorrected_m corrected_m)

log close

restore
