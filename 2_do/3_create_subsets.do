///Create subsets of the data for further analysis
///Created: January 28, 2023
///Modified: January 28, 2023

use "$prepped_data/full_dataset", clear
drop code gicssubindustry pledge_strength ccpi_policy_overall ccpi_policy_national ccpi_policy_international

//Subset 1: Unaggregated with all firms 
preserve 
save "$prepped_data/sub1_unagg_all", replace
restore

//Subset 2: Unaggregated with only firms without positive emissions (dropped observations)
preserve 
keep if (environmental_intensity_sales < 0) | (environmental_intensity_sales == .)
save "$prepped_data/sub2_unagg_neg_dropobs", replace
restore

//Subset 3: Unaggregated with only firms without positive emissions (dropped firms)
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

collapse (mean) tot_environmental_cost tot_sales, ///
	by(country year ccpi_overall ccpi_policy_score eff_estimate reg_estimate ghg gdp pop pledge_strong)

gen environmental_intensity_sales = tot_environmental_cost/tot_sales

order country year environmental_intensity_sales tot_environmental_cost tot_sales ///
	ccpi_overall ccpi_policy_score eff_estimate reg_estimate ghg gdp pop pledge_strong

	save "$prepped_data/sub4_agg_all", replace
restore

//Subset 5: Aggregated at the country level with only firms without positive emissions (dropped observations)
*Firms weighted by company size (sales revenues)
preserve 
keep if (environmental_intensity_sales < 0) | (environmental_intensity_sales == .)
drop environmental_intensity_sales

collapse (mean) tot_environmental_cost tot_sales, ///
	by(country year ccpi_overall ccpi_policy_score eff_estimate reg_estimate ghg gdp pop pledge_strong)

gen environmental_intensity_sales = tot_environmental_cost/tot_sales

order country year environmental_intensity_sales tot_environmental_cost tot_sales ///
	ccpi_overall ccpi_policy_score eff_estimate reg_estimate ghg gdp pop pledge_strong

save "$prepped_data/sub5_agg_neg_dropobs", replace
restore

//Subset 6: Aggregated at the country level with only firms without positive emissions (dropped firms)
*Firms weighted by company size (sales revenues)
preserve 
egen anypos = max(environmental_intensity_sales != . & environmental_intensity_sales > 0), by(country company)
drop if anypos == 1
drop anypos
drop environmental_intensity_sales

collapse (mean) tot_environmental_cost tot_sales, ///
	by(country year ccpi_overall ccpi_policy_score eff_estimate reg_estimate ghg gdp pop pledge_strong)

gen environmental_intensity_sales = tot_environmental_cost/tot_sales

order country year environmental_intensity_sales tot_environmental_cost tot_sales ///
	ccpi_overall ccpi_policy_score eff_estimate reg_estimate ghg gdp pop pledge_strong

save "$prepped_data/sub6_agg_neg_dropfirms", replace
restore
