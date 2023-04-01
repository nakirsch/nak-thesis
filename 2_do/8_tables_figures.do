///Additional tables and figures
///Created: February 3, 2023
///Modified: March 26, 2023

/*
Create:
Tables with summary stats for each variable - maybe separated by pledge strength/overall?
Map of countries by pledge strength
Diff in diff graphs
*/

foreach file in "sub1_unagg_all" "bal_sub1_unagg_all" {
	use "$prepped_data/`file'.dta", clear
	
	replace ccpi_policy_overall = subinstr(ccpi_policy_overall, uchar(160), "", .)
	gen policy_level = .
	replace policy_level = 1 if ccpi_policy_overall == "very low"
	replace policy_level = 2 if ccpi_policy_overall == "low"
	replace policy_level = 3 if ccpi_policy_overall == "medium"
	replace policy_level = 4 if ccpi_policy_overall == "high"
	
	gen gdp_percap = gdp/pop
	gen ln_gdp_percap = ln(gdp_percap)

	label var pledge_strong "Strong pledge"
	label var environmental_intensity_sales "Environmental intensity"
	label var gdp_percap "GDP per capita (USD)"
	label var ln_gdp_percap "Natural log of GDP per capita (USD)"
	label var policy_level "Policy level"

	outreg2 using "$output/overview_`file'.xls", replace lab sum(log) ///
	keep (environmental_intensity_sales pledge_strong eff_estimate ccpi_overall ///
		policy_level ln_ghg ln_gdp_percap ln_pop)
}

/*	
Comparison:

gen post = 0 
replace post = 1 if year > 2016
label define pledge_strong 0 "Weak" 1 "Strong" 

orth_out environmental_intensity_sales eff_estimate ccpi_overall policy_level ln_ghg ln_gdp_percap ln_pop ///
	using "$output/`file'_compare.xls", by(pledge_strong) replace overall se count compare test ///
	title("Comparison of Values by Pledge Strength") 
	
Could also do with pre/post
label define post 0 "Pre-Paris" 1 "Post-Paris"
*/
	
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

*Countries in analysis with non-missing data
use "$prepped_data/full_dataset", clear
egen anymiss = max(missing(environmental_intensity_sales)), by(country company)
drop if anymiss == 1 // 489 companies in 34 countries remain
drop anymiss
keep country pledge_strength pledge_strong
duplicates drop

replace pledge_strength = "No pledge" if pledge_strength == "no_pledge"
replace pledge_strength = "Insufficient" if pledge_strength == "insufficient"
replace pledge_strength = "Partially Sufficient" if pledge_strength == "partially_sufficient"
replace pledge_strength = "Sufficient" if pledge_strength == "sufficient"

export excel using "$output/pledges_balanced.xlsx", replace firstrow(variables) 

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

graph set window fontface "Times"


use "$prepped_data/sub1_unagg_all", clear

collapse (mean) tot_environmental_cost tot_sales, by(pledge_strong year)
gen environmental_intensity_sales = tot_environmental_cost/tot_sales

twoway connected environmental_intensity_sales year if pledge_strong == 1 || ///
	   connected environmental_intensity_sales year if pledge_strong == 0, ///
	   title("Full Data, Weighted") ///
	   ytitle("Environmental Intensity") ///
	   xtitle("") ///
	   xlabel(none) ///
	   xline(2016, lcolor(black)) ///
	   plotregion(fcolor(white)) ///
	   graphregion(color(white)) ///
	   legend(order(1 "Strong" 2 "Weak")) ///
	   legend(region(color(white))) ///
	   saving(all_w, replace)
	   
use "$prepped_data/sub1_unagg_all", clear

collapse (mean) environmental_intensity_sales tot_environmental_cost, by(pledge_strong year)

twoway connected environmental_intensity_sales year if pledge_strong == 1 || ///
	   connected environmental_intensity_sales year if pledge_strong == 0, ///
	   title("Full Data, Unweighted") ///
	   ytitle("") ///
	   xtitle("") ///
	   xlabel(none) ///
	   xline(2016, lcolor(black)) ///
	   plotregion(fcolor(white)) ///
	   graphregion(color(white)) ///
	   legend(order(1 "Strong" 2 "Weak")) ///
	   legend(region(color(white))) ///
	   saving(all_no_w, replace)
	  
use "$prepped_data/bal_sub1_unagg_all", clear

collapse (mean) tot_environmental_cost tot_sales, by(pledge_strong year)
gen environmental_intensity_sales = tot_environmental_cost/tot_sales

twoway connected environmental_intensity_sales year if pledge_strong == 1 || ///
	   connected environmental_intensity_sales year if pledge_strong == 0, ///
	   title("Clean Data, Weighted") ///
	   ytitle("Environmental Intensity") ///
	   xtitle("") ///
	   xlabel(2010 (1) 2019) ///
	   xline(2016, lcolor(black)) ///
	   plotregion(fcolor(white)) ///
	   graphregion(color(white))	///
	   legend(order(1 "Strong" 2 "Weak")) ///
	   legend(region(color(white))) ///
	   saving(sub_w, replace)

use "$prepped_data/bal_sub1_unagg_all", clear

collapse (mean) environmental_intensity_sales tot_environmental_cost, by(pledge_strong year)

twoway connected environmental_intensity_sales year if pledge_strong == 1 || ///
	   connected environmental_intensity_sales year if pledge_strong == 0, ///
	   title("Clean Data, Unweighted") ///
	   ytitle("") ///
	   xtitle("") ///
	   xlabel(2010 (1) 2019) ///
	   xline(2016, lcolor(black)) ///
	   plotregion(fcolor(white)) ///
	   graphregion(color(white))	///
	   legend(order(1 "Strong" 2 "Weak")) ///
	   legend(region(color(white))) ///
	   saving(sub_no_w, replace)
	   
grc1leg all_w.gph all_no_w.gph sub_w.gph sub_no_w.gph, ycommon
graph export "$output/dd_init_plot.png", replace

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
