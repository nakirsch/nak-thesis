///Diff-in-diff to examine impact of pledges on firm-level intensity of production
///Created: February 3, 2023
///Modified: February 25, 2023

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

foreach file in "dd_sub1_unagg_all.dta" "dd_sub2_unagg_neg_dropobs.dta" "dd_sub3_unagg_neg_dropfirms.dta" /// 
	"dd_sub4_agg_all.dta" "dd_sub5_agg_neg_dropobs.dta" "dd_sub6_agg_neg_dropfirms.dta" {

	*Unaggregated version
	use "$prepped_data/`file'", clear

	*without controls
	reg environmental_intensity_sales post pledge_strong postxstrong, cluster(region)
	outreg2 using "$output/DD_`file'.xls", replace dec(3)

	*with controls 
	reg environmental_intensity_sales post pledge_strong postxstrong ///
		eff_estimate ln_gdp ln_pop, cluster(region)
	outreg2 using "$output/DD_`file'.xls", dec(3)

	if ("`file'" == "dd_sub1_unagg_all.dta") | ("`file'" == "dd_sub2_unagg_neg_dropobs.dta")| ///
	("`file'" == "dd_sub3_unagg_neg_dropfirms.dta") {
	
		*fixed effects without controls
		tostring year, replace
		encode year, gen(yearcode)
		order yearcode, a(year)

		encode company, gen(companycode)
		order companycode, a(company)

		reghdfe environmental_intensity_sales postxstrong ///
			, a(companycode yearcode)
		outreg2 using "$output/DD_`file'.xls", dec(3)

		*fixed effects with controls 
		reghdfe environmental_intensity_sales postxstrong ///
			eff_estimate ln_gdp ln_pop, a(companycode yearcode)
		outreg2 using "$output/DD_`file'.xls", dec(3)

	}
	
	else {
		
		*fixed effects without controls
		tostring year, replace
		encode year, gen(yearcode)
		order yearcode, a(year)

		encode country, gen(countrycode)
		order countrycode, a(country)

		reghdfe environmental_intensity_sales postxstrong ///
			, a(countrycode yearcode)
		outreg2 using "$output/DD_`file'.xls", dec(3)

		*fixed effects with controls 
		reghdfe environmental_intensity_sales postxstrong ///
			eff_estimate ln_gdp ln_pop, a(countrycode yearcode)
		outreg2 using "$output/DD_`file'.xls", dec(3)
		
	}
	
}

/*
	gen salesxpostxstrong = tot_sales * postxstrong
		
	reghdfe environmental_intensity_sales i.post##i.pledge_strong##c.tot_sales ///
		, a(companycode yearcode)

	marginsplot , xscale(log)
*/
