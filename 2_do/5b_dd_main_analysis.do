///Diff-in-diff to examine impact of pledges on firm-level intensity of production (using balanced sample)
///Created: March 19, 2023
///Modified: March 19, 2023

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
Intensity = B0 + B1post + B2strong + B3post*strong
		 + B4X (X = governance, GDP, pop)
		(+ country fixed effects, year fixed effects)
		 + Error
*/

foreach file in "dd_bal_sub1_unagg_all.dta" "dd_bal_sub2_unagg_neg_dropobs.dta" "dd_bal_sub3_unagg_neg_dropfirms.dta" /// 
	"dd_bal_sub4_agg_all.dta" "dd_bal_sub5_agg_neg_dropobs.dta" "dd_bal_sub6_agg_neg_dropfirms.dta" {

	*Unaggregated version
	use "$prepped_data/`file'", clear

	*without controls
	eststo: reg environmental_intensity_sales post pledge_strong postxstrong, cluster(region)

	*with controls 
	eststo: reg environmental_intensity_sales post pledge_strong postxstrong ///
		eff_estimate ln_gdp_percap ln_pop, cluster(region)

	if ("`file'" == "dd_bal_sub1_unagg_all.dta") | ("`file'" == "dd_bal_sub2_unagg_neg_dropobs.dta")| ///
	("`file'" == "dd_bal_sub3_unagg_neg_dropfirms.dta") {
	
		*fixed effects without controls
		tostring year, replace
		encode year, gen(yearcode)
		order yearcode, a(year)

		encode company, gen(companycode)
		order companycode, a(company)

		eststo: reghdfe environmental_intensity_sales postxstrong ///
			, a(companycode yearcode)

		*fixed effects with controls 
		eststo: reghdfe environmental_intensity_sales postxstrong ///
			eff_estimate ln_gdp_percap ln_pop, a(companycode yearcode)
	}
	
	else {
		
		*fixed effects without controls
		tostring year, replace
		encode year, gen(yearcode)
		order yearcode, a(year)

		encode country, gen(countrycode)
		order countrycode, a(country)

		eststo: reghdfe environmental_intensity_sales postxstrong ///
			, a(countrycode yearcode)

		*fixed effects with controls 
		eststo: reghdfe environmental_intensity_sales postxstrong ///
			eff_estimate ln_gdp_percap ln_pop, a(countrycode yearcode)
	}
	
	esttab using "$output/`file'.tex", label replace se r2 ar2 tex 
	eststo clear
}

/*
	gen salesxpostxstrong = tot_sales * postxstrong
		
	reghdfe environmental_intensity_sales i.post##i.pledge_strong##c.tot_sales ///
		, a(companycode yearcode)

	marginsplot , xscale(log)
*/

*Save regressions for fixed effects with controls for all subsets
foreach file in "dd_bal_sub1_unagg_all.dta" "dd_bal_sub2_unagg_neg_dropobs.dta" "dd_bal_sub3_unagg_neg_dropfirms.dta" /// 
	"dd_bal_sub4_agg_all.dta" "dd_bal_sub5_agg_neg_dropobs.dta" "dd_bal_sub6_agg_neg_dropfirms.dta" {

	*Unaggregated version
	use "$prepped_data/`file'", clear

	if ("`file'" == "dd_bal_sub1_unagg_all.dta") | ("`file'" == "dd_bal_sub2_unagg_neg_dropobs.dta")| ///
	("`file'" == "dd_bal_sub3_unagg_neg_dropfirms.dta") {
	
		*fixed effects with controls 
		tostring year, replace
		encode year, gen(yearcode)
		order yearcode, a(year)

		encode company, gen(companycode)
		order companycode, a(company)

		eststo: reghdfe environmental_intensity_sales postxstrong ///
			eff_estimate ln_gdp_percap ln_pop, a(companycode yearcode)
	}
	
	else {
		
		*fixed effects without controls
		tostring year, replace
		encode year, gen(yearcode)
		order yearcode, a(year)

		encode country, gen(countrycode)
		order countrycode, a(country)

		eststo: reghdfe environmental_intensity_sales postxstrong ///
			eff_estimate ln_gdp_percap ln_pop, a(countrycode yearcode)
	}
}
	
	esttab using "$output/dd_bal_main.tex", label replace se r2 ar2 tex
	eststo clear


