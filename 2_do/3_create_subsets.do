///Create subsets of the data for further analysis
///Created: April 1, 2023
///Modified: April 1, 2023

///Clean full_dataset

use "$prepped_data/full_dataset", clear
drop code gicssubindustry pledge_strength ccpi_policy_national ccpi_policy_international
	
label var pledge_strong "Strong pledge"
label var eff_estimate "Government effectiveness"
label var ghg "GHG emissions (kt of CO2 equivalent)"
label var gdp "GDP (USD)"
label var pop "Population"
label var ccpi_overall "Climate Change Performance Index"
label var environmental_intensity_sales "Environmental intensity"
label var region "Region"

*Flip signs of environmental intensity variables 
replace environmental_intensity_sales = -environmental_intensity_sales
replace tot_environmental_cost = -tot_environmental_cost

save "$prepped_data/full_dataset_clean", replace

///Main four datasets

//All W
*Firms weighted by company size (sales revenues)
preserve 
drop environmental_intensity_sales

collapse (mean) tot_environmental_cost tot_sales ///
	(firstnm) region ccpi_overall ccpi_policy_score ccpi_policy_overall eff_estimate reg_estimate ghg gdp pop pledge_strong, ///
	by(country year)

gen environmental_intensity_sales = tot_environmental_cost/tot_sales

order country region year environmental_intensity_sales tot_environmental_cost tot_sales ///
	ccpi_overall ccpi_policy_score ccpi_policy_overall eff_estimate reg_estimate ghg gdp pop pledge_strong

label var eff_estimate "Government effectiveness"
label var ccpi_overall "Climate Change Performance Index"
	
save "$prepped_data/all_w", replace
restore

//All Un-W
preserve 
save "$prepped_data/all_unw", replace
restore

//No Miss W
*Firms weighted by company size (sales revenues)
preserve 
egen anymiss = max(missing(environmental_intensity_sales)), by(country company)
drop if anymiss == 1 // 489 companies in 34 countries remain
drop anymiss
drop environmental_intensity_sales

collapse (mean) tot_environmental_cost tot_sales ///
	(firstnm) region ccpi_overall ccpi_policy_score ccpi_policy_overall eff_estimate reg_estimate ghg gdp pop pledge_strong, ///
	by(country year)

gen environmental_intensity_sales = tot_environmental_cost/tot_sales

order country region year environmental_intensity_sales tot_environmental_cost tot_sales ///
	ccpi_overall ccpi_policy_score ccpi_policy_overall eff_estimate reg_estimate ghg gdp pop pledge_strong

label var eff_estimate "Government effectiveness"
label var ccpi_overall "Climate Change Performance Index"

save "$prepped_data/nomiss_w", replace
restore

//No Miss Un-W
preserve 
egen anymiss = max(missing(environmental_intensity_sales)), by(country company)
drop if anymiss == 1 // 489 companies in 34 countries remain
drop anymiss
save "$prepped_data/nomiss_unw", replace
restore

///Datasets for the appendix

//All W, V1
*Firms weighted by company size (sales revenues)
*Only firms with environmental damage (dropped observations)
preserve 
keep if (environmental_intensity_sales > 0) | (environmental_intensity_sales == .)
drop environmental_intensity_sales

collapse (mean) tot_environmental_cost tot_sales ///
	(firstnm) region ccpi_overall ccpi_policy_score ccpi_policy_overall eff_estimate reg_estimate ghg gdp pop pledge_strong, ///
	by(country year)

gen environmental_intensity_sales = tot_environmental_cost/tot_sales

order country region year environmental_intensity_sales tot_environmental_cost tot_sales ///
	ccpi_overall ccpi_policy_score ccpi_policy_overall eff_estimate reg_estimate ghg gdp pop pledge_strong

label var eff_estimate "Government effectiveness"
label var ccpi_overall "Climate Change Performance Index"

save "$prepped_data/all_w_v1", replace
restore

//All W, V2
*Firms weighted by company size (sales revenues)
*Only firms with environmental damage (dropped firms)
preserve 
egen anyneg = max(environmental_intensity_sales != . & environmental_intensity_sales < 0), by(country company)
drop if anyneg == 1
drop anyneg
drop environmental_intensity_sales

collapse (mean) tot_environmental_cost tot_sales ///
	(firstnm) region ccpi_overall ccpi_policy_score ccpi_policy_overall eff_estimate reg_estimate ghg gdp pop pledge_strong, ///
	by(country year)

gen environmental_intensity_sales = tot_environmental_cost/tot_sales

order country region year environmental_intensity_sales tot_environmental_cost tot_sales ///
	ccpi_overall ccpi_policy_score ccpi_policy_overall eff_estimate reg_estimate ghg gdp pop pledge_strong

label var eff_estimate "Government effectiveness"
label var ccpi_overall "Climate Change Performance Index"
	
save "$prepped_data/all_w_v2", replace
restore

//All Un-W, V1
*Only firms with environmental damage (dropped observations)
preserve 
keep if (environmental_intensity_sales > 0) | (environmental_intensity_sales == .)
save "$prepped_data/all_unw_v1", replace
restore

//All Un-W, V2
*Only firms with environmental damage (dropped firms)
preserve 
egen anyneg = max(environmental_intensity_sales != . & environmental_intensity_sales < 0), by(country company)
drop if anyneg == 1
drop anyneg
save "$prepped_data/all_unw_v2", replace
restore

//No Miss W, V1
*Firms weighted by company size (sales revenues)
*Only firms with environmental damage (dropped observations)
preserve 
egen anymiss = max(missing(environmental_intensity_sales)), by(country company)
drop if anymiss == 1 // 489 companies in 34 countries remain
drop anymiss

keep if (environmental_intensity_sales > 0) | (environmental_intensity_sales == .)
drop environmental_intensity_sales

collapse (mean) tot_environmental_cost tot_sales ///
	(firstnm) region ccpi_overall ccpi_policy_score ccpi_policy_overall eff_estimate reg_estimate ghg gdp pop pledge_strong, ///
	by(country year)

gen environmental_intensity_sales = tot_environmental_cost/tot_sales

order country region year environmental_intensity_sales tot_environmental_cost tot_sales ///
	ccpi_overall ccpi_policy_score ccpi_policy_overall eff_estimate reg_estimate ghg gdp pop pledge_strong

label var eff_estimate "Government effectiveness"
label var ccpi_overall "Climate Change Performance Index"
	
save "$prepped_data/nomiss_w_v1", replace
restore

//No Miss W, V2
*Firms weighted by company size (sales revenues)
*Only firms with environmental damage (dropped firms)
preserve 
egen anymiss = max(missing(environmental_intensity_sales)), by(country company)
drop if anymiss == 1 // 489 companies in 34 countries remain
drop anymiss
egen anyneg = max(environmental_intensity_sales != . & environmental_intensity_sales < 0), by(country company)
drop if anyneg == 1
drop anyneg
drop environmental_intensity_sales

collapse (mean) tot_environmental_cost tot_sales ///
	(firstnm) region ccpi_overall ccpi_policy_score ccpi_policy_overall eff_estimate reg_estimate ghg gdp pop pledge_strong, ///
	by(country year)

gen environmental_intensity_sales = tot_environmental_cost/tot_sales

order country region year environmental_intensity_sales tot_environmental_cost tot_sales ///
	ccpi_overall ccpi_policy_score ccpi_policy_overall eff_estimate reg_estimate ghg gdp pop pledge_strong

label var eff_estimate "Government effectiveness"
label var ccpi_overall "Climate Change Performance Index"

save "$prepped_data/nomiss_w_v2", replace
restore

//No Miss Un-W, V1
*Only firms with environmental damage (dropped observations)
preserve 
egen anymiss = max(missing(environmental_intensity_sales)), by(country company)
drop if anymiss == 1 // 489 companies in 34 countries remain
drop anymiss
keep if (environmental_intensity_sales > 0) | (environmental_intensity_sales == .)
save "$prepped_data/nomiss_unw_v1", replace
restore

//No Miss Un-W, V2
*Only firms with environmental damage (dropped firms)
preserve 
egen anymiss = max(missing(environmental_intensity_sales)), by(country company)
drop if anymiss == 1 // 489 companies in 34 countries remain
drop anymiss
egen anyneg = max(environmental_intensity_sales != . & environmental_intensity_sales < 0), by(country company)
drop if anyneg == 1
drop anyneg
save "$prepped_data/nomiss_unw_v2", replace
restore

//Additional changes for all subsets
foreach file in "all_w" "all_unw" "nomiss_w" "nomiss_unw" "all_w_v1" "all_w_v2" ///
	"all_unw_v1" "all_unw_v2" "nomiss_w_v1" "nomiss_w_v2" "nomiss_unw_v1" "nomiss_unw_v2" {
		
		use "$prepped_data/`file'", clear
		gen ln_ghg = ln(ghg)
		gen ln_gdp = ln(gdp)
		gen ln_pop = ln(pop)
		
		label var ln_ghg "Natural log of GHG emissions (kt of CO2 equivalent)"
		label var ln_gdp "Natural log of GDP (USD)"
		label var ln_pop "Natural log of population"
		
		save "$prepped_data/`file'", replace
	}
