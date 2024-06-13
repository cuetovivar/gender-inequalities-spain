// -------------------------------------------------------------------------- //
// Do file: 03_Propensity_Score
// Description: Estimation of the propensity score using a Probit model
//
// Author: José M. Cueto
// Date: April 28, 2024
// -------------------------------------------------------------------------- //

clear all
set more off
capture log close

cd "C:\Users\cueto\Dropbox (Personal)\TFG\Replication"

**# Data

use "Data\Panel.dta", clear

gen p_hat = .

**# Participation equation

global seleqn work intermediate advanced age exper exper2 children good_health gal ast cant pv nav rio ara mad cyl clm ext cat val bal and mur ceu mel nincome

**# Females

log using "Log\Probit_Females.log", replace

foreach year of numlist 2017/2023 {
	
	* Probit model
	
	probit $seleqn if year == `year' & male == 0
	
	* Predicted probabilities
	
	predict p_hat_`year', pr
    
    	replace p_hat = p_hat_`year' if year == `year' & male == 0
    
    	drop p_hat_`year'
}

log close

**# Males

log using "Log\Probit_Males.log", replace

foreach year of numlist 2017/2023 {
	
	* Probit model
	
	probit $seleqn if year == `year' & male == 1
	
	* Predicted probabilities
	
	predict p_hat_`year', pr
    
    	replace p_hat = p_hat_`year' if year == `year' & male == 1
    
    	drop p_hat_`year'
}

log close

**# Average propensity to work by sex and year

log using "Log\Average_Propensity_Score.log", replace

table year male, stat(mean p_hat)

log close
