///OLS to examine pretrends for difference in emissions by countries' pledge strength
///Created: February 3, 2023
///Modified: February 3, 2023

/*
emissions = B0 + B1pledge + 
            + B2X (X = (policy), governance, GDP, pop)
			+ year fes
			+ error
*/

/*
Government Effectiveness (GE) – capturing perceptions of the quality of public services, the quality of the civil service and the degree of its independence from political pressures, the quality of policy formulation and implementation, and the credibility of the government's commitment to such policies.

Regulatory Quality (RQ) – capturing perceptions of the ability of the government to formulate and implement sound policies and regulations that permit and promote private sector development.

Estimate of governance (ranges from approximately -2.5 (weak) to 2.5 (strong) governance performance)

https://info.worldbank.org/governance/wgi/Home/FAQ
*/

foreach file in "sub1_unagg_all.dta" "sub2_unagg_neg_dropobs.dta" "sub3_unagg_neg_dropfirms.dta" /// 
	"sub4_agg_all.dta" "sub5_agg_neg_dropobs.dta" "sub6_agg_neg_dropfirms.dta" {

	use "$prepped_data/`file'", clear

	//Subset the data to years before the Paris Agreement
	keep if year < 2015

	//Run without policy
	reg environmental_intensity_sales pledge_strong eff_estimate ln_gdp ln_pop, r
	
	if "`file'" == "sub1_unagg_all.dta" {
		outreg2 using "$output/OLS_nopolicy.xls", replace dec(3) cttop(`file')
	}
	else {
		outreg2 using "$output/OLS_nopolicy.xls", dec(3) cttop(`file')
	}
	
	//Run without policy, including year fes 
	tostring year, replace
	encode year, gen(yearcode)
	order yearcode, a(year)

	xtset yearcode 
	xtreg environmental_intensity_sales pledge_strong eff_estimate ln_gdp ln_pop, fe

	if "`file'" == "sub1_unagg_all.dta" {
		outreg2 using "$output/OLS_nopolicy_fe.xls", replace dec(3) cttop(`file')
	}
	else {
		outreg2 using "$output/OLS_nopolicy_fe.xls", dec(3) cttop(`file')
	}

	*Run with policy (2019 policy score applied to previous years)?
}

