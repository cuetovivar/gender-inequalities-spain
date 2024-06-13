// -------------------------------------------------------------------------- //
// Do file: 04_QSR
// Description: Estimates the quantile selection model proposed by Arellano and
//              Bonhomme (2017) and computes of the corrected quantiles using
//              the method of Machado and Mata (2005)
//
// Note: The code used to estimate the quantile selection model is based on
//       Muñoz and Siravegna (2021)
//
// Author: José M. Cueto
// Date: April 25, 2024
// -------------------------------------------------------------------------- //

clear all
set more off
capture log close

cd "C:\Users\cueto\Dropbox (Personal)\TFG\Replication"

**# Data

use "Data\Panel.dta", clear

**# Participation and wage equations

global wage_eqn hwage intermediate advanced age exper exper2 children good_health gal ast cant pv nav rio ara mad cyl clm ext cat val bal and mur ceu mel
global seleqn intermediate advanced age exper exper2 children good_health gal ast cant pv nav rio ara mad cyl clm ext cat val bal and mur ceu mel nincome

**# Females

foreach year of numlist 2017/2023 {
	
	**# Quantile selection model
	
	log using "Log\QSR_Females_`year'.log", replace
	
	qregsel $wage_eqn if year == `year' & male == 0, select($seleqn) quantile(.5)
	
	ereturn list
	
	log close
	
	**# Corrected quantiles
	
	preserve
	
	set seed 5
	
	* Corrected quantiles using Machado and Mata (2005)

	predict hwage_hat participation

	_pctile hwage_hat, nq(10)

	matrix qs = J(9, 3, .)

	forvalues i = 1/9 {
		mat qs[`i', 1] = r(r`i')
	}
	
	* Uncorrected quantiles and quantiles' order

	_pctile hwage if year == `year' & male == 0, nq(10)

	forvalues i = 1/9 {
		mat qs[`i', 2] = r(r`i')
		mat qs[`i', 3] = `i'
	}

	svmat qs, name(quantiles)

	keep quantiles1 quantiles2 quantiles3

	drop if mi(quantiles1, quantiles2, quantiles3)
	
	* Year
	
	gen year = `year'
	
	* Save
	
	save "Data\Temporary\Quantiles_Females_`year'.dta", replace
	
	restore

}

**# Males

foreach year of numlist 2017/2023 {
	
	* Quantile selection model
	
	log using "Log\QSR_Males_`year'.log", replace
	
	qregsel $wage_eqn if year == `year' & male == 1, select($seleqn) quantile(.5)
	
	ereturn list
	
	log close
	
	* Corrected quantiles
	
	preserve
	
	set seed 5
	
	* Corrected quantiles using Machado and Mata (2005)

	predict hwage_hat participation

	_pctile hwage_hat, nq(10)

	matrix qs = J(9, 3, .)

	forvalues i = 1/9 {
		mat qs[`i', 1] = r(r`i')
	}
	
	* Uncorrected quantiles and quantiles' order

	_pctile hwage if year == `year' & male == 1, nq(10)

	forvalues i = 1/9 {
		mat qs[`i', 2] = r(r`i')
		mat qs[`i', 3] = `i'
	}

	svmat qs, name(quantiles)

	keep quantiles1 quantiles2 quantiles3

	drop if mi(quantiles1, quantiles2, quantiles3)
	
	* Year
	
	gen year = `year'
	
	* Save
	
	save "Data\Temporary\Quantiles_Males_`year'.dta", replace
	
	restore

}

**# Corrected and uncorrected quantiles

use "Data\Temporary\Quantiles_Females_2017.dta", clear

save "Data\Quantiles.dta", replace

* Data for females

foreach year of numlist 2018/2023 {
	
    	use "Data\Temporary\Quantiles_Females_`year'.dta", clear
	
    	append using "Data\Quantiles.dta"
	
    	save "Data\Quantiles.dta", replace
	
	sleep 1000
}

rename quantiles1 corrected_q_females
rename quantiles2 uncorrected_q_females
rename quantiles3 quantile

save "Data\Quantiles.dta", replace

* Data for males

use "Data\Temporary\Quantiles_Males_2017.dta", clear

save "Data\Temporary\Quantiles_Males.dta", replace

foreach year of numlist 2018/2023 {
	
    	use "Data\Temporary\Quantiles_Males_`year'.dta", clear
	
    	append using "Data\Temporary\Quantiles_Males.dta"
	
    	save "Data\Temporary\Quantiles_Males.dta", replace
	
	sleep 1000
}

rename quantiles1 corrected_q_males
rename quantiles2 uncorrected_q_males
rename quantiles3 quantile

save "Data\Temporary\Quantiles_Males.dta", replace

* Merge

merge 1:1 quantile year using "Data\Quantiles.dta"

drop _merge

sort year quantile

* Corrected and uncorrected wage gaps
gen c_wage_gap = (corrected_q_males / corrected_q_females - 1)*100
gen u_wage_gap = (uncorrected_q_males / uncorrected_q_females - 1)*100

save "Data\Quantiles.dta", replace
