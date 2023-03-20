///Additional tables and figures
///Created: February 3, 2023
///Modified: February 5, 2023

/*
Create:
Tables with summary stats for each variable - maybe separated by pledge strength/overall?
Map of countries by pledge strength
Diff in diff graphs
*/
	
//Table with sum stats for numeric variables
*Should I also do a version with before/after data instead of data for all years aggregated together?

*Unaggregated data
use "$prepped_data/sub1_unagg_all.dta", clear

replace ccpi_policy_overall = subinstr(ccpi_policy_overall, uchar(160), "", .)
gen policy_level = .
	replace policy_level = 1 if ccpi_policy_overall == "very low"
	replace policy_level = 2 if ccpi_policy_overall == "low"
	replace policy_level = 3 if ccpi_policy_overall == "medium"
	replace policy_level = 4 if ccpi_policy_overall == "high"
	
label define pledge_strong 0 "Weak" 1 "Strong" 

outreg2 using "$output/sub1sum.xls", replace sum(log) ///
keep (environmental_intensity_sales eff_estimate ln_ghg ln_gdp ln_pop ccpi_overall policy_level)

orth_out environmental_intensity_sales eff_estimate ln_ghg ln_gdp ln_pop ccpi_overall policy_level ///
 using "$output/sub1sum_compare.xls", by(pledge_strong) replace overall se count compare test ///
 title("Comparison by Pledge Strength")

*Aggregated data
use "$prepped_data/sub4_agg_all.dta", clear 

replace ccpi_policy_overall = subinstr(ccpi_policy_overall, uchar(160), "", .)
gen policy_level = .
	replace policy_level = 1 if ccpi_policy_overall == "very low"
	replace policy_level = 2 if ccpi_policy_overall == "low"
	replace policy_level = 3 if ccpi_policy_overall == "medium"
	replace policy_level = 4 if ccpi_policy_overall == "high"
	
label define pledge_strong 0 "Weak" 1 "Strong" 

outreg2 using "$output/sub4sum.xls", replace sum(log) ///
keep (environmental_intensity_sales eff_estimate ln_ghg ln_gdp ln_pop ccpi_overall policy_level)

orth_out environmental_intensity_sales eff_estimate ln_ghg ln_gdp ln_pop ccpi_overall policy_level ///
 using "$output/sub4sum_compare.xls", by(pledge_strong) replace overall se count compare test ///
 title("Comparison by Pledge Strength")
	   
//Map of countries by pledge strength
*Countries in analysis
use "$prepped_data/full_dataset", clear
keep country pledge_strength pledge_strong
duplicates drop

replace pledge_strength = "No pledge" if pledge_strength == "no_pledge"
replace pledge_strength = "Insufficient" if pledge_strength == "insufficient"
replace pledge_strength = "Partially Sufficient" if pledge_strength == "partially_sufficient"
replace pledge_strength = "Sufficient" if pledge_strength == "sufficient"

export excel using "$output/pledges.xlsx", replace firstrow(variables) 

*All Countries
use "$temp/pledge", clear
replace pledge_strength = "No pledge" if pledge_strength == "no_pledge"
replace pledge_strength = "Insufficient" if pledge_strength == "insufficient"
replace pledge_strength = "Partially Insufficient" if pledge_strength == "partially_insufficient"
replace pledge_strength = "Partially Sufficient" if pledge_strength == "partially_sufficient"
replace pledge_strength = "Sufficient" if pledge_strength == "sufficient"

export excel using "$output/pledges_all.xlsx", replace firstrow(variables) 

*See Tableau files

//Diff in diff graphs 
*Collapse so companies have weight proportional to size
*use "$prepped_data/sub1_unagg_all.dta", clear 
use "$prepped_data/bal_sub1_unagg_all.dta", clear 

collapse (mean) tot_environmental_cost tot_sales, by(pledge_strong year)
gen environmental_intensity_sales = tot_environmental_cost/tot_sales

twoway connected environmental_intensity_sales year if pledge_strong == 1 || ///
       connected environmental_intensity_sales year if pledge_strong == 0, ///
	   title("Environmental Intensity, by Pledge Strength") ///
	   ytitle("Environmental Intensity (Sales)") ///
	   xtitle("Year") ///
	   xlabel(2010 (1) 2019) ///
	   legend(order(1 "strong" 2 "weak")) ///
	   xline(2015, lcolor(black)) ///
	   graphregion(color(white))	///
	   legend(region(color(white)))
	   
*Collapse so all companies/countries have the same weight
*use "$prepped_data/sub1_unagg_all.dta", clear 
use "$prepped_data/bal_sub1_unagg_all.dta", clear 

collapse (mean) environmental_intensity_sales tot_environmental_cost, by(pledge_strong year)

twoway connected environmental_intensity_sales year if pledge_strong == 1 || ///
       connected environmental_intensity_sales year if pledge_strong == 0, ///
	   title("Environmental Intensity, by Pledge Strength") ///
	   ytitle("Environmental Intensity (Sales)") ///
	   xtitle("Year") ///
	   xlabel(2010 (1) 2019) ///
	   legend(order(1 "strong" 2 "weak")) ///
	   xline(2015, lcolor(black)) ///
	   graphregion(color(white))	///
	   legend(region(color(white)))
	   
*Count of companies, countries 
use "$prepped_data/sub1_unagg_all.dta", clear
unique company
unique country 
sum environmental_intensity_sales tot_environmental_cost tot_sales pop

use "$prepped_data/bal_sub1_unagg_all.dta", clear
unique company
unique country 
sum environmental_intensity_sales tot_environmental_cost tot_sales pop

*Higher total_sales, environmental_intensity_sales in balanced sample
