///OLS to examine pretrends for difference in intensity by countries' pledge strength
///Created: February 3, 2023
///Modified: February 25, 2023

/*
Intensity = B0 + B1pledge + 
            + B2X (X = governance, GDP, pop)
			+ year fes
			+ error
*/

/*
Government Effectiveness (GE) – capturing perceptions of the quality of public services, the quality of the civil service and the degree of its independence from political pressures, the quality of policy formulation and implementation, and the credibility of the government's commitment to such policies.

Regulatory Quality (RQ) – capturing perceptions of the ability of the government to formulate and implement sound policies and regulations that permit and promote private sector development.

Estimate of governance (ranges from approximately -2.5 (weak) to 2.5 (strong) governance performance)

https://info.worldbank.org/governance/wgi/Home/FAQ
*/

foreach file in "ols_sub1_unagg_all.dta" "ols_sub2_unagg_neg_dropobs.dta" ///
	"ols_sub3_unagg_neg_dropfirms.dta" "ols_sub4_agg_all.dta" ///
	"ols_sub5_agg_neg_dropobs.dta" "ols_sub6_agg_neg_dropfirms.dta" {

	use "$prepped_data/`file'", clear
	
	//Run without fes
	reg environmental_intensity_sales pledge_strong eff_estimate ln_gdp ln_pop, cluster(region)
	
	if "`file'" == "ols_sub1_unagg_all.dta" {
		outreg2 using "$output/OLS_.xls", replace dec(3) cttop(`file')
	}
	else {
		outreg2 using "$output/OLS_.xls", dec(3) cttop(`file')
	}
	
	//Run with year fes 
	tostring year, replace
	encode year, gen(yearcode)
	order yearcode, a(year)
	
	reghdfe environmental_intensity_sales pledge_strong eff_estimate ln_gdp ln_pop ///
			, cluster(region) a(yearcode)

	if "`file'" == "ols_sub1_unagg_all.dta" {
		outreg2 using "$output/OLS_fe.xls", replace dec(3) cttop(`file')
	}
	else {
		outreg2 using "$output/OLS_fe.xls", dec(3) cttop(`file')
	}
}

