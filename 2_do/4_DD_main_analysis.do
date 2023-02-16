///Diff-in-diff to examine impact of pledges on firm-level emissions
///Created: February 3, 2023
///Modified: February 8, 2023

/*
The Paris Agreement is a legally binding international treaty on climate change. It was adopted by 196 Parties at COP 21 in Paris, on 12 December 2015 and entered into force on 4 November 2016.

https://unfccc.int/process-and-meetings/the-paris-agreement/the-paris-agreement

"This Agreement shall enter into force on the thirtieth day after the date on which at least 55
Parties to the Convention accounting in total for at least an estimated 55 per cent of the total global
greenhouse gas emissions have deposited their instruments of ratification, acceptance, approval or
accession."

https://treaties.un.org/doc/Publication/CN/2016/CN.735.2016-Eng.pdf
*/

/*
Impact = B0 + B1post + B2strong + B3post*strong
		 + B4X (X = policy, governance, GDP, GHG, pop)
		(+ country fixed effects, year fixed effects)
		 + Error
*/

*Unaggregated version
use "$prepped_data/sub1_unagg_all.dta", clear

//Organize years
*drop if year == 2016
gen post = 0 
replace post = 1 if year > 2016

gen postxstrong = post * pledge_strong

*without controls
reg environmental_intensity_sales post pledge_strong postxstrong, r
*outreg2 using DD.xls, replace dec(3)

*with controls (no policy or ghg)
*policy - only have 2019 value, would need to extrapolate
*ghg - doesn't make sense to use? or if use only keep values for 2015 (year of pledge signing)?
reg environmental_intensity_sales post pledge_strong postxstrong ///
	eff_estimate ln_gdp ln_pop, r
*outreg2 using DD.xls, replace dec(3)

*fixed effects - years, without controls
tostring year, replace
encode year, gen(yearcode)
order yearcode, a(year)

xtset yearcode
xtreg environmental_intensity_sales post pledge_strong postxstrong, fe
*outreg2 using DD.xls, replace dec(3)

*fixed effects - years, with controls
xtset yearcode
xtreg environmental_intensity_sales post pledge_strong postxstrong ///
	eff_estimate ln_gdp ln_pop, fe
*outreg2 using DD.xls, replace dec(3)

********************************************************************************

*Aggregated version
use "$prepped_data/sub4_agg_all.dta", clear

//Organize years
*drop if year == 2016
gen post = 0 
replace post = 1 if year > 2016

gen postxstrong = post * pledge_strong

//without controls
reg environmental_intensity_sales post pledge_strong postxstrong, r
*outreg2 using DD.xls, replace dec(3)

//with controls (no policy or ghg)
*policy - only have 2019 value, would need to extrapolate
*ghg - doesn't make sense to use? or if use only keep values for 2015 (year of pledge signing)?
reg environmental_intensity_sales post pledge_strong postxstrong ///
	eff_estimate ln_gdp ln_pop, r
*outreg2 using DD.xls, replace dec(3)

//fixed effects - years, without controls
encode country, gen(countrycode)
order countrycode, a(country)

tostring year, replace
encode year, gen(yearcode)
order yearcode, a(year)

xtset countrycode yearcode
xtreg environmental_intensity_sales post pledge_strong postxstrong, fe
*outreg2 using DD.xls, replace dec(3)

xtset countrycode yearcode
xtreg environmental_intensity_sales post pledge_strong postxstrong, fe cluster(countrycode)
*outreg2 using DD.xls, replace dec(3)

//fixed effects - years, country, with controls
xtset countrycode yearcode
xtreg environmental_intensity_sales post pledge_strong postxstrong ///
	eff_estimate ln_gdp ln_pop, fe
*outreg2 using DD.xls, replace dec(3)

xtset countrycode yearcode
xtreg environmental_intensity_sales post pledge_strong postxstrong ///
	eff_estimate ln_gdp ln_pop, fe cluster(countrycode)
*outreg2 using DD.xls, replace dec(3)
