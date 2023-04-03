///LPM to examine pledge determinants
///Created: February 3, 2023
///Modified: April 1, 2023

*Run at the country level only

foreach file in "lpm_all_w" "lpm_nomiss_w" {
	
	use "$prepped_data/`file'.dta", clear 

	*Run with controls as input
	eststo: reg pledge_strong eff_estimate ln_gdp_percap ln_ghg_percap, cluster(region)

}

foreach file in "lpm_all_w" "lpm_nomiss_w" {
	
	use "$prepped_data/`file'.dta", clear 

	*Run with CCPI as input
	eststo: reg pledge_strong ccpi_overall, cluster(region)
	estadd local fe Yes

}

esttab using "$output/lpm.tex", label replace se r2 tex
eststo clear 
