// -------------------------------------------------------------------------- //
// Do file: 01_Data_Preparation
// Description: Creates the sample using the ECVs from 2017 to 2023
//
// Author: José M. Cueto
// Date: April 10, 2024
// -------------------------------------------------------------------------- //

clear all
set more off
capture log close

cd "C:\Users\cueto\Dropbox (Personal)\TFG\Replication\Data"

**# 2017 - 2020

foreach year of numlist 2017/2020 {
	
	**# File D: Datos básicos del hogar
	 
    	use "Raw\ECV_Td_`year'.dta", clear
	
	* Variables of interest
	
	rename DB030 id_hh
	rename DB040 region
	
	keep id_hh region
	
	* Removing missing values
	
	foreach var of varlist _all {
		drop if mi(`var')
	}
	
	* Regions
	
	drop if region == "ESZZ"
	
	gen gal  = (region == "ES11")
	gen ast  = (region == "ES12")
	gen cant = (region == "ES13")
	gen pv   = (region == "ES21")
	gen nav  = (region == "ES22")
	gen rio  = (region == "ES23")
	gen ara  = (region == "ES24")
	gen mad  = (region == "ES30")
	gen cyl  = (region == "ES41")
	gen clm  = (region == "ES42")
	gen ext  = (region == "ES43")
	gen cat  = (region == "ES51")
	gen val  = (region == "ES52")
	gen bal  = (region == "ES53")
	gen and  = (region == "ES61")
	gen mur  = (region == "ES62")
	gen ceu  = (region == "ES63")
	gen mel  = (region == "ES64")
	gen can  = (region == "ES70")
	
	* Removing useless information
	
	drop region
	
	* Save
	
	save "Temporary\d_`year'.dta", replace

	**# File H: Datos detallados del hogar
	
	use "Raw\ECV_Th_`year'.dta", clear
	
	* Variables of interest
	
	rename HB030 id_hh
	rename HY020 hh_income
	
	keep id_hh hh_income
	
	* Removing missing values
	
	foreach var of varlist _all {
		drop if mi(`var')
	}
	
	* Save
	
	save "Temporary\h_`year'.dta", replace
	
	**# File P: Datos detallados de los adultos
	
	use "Raw\ECV_Tp_`year'.dta", clear
	
	* Variables of interest
	
	rename PB030  id
	rename PB140  birth_year
	rename PB150  sex
	rename PB200  marital_status
	rename PE040  educ
	rename PL031  employment_situation
	rename PL040  worker_type
	rename PL060  hours
	rename PL073  months_full_time
	rename PL074  months_part_time
	rename PL200  exper
	rename PH010  health
	rename PY010N wage
	
	keep id birth_year sex marital_status educ employment_situation ///
	     worker_type hours months_full_time months_part_time exper health wage
	
	* Restricting the sample to people aged 23 to 59
	
	gen age = `year' - birth_year
	
	drop if age < 23 | age > 64
	
	* Restricting the sample to potentially active people
	
	destring employment_situation, replace
	
	keep if employment_situation == 1 | employment_situation == 2 | ///
	        employment_situation == 5 | employment_situation == 10 | ///
			employment_situation == 11
	
	* Removing business owners and self-employed people
	
	destring worker_type, replace
	
	keep if worker_type != 1 & worker_type != 2 & worker_type != 4
	
	* Removing missing values
	
	foreach var of varlist _all {
		if "`var'" != "worker_type" & "`var'" != "hours" & "`var'" != "exper" {
			drop if mi(`var')
		}
	}
	
	* Household id
	
	gen id_hh = floor(id / 100)
	
	* Sex
	
	destring sex, replace
	
	gen male = (sex == 1)
	
	* Married
	
	destring marital_status, replace
	
	gen married = (marital_status == 1 | marital_status == 2)
	
	* Health
	
	destring health, replace
	
	gen good_health = (health == 1 | health == 2)
	
	* Education
	
	destring educ, replace
	
	gen basic        = (educ == 0 | educ == 100)
	gen intermediate = (educ == 200 | educ == 300 | educ == 344 | ///
	                    educ == 353 | educ == 354 | educ == 400 | educ == 450)
	gen advanced     = (educ == 500)
	
	* Experience
	
	destring exper, replace
	
	replace exper = 0 if mi(exper)
	
	gen exper2 = exper * exper
	
	* Months worked
	
	gen months = max(months_full_time, months_part_time) if !mi(hours) & ///
	    !(months_full_time + months_part_time == 0)
	
	* Hourly wage
	
	gen hwage = wage / (hours * 4.345 * months)
	
	replace hwage = . if hwage == 0
	
	* Work indicator
	
	gen work = (!mi(hwage))
	
	* Removing useless information
	
	drop birth_year sex marital_status educ employment_situation worker_type ///
	     hours months_full_time months_part_time health months
	
	* Save
	
	save "Temporary\p_`year'.dta", replace
	
	**# File R: Datos básicos de la persona
	
	use "Raw\ECV_Tr_`year'.dta", clear
	
	* Variables of interest
	
	rename RB030 id
	rename RB220 id_father
	rename RB230 id_mother
	
	keep id id_father id_mother
	
	* Children

	egen temp = count(id_father), by(id_father)
	
	gen aux = .
	
	quietly forvalues i = 1 / `=_N' {
		replace aux = temp[`i'] if id == id_father[`i']
	}
	
	egen temp2 = count(id_mother), by(id_mother)
	
	gen aux2 = .
	
	quietly forvalues i = 1 / `=_N' {
		replace aux2 = temp2[`i'] if id == id_mother[`i']
	}

	drop temp temp2
	
	replace aux = 0 if missing(aux)
	replace aux2 = 0 if missing(aux2)
	
	gen children = aux + aux2
	
	drop id_father id_mother aux aux2
	
	* Removing missing values
	
	foreach var of varlist _all {
		drop if mi(`var')
	}
	
	* Save
	
	save "Temporary\r_`year'.dta", replace
	
	**# Merging data sets
	
	* Households
	
	use "Temporary\d_`year'.dta", clear

	merge 1:1 id_hh using "Temporary\h_`year'.dta"

	drop _merge

	save "Temporary\Households_`year'.dta", replace
	
	* Individuals
	
	use "Temporary\p_`year'.dta", clear
	
	merge 1:1 id using "Temporary\r_`year'.dta"
	
	keep if _merge == 3
	
	drop _merge
	
	save "Temporary\Individuals_`year'.dta", replace
	
	* Final data set
	
	use "Temporary\Individuals_`year'.dta", clear
	
	merge m:1 id_hh using "Temporary\Households_`year'.dta"
	
	keep if _merge == 3
	
	drop _merge
	
	* Household income
	
	gen nincome = (hh_income - wage) / 1000
	
	drop hh_income wage
	
	* Year
	
	gen year = `year'
	
	* Save
	
	save "Data_`year'.dta", replace
}

**# 2021 - 2023

foreach year of numlist 2021/2023 {
	
	**# File D: Datos básicos del hogar
	
    	use "Raw\ECV_Td_`year'.dta", clear
	
	* Variables of interest
	
	rename DB030 id_hh
	rename DB040 region
	
	keep id_hh region
	
	* Removing missing values
	
	foreach var of varlist _all {
		drop if mi(`var')
	}
	
	* Regions
	
	drop if region == "ESZZ"
	
	gen gal  = (region == "ES11")
	gen ast  = (region == "ES12")
	gen cant = (region == "ES13")
	gen pv   = (region == "ES21")
	gen nav  = (region == "ES22")
	gen rio  = (region == "ES23")
	gen ara  = (region == "ES24")
	gen mad  = (region == "ES30")
	gen cyl  = (region == "ES41")
	gen clm  = (region == "ES42")
	gen ext  = (region == "ES43")
	gen cat  = (region == "ES51")
	gen val  = (region == "ES52")
	gen bal  = (region == "ES53")
	gen and  = (region == "ES61")
	gen mur  = (region == "ES62")
	gen ceu  = (region == "ES63")
	gen mel  = (region == "ES64")
	gen can  = (region == "ES70")
	
	* Removing useless information
	
	drop region
	
	* Save
	
	save "Temporary\d_`year'.dta", replace
	
	**# File H: Datos detallados del hogar
	
	use "Raw\ECV_Th_`year'.dta", clear
	
	* Variables of interest
	
	rename HB030 id_hh
	rename HY020 hh_income
	
	keep id_hh hh_income
	
	* Removing missing values
	
	foreach var of varlist _all {
		drop if mi(`var')
	}
	
	* Save
	
	save "Temporary\h_`year'.dta", replace
	
	**# File P: Datos detallados de los adultos
	
	use "Raw\ECV_Tp_`year'.dta", clear
	
	* Variables of interest
	
	rename PB030  id
	rename PB140  birth_year
	rename PB150  sex
	rename PB200  marital_status
	rename PE041  educ
	rename PL032  employment_situation
	rename PL040A worker_type
	rename PL060  hours
	rename PL073  months_full_time
	rename PL074  months_part_time
	rename PL200  exper
	rename PH010  health
	rename PY010N wage
	
	keep id birth_year sex marital_status educ employment_situation ///
	     worker_type hours months_full_time months_part_time exper health wage
	
	* Restricting the sample to people aged 23 to 59
	
	gen age = `year' - birth_year
	
	drop if age < 23 | age > 64
	
	* Restricting the sample to potentially active people
	
	destring employment_situation, replace
	
	keep if employment_situation == 1 | employment_situation == 2 | ///
	        employment_situation == 6 | employment_situation == 8
	
	* Removing business owners and self-employed people
	
	destring worker_type, replace
	
	keep if worker_type != 1 & worker_type != 2 & worker_type != 4
	
	* Removing missing values
	
	foreach var of varlist _all {
		if "`var'" != "worker_type" & "`var'" != "hours" & "`var'" != "exper" {
			drop if mi(`var')
		}
	}
	
	* Household id
	
	gen id_hh = floor(id / 100)
	
	* Sex
	
	destring sex, replace
	
	gen male = (sex == 1)
	
	* Married
	
	destring marital_status, replace
	
	gen married = (marital_status == 1 | marital_status == 2)
	
	* Health
	
	destring health, replace
	
	gen good_health = (health == 1 | health == 2)
	
	* Education
	
	destring educ, replace
	
	gen basic        = (educ == 0 | educ == 100)
	gen intermediate = (educ == 200 | educ == 340 | educ == 344 | ///
	                    educ == 350 | educ == 353 | educ == 354 | educ == 450)
	gen advanced     = (educ == 500)
	
	* Experience
	
	destring exper, replace
	
	replace exper = 0 if mi(exper)
	
	gen exper2 = exper * exper
	
	* Months worked
	
	gen months = max(months_full_time, months_part_time) if !mi(hours) & ///
	    !(months_full_time + months_part_time == 0)
	
	* Hourly wage
	
	gen hwage = wage / (hours * 4.345 * months)
	
	replace hwage = . if hwage == 0
	
	* Work indicator
	
	gen work = (!mi(hwage))
	
	* Removing useless information
	
	drop birth_year sex marital_status educ employment_situation worker_type ///
	     hours months_full_time months_part_time health months
	
	* Save
	
	save "Temporary\p_`year'.dta", replace
	
	**# File R: Datos básicos de la persona
	
	use "Raw\ECV_Tr_`year'.dta", clear
	
	* Variables of interest
	
	rename RB030 id
	rename RB220 id_father
	rename RB230 id_mother
	
	keep id id_father id_mother
	
	* Children

	egen temp = count(id_father), by(id_father)
	
	gen aux = .
	
	quietly forvalues i = 1 / `=_N' {
		replace aux = temp[`i'] if id == id_father[`i']
	}
	
	egen temp2 = count(id_mother), by(id_mother)
	
	gen aux2 = .
	
	quietly forvalues i = 1 / `=_N' {
		replace aux2 = temp2[`i'] if id == id_mother[`i']
	}

	drop temp temp2
	
	replace aux = 0 if missing(aux)
	replace aux2 = 0 if missing(aux2)
	
	gen children = aux + aux2
	
	drop id_father id_mother aux aux2
	
	* Removing missing values
	
	foreach var of varlist _all {
		drop if mi(`var')
	}
	
	* Save
	
	save "Temporary\r_`year'.dta", replace
	
	**# Merging data sets
	
	* Households
	
	use "Temporary\d_`year'.dta", clear

	merge 1:1 id_hh using "Temporary\h_`year'.dta"

	drop _merge
	
	save "Temporary\Households_`year'.dta", replace
	
	* Individuals
	
	use "Temporary\p_`year'.dta", clear
	
	merge 1:1 id using "Temporary\r_`year'.dta"
	
	keep if _merge == 3
	
	drop _merge
	
	save "Temporary\Individuals_`year'.dta", replace
	
	* Final data set
	
	use "Temporary\Individuals_`year'.dta", clear
	
	merge m:1 id_hh using "Temporary\Households_`year'.dta"
	
	keep if _merge == 3
	
	drop _merge
	
	* Household income
	
	gen nincome = (hh_income - wage) / 1000
	
	drop hh_income wage
	
	* Year
	
	gen year = `year'
	
	* Save
	
	save "Data_`year'.dta", replace
}

**# Panel

use "Data_2017.dta", clear

save "Panel.dta", replace

foreach year of numlist 2018/2023 {
	
	use "Data_`year'.dta", clear
	
    	append using "Panel.dta"
	
    	save "Panel.dta", replace
	
	sleep 1000
}

use "Panel.dta", clear

sort year

* Deflating hwage and nincome

merge m:1 year using "Raw\CPI.dta"

drop _merge

replace hwage   = hwage / cpi
replace nincome = nincome / cpi

drop cpi

* Save

save "Panel.dta", replace
