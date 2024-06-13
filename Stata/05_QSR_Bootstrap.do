// -------------------------------------------------------------------------- //
// Do file: 05_QSR_Bootstrap
// Description: Performs the bootstrap to obtain the standard errors of the
//              copula parameter of the quantile selection model proposed by
//              Arellano and Bonhomme (2017).
//
// Note: The code used to perform the bootstrap is based on Muñoz and Siravegna
//       (2021)
//
// Author: José M. Cueto
// Date: May 15, 2024
// -------------------------------------------------------------------------- //

clear all
set more off
capture log close

cd "C:\Users\cueto\Dropbox (Personal)\TFG\Data_and_Programs"

**# Data

use "Data\Panel.dta", clear

**# Participation and wage equations

global wage_eqn hwage intermediate advanced age exper exper2 children good_health gal ast cant pv nav rio ara mad cyl clm ext cat val bal and mur ceu mel
global seleqn intermediate advanced age exper exper2 children good_health gal ast cant pv nav rio ara mad cyl clm ext cat val bal and mur ceu mel nincome

**# Females

log using "Log\QSR_Females_Bootstrap.log", replace

foreach year of numlist 2017/2023 {
	
	bootstrap rho = e(rho) _b, reps(100) seed(5): qregsel $wage_eqn if year == `year' & male == 0, select($seleqn) quantile(.5)
	
}

log close

**# Males

log using "Log\QSR_Males_Bootstrap.log", replace

foreach year of numlist 2017/2023 {
	
	bootstrap rho = e(rho) _b, reps(100) seed(5): qregsel $wage_eqn if year == `year' & male == 1, select($seleqn) quantile(.5)

}

log close
