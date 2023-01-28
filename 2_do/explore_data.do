///Explore data issues to prepare for merging, visualizing
///Created: November 29, 2022
///Modified: December 6, 2022

use "$temp/iws", clear 

*Taiwan, Hong Kong, Macao

/*
Total observations: 25850
Total number of companies: 2585
Total number of countries: 62

Taiwan: 1,840, 184 companies, 7.1% of sample
Hong Kong: 930, 93 companies, 3.6% of sample
Macao: 30, 3 companies, 0.1% of sample
*/

unique company
unique country

unique company if country == "Taiwan"
disp 1840/25850*100

unique company if country == "Hong Kong"
disp 930/25850*100

unique company if country == "Macao"
disp 30/25850*100

*All Countries
use "$temp/pledge", clear
tab pledge 

use "$temp/iws", clear  

merge m:1 country using "$temp/pledge"
tab country if _merge == 1
keep if _merge == 1 | _merge == 3
drop _merge
*Hong Kong, Macao, Taiwan unmatched

tab pledge_strength  
tab pledge_strength if year == 2010

replace environmental_intensity_sales = subinstr(environmental_intensity_sales, "%", "", .) 
destring environmental_intensity_sales, replace

replace tot_environmental_cost = subinstr(tot_environmental_cost, ",", "", .) 
replace tot_environmental_cost = subinstr(tot_environmental_cost, "$", "", .) 
replace tot_environmental_cost = subinstr(tot_environmental_cost, "(", "-", .) 
replace tot_environmental_cost = subinstr(tot_environmental_cost, ")", "", .) 
destring tot_environmental_cost, replace

*Graphs grouped by pledge strength
gen pledge_strong = 0
replace pledge_strong = 1 if pledge_strength == "partially_sufficient"
replace pledge_strong = 1 if pledge_strength == "sufficient"

sum environmental_intensity_sales
sum tot_environmental_cost

*take mean values by year for each country

*Part I
use "$temp/iws", clear  

replace environmental_intensity_sales = subinstr(environmental_intensity_sales, "%", "", .) 
destring environmental_intensity_sales, replace

replace tot_environmental_cost = subinstr(tot_environmental_cost, ",", "", .) 
replace tot_environmental_cost = subinstr(tot_environmental_cost, "$", "", .) 
replace tot_environmental_cost = subinstr(tot_environmental_cost, "(", "-", .) 
replace tot_environmental_cost = subinstr(tot_environmental_cost, ")", "", .) 
destring tot_environmental_cost, replace

*Collapse so all countries have the same weight
*collapse (mean) environmental_intensity_sales tot_environmental_cost, by(country year)

merge m:1 country using "$temp/pledge"
tab country if _merge == 1
keep if _merge == 1 | _merge == 3
drop _merge
*Hong Kong, Macao, Taiwan unmatched

*Graphs grouped by pledge strength
gen pledge_strong = 0
replace pledge_strong = 1 if pledge_strength == "partially_sufficient"
replace pledge_strong = 1 if pledge_strength == "sufficient"

keep country year environmental_intensity_sales tot_environmental_cost pledge_strong

collapse (mean) environmental_intensity_sales tot_environmental_cost, by(pledge_strong year)

*Graphs
	
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

twoway (connected environmental_intensity_sales year), ///
	by(pledge_strong) 
	
twoway (connected tot_environmental_cost year), ///
	by(pledge_strong)

*Part II

*Part III
*Merge with ccpi data
use "$temp/iws", clear 
merge m:1 country year using "$temp/ccpi_long"
tab country if _merge == 1
tab country if _merge == 2
*Many countries unmatched, including Hong Kong and Macao

keep if _merge == 1 | _merge == 3
drop _merge

bysort pledge_strength: sum ccpi_overall if year == 2015




 