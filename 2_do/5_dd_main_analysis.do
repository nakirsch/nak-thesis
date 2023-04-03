///Diff-in-diff to examine impact of pledges on firm-level intensity of production
///Created: February 3, 2023
///Modified: April 1, 2023

//Main tables

*Regression 1 - No controls, no fixed effects
foreach file in "dd_all_unw" "dd_nomiss_unw" "dd_all_w" "dd_nomiss_w" {

	use "$prepped_data/`file'.dta", clear	
	eststo: reg environmental_intensity_sales post pledge_strong postxstrong, cluster(region)
}
esttab using "$output/dd_1.tex", label replace se r2 tex 
eststo clear

*Regression 2 - Controls, no fixed effects 
foreach file in "dd_all_unw" "dd_nomiss_unw" "dd_all_w" "dd_nomiss_w" {

	use "$prepped_data/`file'.dta", clear	
	eststo: reg environmental_intensity_sales post pledge_strong postxstrong ///
		eff_estimate ln_gdp_percap ln_pop, cluster(region)
}
esttab using "$output/dd_2.tex", label replace se r2 tex 
eststo clear

*Regression 3 - No controls, fixed effects 
foreach file in "dd_all_unw" "dd_nomiss_unw" "dd_all_w" "dd_nomiss_w" {

	use "$prepped_data/`file'.dta", clear	
	
	if ("`file'" == "dd_all_unw") | ("`file'" == "dd_nomiss_unw") {
	
		tostring year, replace
		encode year, gen(yearcode)
		order yearcode, a(year)

		encode company, gen(companycode)
		order companycode, a(company)

		eststo: reghdfe environmental_intensity_sales postxstrong ///
			, a(companycode yearcode)
	}
	
	else {
		
		tostring year, replace
		encode year, gen(yearcode)
		order yearcode, a(year)

		encode country, gen(countrycode)
		order countrycode, a(country)

		eststo: reghdfe environmental_intensity_sales postxstrong ///
			, a(countrycode yearcode)
	}
}
esttab using "$output/dd_3.tex", label replace se r2 tex 
eststo clear

*Regression 4 - Controls, fixed effects 
foreach file in "dd_all_unw" "dd_nomiss_unw" "dd_all_w" "dd_nomiss_w" {

	use "$prepped_data/`file'.dta", clear	
	
	if ("`file'" == "dd_all_unw") | ("`file'" == "dd_nomiss_unw") {
	
		tostring year, replace
		encode year, gen(yearcode)
		order yearcode, a(year)

		encode company, gen(companycode)
		order companycode, a(company)

		eststo: reghdfe environmental_intensity_sales postxstrong ///
			eff_estimate ln_gdp_percap ln_pop, a(companycode yearcode)
	}
	
	else {
		
		tostring year, replace
		encode year, gen(yearcode)
		order yearcode, a(year)

		encode country, gen(countrycode)
		order countrycode, a(country)

		eststo: reghdfe environmental_intensity_sales postxstrong ///
			eff_estimate ln_gdp_percap ln_pop, a(countrycode yearcode)
	}
}
esttab using "$output/dd_4.tex", label replace se r2 tex 
eststo clear

//Appendix tables 

*V1 

*Regression 1 - No controls, no fixed effects
foreach file in "dd_all_unw_v1" "dd_nomiss_unw_v1" "dd_all_w_v1" "dd_nomiss_w_v1" {
	
	use "$prepped_data/`file'.dta", clear	
	eststo: reg environmental_intensity_sales post pledge_strong postxstrong, cluster(region)
}
esttab using "$output/dd_1_v1.tex", label replace se r2 tex 
eststo clear


*Regression 2 - Controls, no fixed effects 
foreach file in "dd_all_unw_v1" "dd_nomiss_unw_v1" "dd_all_w_v1" "dd_nomiss_w_v1" {
	
	use "$prepped_data/`file'.dta", clear	
	eststo: reg environmental_intensity_sales post pledge_strong postxstrong ///
		eff_estimate ln_gdp_percap ln_pop, cluster(region)
}
esttab using "$output/dd_2_v1.tex", label replace se r2 tex 
eststo clear

*Regression 3 - No controls, fixed effects 
foreach file in "dd_all_unw_v1" "dd_nomiss_unw_v1" "dd_all_w_v1" "dd_nomiss_w_v1" {

	use "$prepped_data/`file'.dta", clear	
	
	if ("`file'" == "dd_all_unw_v1") | ("`file'" == "dd_nomiss_unw_v1") {
	
		tostring year, replace
		encode year, gen(yearcode)
		order yearcode, a(year)

		encode company, gen(companycode)
		order companycode, a(company)

		eststo: reghdfe environmental_intensity_sales postxstrong ///
			, a(companycode yearcode)
	}
	
	else {
		
		tostring year, replace
		encode year, gen(yearcode)
		order yearcode, a(year)

		encode country, gen(countrycode)
		order countrycode, a(country)

		eststo: reghdfe environmental_intensity_sales postxstrong ///
			, a(countrycode yearcode)
	}
}
esttab using "$output/dd_3_v1.tex", label replace se r2 tex 
eststo clear

*Regression 4 - Controls, fixed effects 
foreach file in "dd_all_unw_v1" "dd_nomiss_unw_v1" "dd_all_w_v1" "dd_nomiss_w_v1" {

	use "$prepped_data/`file'.dta", clear	
	
	if ("`file'" == "dd_all_unw_v1") | ("`file'" == "dd_nomiss_unw_v1") {
	
		tostring year, replace
		encode year, gen(yearcode)
		order yearcode, a(year)

		encode company, gen(companycode)
		order companycode, a(company)

		eststo: reghdfe environmental_intensity_sales postxstrong ///
			eff_estimate ln_gdp_percap ln_pop, a(companycode yearcode)
	}
	
	else {
		
		tostring year, replace
		encode year, gen(yearcode)
		order yearcode, a(year)

		encode country, gen(countrycode)
		order countrycode, a(country)

		eststo: reghdfe environmental_intensity_sales postxstrong ///
			eff_estimate ln_gdp_percap ln_pop, a(countrycode yearcode)
	}
}
esttab using "$output/dd_4_v1.tex", label replace se r2 tex 
eststo clear

*V2

*Regression 1 - No controls, no fixed effects
foreach file in "dd_all_unw_v2" "dd_nomiss_unw_v2" "dd_all_w_v2" "dd_nomiss_w_v2" {
	
	use "$prepped_data/`file'.dta", clear	
	eststo: reg environmental_intensity_sales post pledge_strong postxstrong, cluster(region)
}
esttab using "$output/dd_1_v2.tex", label replace se r2 tex 
eststo clear


*Regression 2 - Controls, no fixed effects 
foreach file in "dd_all_unw_v2" "dd_nomiss_unw_v2" "dd_all_w_v2" "dd_nomiss_w_v2" {

	use "$prepped_data/`file'.dta", clear	
	eststo: reg environmental_intensity_sales post pledge_strong postxstrong ///
		eff_estimate ln_gdp_percap ln_pop, cluster(region)
}
esttab using "$output/dd_2_v2.tex", label replace se r2 tex 
eststo clear

*Regression 3 - No controls, fixed effects 
foreach file in "dd_all_unw_v2" "dd_nomiss_unw_v2" "dd_all_w_v2" "dd_nomiss_w_v2" {

	use "$prepped_data/`file'.dta", clear	
	
	if ("`file'" == "dd_all_unw_v2") | ("`file'" == "dd_nomiss_unw_v2") {
	
		tostring year, replace
		encode year, gen(yearcode)
		order yearcode, a(year)

		encode company, gen(companycode)
		order companycode, a(company)

		eststo: reghdfe environmental_intensity_sales postxstrong ///
			, a(companycode yearcode)
	}
	
	else {
		
		tostring year, replace
		encode year, gen(yearcode)
		order yearcode, a(year)

		encode country, gen(countrycode)
		order countrycode, a(country)

		eststo: reghdfe environmental_intensity_sales postxstrong ///
			, a(countrycode yearcode)
	}
}
esttab using "$output/dd_3_v2.tex", label replace se r2 tex 
eststo clear

*Regression 4 - Controls, fixed effects 
foreach file in "dd_all_unw_v2" "dd_nomiss_unw_v2" "dd_all_w_v2" "dd_nomiss_w_v2" {
	
	use "$prepped_data/`file'.dta", clear	
	
	if ("`file'" == "dd_all_unw_v2") | ("`file'" == "dd_nomiss_unw_v2") {
	
		tostring year, replace
		encode year, gen(yearcode)
		order yearcode, a(year)

		encode company, gen(companycode)
		order companycode, a(company)

		eststo: reghdfe environmental_intensity_sales postxstrong ///
			eff_estimate ln_gdp_percap ln_pop, a(companycode yearcode)
	}
	
	else {
		
		tostring year, replace
		encode year, gen(yearcode)
		order yearcode, a(year)

		encode country, gen(countrycode)
		order countrycode, a(country)

		eststo: reghdfe environmental_intensity_sales postxstrong ///
			eff_estimate ln_gdp_percap ln_pop, a(countrycode yearcode)
	}
}
esttab using "$output/dd_4_v2.tex", label replace se r2 tex 
eststo clear
