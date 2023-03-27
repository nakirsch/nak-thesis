///Clean balanced subsets of the data for analyses
///Created: March 19, 2023
///Modified: March 19, 2023

//Subsets for DD

foreach file in "bal_sub1_unagg_all.dta" "bal_sub2_unagg_neg_dropobs.dta" "bal_sub3_unagg_neg_dropfirms.dta" /// 
	"bal_sub4_agg_all.dta" "bal_sub5_agg_neg_dropobs.dta" "bal_sub6_agg_neg_dropfirms.dta" {
		
	use "$prepped_data/`file'", clear
	gen post = 0 
	replace post = 1 if year > 2016
	gen postxstrong = post * pledge_strong
	
	gen gdp_percap = gdp/pop
	gen ln_gdp_percap = ln(gdp_percap)
	
	label var pledge_strong "Strong pledge"
	label var post "Post 2016"
	label var postxstrong "Post 2016 X Strong pledge"
	label var environmental_intensity_sales "Environmental intensity"
	label var gdp_percap "GDP per capita (USD)"
	label var ln_gdp_percap "Natural log of GDP per capita (USD)"

	save "$prepped_data/dd_`file'", replace
}

//Subsets for LPM

use "$prepped_data/bal_sub4_agg_all.dta", clear 

*Subset the data to year of the Paris Agreement
keep if year == 2015

gen ghg_percap = ghg/pop
gen gdp_percap = gdp/pop

gen ln_ghg_percap = ln(ghg_percap)
gen ln_gdp_percap = ln(gdp_percap)

label var pledge_strong "Strong pledge"
label var ghg_percap "GHG emissions (kt of CO2 equivalent) per capita"
label var gdp_percap "GDP per capita (USD)"
label var ln_ghg_percap "Natural log of GHG emissions (kt of CO2 equivalent) per capita"
label var ln_gdp_percap "Natural log of GDP per capita (USD)"

save "$prepped_data/lpm_bal_sub4_agg_all.dta", replace

//Subsets for FD

foreach file in "bal_sub1_unagg_all.dta" "bal_sub2_unagg_neg_dropobs.dta" "bal_sub3_unagg_neg_dropfirms.dta" /// 
	"bal_sub4_agg_all.dta" "bal_sub5_agg_neg_dropobs.dta" "bal_sub6_agg_neg_dropfirms.dta" {
	
	use "$prepped_data/`file'", clear
	
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
	
	if ("`file'" == "bal_sub1_unagg_all.dta") | ("`file'" == "bal_sub2_unagg_neg_dropobs.dta")| ///
	   ("`file'" == "bal_sub3_unagg_neg_dropfirms.dta") {
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
	
	label var evintensity_dif "Difference in environmental intensity"
	label var policy_dif "Difference in environmental policy level"
	label var gov_dif "Difference in government effectivenss"
	label var ln_gdp_percap_dif "Difference in natural log of GDP per capita (USD)" 
	label var ln_pop_dif "Difference in natural log of population"
	
	save "$prepped_data/fd_`file'", replace
}
