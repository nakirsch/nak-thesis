///LPM to examine pledge determinants
///Created: February 3, 2023
///Modified: March 19, 2023

/*
pledge = B0 + B1governance + B2GHG + B3GDP + B4pop 
		 + error

pledge = B0 + B1CCPI
		 + error
*/

*Run at the country level only
use "$prepped_data/lpm_sub4_agg_all.dta", clear 

//Run with controls as input
eststo: reg pledge_strong eff_estimate ln_ghg ln_gdp ln_pop, cluster(region)
eststo: reg pledge_strong eff_estimate ghg_percap gdp_percap ln_pop, cluster(region)
eststo: reg pledge_strong eff_estimate ghg_percap ln_gdp ln_pop, cluster(region)
eststo: reg pledge_strong eff_estimate ln_ghg gdp_percap ln_pop, cluster(region)
eststo: reg pledge_strong eff_estimate ghg_percap ln_gdp_percap ln_pop, cluster(region)

//Run with CCPI as input
eststo: reg pledge_strong ccpi_overall, cluster(region)
esttab using "$output/lpm.tex", label replace se r2 tex 
eststo clear 
