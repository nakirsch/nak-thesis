///LPM to examine pledge determinants
///Created: February 3, 2023
///Modified: February 3, 2023

/*
pledge = B0 + (B1policy) + B2governance + B1GHG + B3GDP + B4pop 
		 + error

pledge = B0 + B1CCPI
		 + error
*/

*Run at the country level only

foreach file in "sub4_agg_all.dta" "sub5_agg_neg_dropobs.dta" "sub6_agg_neg_dropfirms.dta" {

	use "$prepped_data/`file'", clear

	//Subset the data to year of the Paris Agreement
	keep if year == 2015

	//Run without policy
	reg pledge_strong eff_estimate ln_ghg ln_gdp ln_pop, r
	
	if "`file'" == "sub1_unagg_all.dta" {
		outreg2 using "$output/LPM_nopolicy.xls", replace dec(3) cttop(`file')
	}
	else {
		outreg2 using "$output/LPM_nopolicy.xls", dec(3) cttop(`file')
	}
	
	//Run without policy, CCPI as input
	reg pledge_strong ccpi_overall, r
	
	if "`file'" == "sub1_unagg_all.dta" {
		outreg2 using "$output/LPM_nopolicy_ccpi.xls", replace dec(3) cttop(`file')
	}
	else {
		outreg2 using "$output/LPM_nopolicy_ccpi.xls", dec(3) cttop(`file')
	}

	*Run with policy (2019 policy score applied to 2015)?
}
