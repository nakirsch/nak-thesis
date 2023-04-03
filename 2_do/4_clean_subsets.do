///Clean subsets of the data for analyses
///Created: February 25, 2023
///Modified: April 1, 2023

//Subsets for DD

foreach file in "all_w" "all_unw" "nomiss_w" "nomiss_unw" "all_w_v1" "all_w_v2" ///
	"all_unw_v1" "all_unw_v2" "nomiss_w_v1" "nomiss_w_v2" "nomiss_unw_v1" "nomiss_unw_v2" {
		
	use "$prepped_data/`file'.dta", clear
	gen post = 0 
	replace post = 1 if year > 2016
	gen postxstrong = post * pledge_strong
	
	gen gdp_percap = gdp/pop
	gen ln_gdp_percap = ln(gdp_percap)
	
	label var pledge_strong "Strong pledge"
	label var post "Post 2016"
	label var postxstrong "Post 2016 x strong pledge"
	label var environmental_intensity_sales "Environmental intensity"
	label var gdp_percap "GDP per capita (USD)"
	label var ln_gdp_percap "Natural log of GDP per capita (USD)"

	save "$prepped_data/dd_`file'.dta", replace
}

//Subsets for LPM

foreach file in "all_w" "nomiss_w" "all_w_v1" "all_w_v2" "nomiss_w_v1" "nomiss_w_v2" {
	
	use "$prepped_data/`file'.dta", clear 

	*Subset the data to year of the Paris Agreement
	keep if year == 2015

	gen ghg_percap = ghg/pop
	gen gdp_percap = gdp/pop

	gen ln_ghg_percap = ln(ghg_percap)
	gen ln_gdp_percap = ln(gdp_percap)

	label var pledge_strong "Strong pledge"
	label var ghg_percap "GHG emissions per capita (kt of CO2 equivalent)"
	label var gdp_percap "GDP per capita (USD)"
	label var ln_ghg_percap "Natural log of GHG emissions per capita (kt of CO2 equivalent)"
	label var ln_gdp_percap "Natural log of GDP per capita (USD)"

	save "$prepped_data/lpm_`file'.dta", replace
}

//Subsets for FD

foreach file in "all_w" "all_unw" "nomiss_w" "nomiss_unw" "all_w_v1" "all_w_v2" ///
	"all_unw_v1" "all_unw_v2" "nomiss_w_v1" "nomiss_w_v2" "nomiss_unw_v1" "nomiss_unw_v2" {

	use "$prepped_data/`file'.dta", clear
	
	gen gdp_percap = gdp/pop
	gen ln_gdp_percap = ln(gdp_percap)
	label var gdp_percap "GDP per capita (USD)"
	label var ln_gdp_percap "Natural log of GDP per capita (USD)"
	
	//Subset data to 2018-19
	keep if year > 2017

	//Fix policy indicator
	replace ccpi_policy_overall = subinstr(ccpi_policy_overall, uchar(160), "", .)

	//Generate policy level, reshape data
	gen policy_level = .
	replace policy_level = 1 if ccpi_policy_overall == "very low"
	replace policy_level = 2 if ccpi_policy_overall == "low"
	replace policy_level = 3 if ccpi_policy_overall == "medium"
	replace policy_level = 4 if ccpi_policy_overall == "high"
	
	if ("`file'" == "all_unw") | ("`file'" == "all_unw_v1") | ("`file'" == "all_unw_v2") | ///
		("`file'" == "nomiss_unw") | ("`file'" == "nomiss_unw_v1") | ("`file'" == "nomiss_unw_v2") {
		keep country company year environmental_intensity_sales policy_level eff_estimate ln_gdp_percap ln_pop
		ren environmental_intensity_sales evintensity
		reshape wide evintensity policy_level eff_estimate ln_gdp ln_pop, i(country company) j(year)
	}
	
	else {
		keep country year environmental_intensity_sales policy_level eff_estimate ln_gdp_percap ln_pop
		ren environmental_intensity_sales evintensity
		reshape wide evintensity policy_level eff_estimate ln_gdp ln_pop, i(country) j(year)
	}
	
	//Generate change variables
	gen evintensity_dif = evintensity2019 - evintensity2018
	gen policy_dif = policy_level2019 - policy_level2018
	gen gov_dif = eff_estimate2019 - eff_estimate2018
	gen ln_gdp_percap_dif = ln_gdp_percap2019 - ln_gdp_percap2018
	gen ln_pop_dif = ln_pop2019 - ln_pop2018
	
	label var evintensity_dif "Δ Intensity"
	label var policy_dif "Δ Environmental policy level"
	label var gov_dif "Δ Government effectivenss"
	label var ln_gdp_percap_dif "Δ Natural log of GDP per capita (USD)" 
	label var ln_pop_dif "Δ Natural log of population"

	save "$prepped_data/fd_`file'.dta", replace
}
