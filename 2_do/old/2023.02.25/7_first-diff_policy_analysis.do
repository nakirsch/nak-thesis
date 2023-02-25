///First difference to examine impact of policy change on corporate emissions
///Created: February 3, 2023
///Modified: February 3, 2023

/*
Δemissions = B0 + B1Δpolicy + B2Δgovernance + B3ΔGDP + B4Δpop 
		 + error
*/

/*
codebook ccpi_policy_overall
chartab ccpi_policy_overall
*/

foreach file in "sub1_unagg_all.dta" "sub2_unagg_neg_dropobs.dta" "sub3_unagg_neg_dropfirms.dta" /// 
	"sub4_agg_all.dta" "sub5_agg_neg_dropobs.dta" "sub6_agg_neg_dropfirms.dta" {

	use "$prepped_data/`file'", clear
	
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
	
	if ("`file'" == "sub1_unagg_all.dta") | ("`file'" == "sub2_unagg_neg_dropobs.dta")| ("`file'" == "sub3_unagg_neg_dropfirms.dta") {
		keep country company year environmental_intensity_sales policy_level eff_estimate ln_gdp ln_pop
		ren environmental_intensity_sales evintensity
		reshape wide evintensity policy_level eff_estimate ln_gdp ln_pop, i(country company) j(year)
	}
	else {
		keep country year environmental_intensity_sales policy_level eff_estimate ln_gdp ln_pop
		ren environmental_intensity_sales evintensity
		reshape wide evintensity policy_level eff_estimate ln_gdp ln_pop, i(country) j(year)
	}
	
	//Generate change variables
	gen evintensity_dif = evintensity2019 - evintensity2018
	gen policy_dif = policy_level2019 - policy_level2018
	gen gov_dif = eff_estimate2019 - eff_estimate2018
	gen ln_gdp_dif = ln_gdp2019 - ln_gdp2018
	gen ln_pop_dif = ln_pop2019 - ln_pop2018

	//Run regression
	reg evintensity_dif policy_dif gov_dif ln_gdp_dif ln_pop_dif, r
	
	if "`file'" == "sub1_unagg_all.dta" {
		outreg2 using "$output/FirstDiff.xls", replace dec(3) cttop(`file')
	}
	else {
		outreg2 using "$output/FirstDiff.xls", dec(3) cttop(`file')
	}
}
