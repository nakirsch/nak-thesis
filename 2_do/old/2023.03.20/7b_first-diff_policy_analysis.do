///First difference to examine impact of policy change on corporations' intensity of production (balanced sample)
///Created: March 19, 2023
///Modified: March 19, 2023

/*
Δintensity = B0 + B1Δpolicy + B2Δgovernance + B3ΔGDP + B4Δpop 
		 + error
*/

/*
codebook ccpi_policy_overall
chartab ccpi_policy_overall
*/

foreach file in "fd_bal_sub1_unagg_all.dta" "fd_bal_sub2_unagg_neg_dropobs.dta" "fd_bal_sub3_unagg_neg_dropfirms.dta" /// 
	"fd_bal_sub4_agg_all.dta" "fd_bal_sub5_agg_neg_dropobs.dta" "fd_bal_sub6_agg_neg_dropfirms.dta" {

	use "$prepped_data/`file'", clear

	//Run regression
	reg evintensity_dif policy_dif gov_dif ln_gdp_dif ln_pop_dif, r
	
	if "`file'" == "fd_bal_sub1_unagg_all.dta" {
		outreg2 using "$output/FD_bal.xls", replace lab dec(3) cttop(`file')
	}
	else {
		outreg2 using "$output/FD_bal.xls", lab dec(3) cttop(`file')
	}
}
