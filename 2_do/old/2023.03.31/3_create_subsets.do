///Create subsets of the data for further analysis
///Created: January 28, 2023
///Modified: March 26, 2023

use "$prepped_data/full_dataset", clear
drop code gicssubindustry pledge_strength ccpi_policy_national ccpi_policy_international
	
label var pledge_strong "Strong pledge"
label var eff_estimate "Government effectiveness"
label var ghg "GHG emissions (kt of CO2 equivalent)"
label var gdp "GDP (USD)"
label var pop "Population"
label var ccpi_overall "Climate Change Performance Index"
label var environmental_intensity_sales "Environmental intensity"

//Subset 1: Unaggregated with all firms 
preserve 
save "$prepped_data/sub1_unagg_all", replace
restore

//Subset 2: Unaggregated with only firms with negative emissions (dropped observations)
preserve 
keep if (environmental_intensity_sales < 0) | (environmental_intensity_sales == .)
save "$prepped_data/sub2_unagg_neg_dropobs", replace
restore

//Subset 3: Unaggregated with only firms with negative emissions (dropped firms)
preserve 
egen anypos = max(environmental_intensity_sales != . & environmental_intensity_sales > 0), by(country company)
drop if anypos == 1
drop anypos
save "$prepped_data/sub3_unagg_neg_dropfirms", replace
restore

//Subset 4: Aggregated at the country level with all firms 
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
	
save "$prepped_data/sub4_agg_all", replace
restore

//Subset 5: Aggregated at the country level with only firms with negative emissions (dropped observations)
*Firms weighted by company size (sales revenues)
preserve 
keep if (environmental_intensity_sales < 0) | (environmental_intensity_sales == .)
drop environmental_intensity_sales

collapse (mean) tot_environmental_cost tot_sales ///
	(firstnm) region ccpi_overall ccpi_policy_score ccpi_policy_overall eff_estimate reg_estimate ghg gdp pop pledge_strong, ///
	by(country year)

gen environmental_intensity_sales = tot_environmental_cost/tot_sales

order country region year environmental_intensity_sales tot_environmental_cost tot_sales ///
	ccpi_overall ccpi_policy_score ccpi_policy_overall eff_estimate reg_estimate ghg gdp pop pledge_strong

label var eff_estimate "Government effectiveness"
label var ccpi_overall "Climate Change Performance Index"

save "$prepped_data/sub5_agg_neg_dropobs", replace
restore

//Subset 6: Aggregated at the country level with only firms with negative emissions (dropped firms)
*Firms weighted by company size (sales revenues)
preserve 
egen anypos = max(environmental_intensity_sales != . & environmental_intensity_sales > 0), by(country company)
drop if anypos == 1
drop anypos
drop environmental_intensity_sales

collapse (mean) tot_environmental_cost tot_sales ///
	(firstnm) region ccpi_overall ccpi_policy_score ccpi_policy_overall eff_estimate reg_estimate ghg gdp pop pledge_strong, ///
	by(country year)

gen environmental_intensity_sales = tot_environmental_cost/tot_sales

order country region year environmental_intensity_sales tot_environmental_cost tot_sales ///
	ccpi_overall ccpi_policy_score ccpi_policy_overall eff_estimate reg_estimate ghg gdp pop pledge_strong

label var eff_estimate "Government effectiveness"
label var ccpi_overall "Climate Change Performance Index"
	
save "$prepped_data/sub6_agg_neg_dropfirms", replace
restore

//Additional changes for all subsets
foreach file in "sub1_unagg_all.dta" "sub2_unagg_neg_dropobs.dta" "sub3_unagg_neg_dropfirms.dta" /// 
	"sub4_agg_all.dta" "sub5_agg_neg_dropobs.dta" "sub6_agg_neg_dropfirms.dta" {
		
		use "$prepped_data/`file'", clear
		gen ln_ghg = ln(ghg)
		gen ln_gdp = ln(gdp)
		gen ln_pop = ln(pop)
		
		label var ln_ghg "Natural log of GHG emissions (kt of CO2 equivalent)"
		label var ln_gdp "Natural log of GDP (USD)"
		label var ln_pop "Natural log of population"
		
		save "$prepped_data/`file'", replace
	}
	
	
	