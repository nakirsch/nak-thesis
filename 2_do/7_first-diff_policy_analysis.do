///First difference to examine impact of policy change on corporations' intensity of production
///Created: February 3, 2023
///Modified: April 1, 2023


foreach file in "fd_all_unw" "fd_nomiss_unw" "fd_all_w" "fd_nomiss_w" {

	use "$prepped_data/`file'.dta", clear

	//Run regression
	eststo: reg evintensity_dif policy_dif gov_dif ln_gdp_percap_dif ln_pop_dif, r
}

esttab using "$output/fd.tex", label replace se r2 tex 
eststo clear

///For Appendix 
*V1
foreach file in "fd_all_unw_v1" "fd_nomiss_unw_v1" "fd_all_w_v1" "fd_nomiss_w_v1" {

	use "$prepped_data/`file'", clear

	//Run regression
	eststo: reg evintensity_dif policy_dif gov_dif ln_gdp_percap_dif ln_pop_dif, r
}

esttab using "$output/fd_v1.tex", label replace se r2 tex 
eststo clear

*V2
foreach file in "fd_all_unw_v2" "fd_nomiss_unw_v2" "fd_all_w_v2" "fd_nomiss_w_v2" {

	use "$prepped_data/`file'", clear

	//Run regression
	eststo: reg evintensity_dif policy_dif gov_dif ln_gdp_percap_dif ln_pop_dif, r
}

esttab using "$output/fd_v2.tex", label replace se r2 tex 
eststo clear


*Calculations
foreach file in "fd_all_unw" "fd_nomiss_unw" "fd_all_w" "fd_nomiss_w" {

	use "$prepped_data/`file'.dta", clear
	sum evintensity_dif policy_dif gov_dif ln_gdp_percap_dif ln_pop_dif
	reg evintensity_dif policy_dif gov_dif ln_gdp_percap_dif ln_pop_dif, r
}

