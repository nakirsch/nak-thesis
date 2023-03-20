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
reg pledge_strong eff_estimate ln_ghg ln_gdp ln_pop, cluster(region)
outreg2 using "$output/LPM.xls", replace lab dec(3) cttop(`file')

reg pledge_strong eff_estimate ghg_percap gdp_percap ln_pop, cluster(region)
outreg2 using "$output/LPM.xls", replace lab dec(3) cttop(`file')

reg pledge_strong eff_estimate ghg_percap ln_gdp ln_pop, cluster(region)
outreg2 using "$output/LPM.xls", replace lab dec(3) cttop(`file')

reg pledge_strong eff_estimate ln_ghg gdp_percap ln_pop, cluster(region)
outreg2 using "$output/LPM.xls", replace lab dec(3) cttop(`file')

reg pledge_strong eff_estimate ghg_percap ln_gdp_percap ln_pop, cluster(region)
outreg2 using "$output/LPM.xls", replace lab dec(3) cttop(`file')

//Run with CCPI as input
reg pledge_strong ccpi_overall, cluster(region)
outreg2 using "$output/LPM.xls", lab dec(3) cttop(`file')

