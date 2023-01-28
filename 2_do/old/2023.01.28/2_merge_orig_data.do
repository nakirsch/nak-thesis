///Merge cleaned datasets to create full_dataset
///Created: November 11, 2022
///Modified: January 27, 2023

//Reshape ccpi dataset 

use "$temp/ccpi", clear

reshape long ccpi_overall_ ccpi_policy_score_ ccpi_policy_overall_ ccpi_policy_national_ ccpi_policy_international_, i(country) j(year)

rename *_ *

save "$temp/ccpi_long", replace

//Reshape and merge governance datasets (gov_effectiveness, reg_quality)

use "$temp/wgi_gov_effectiveness", clear

merge 1:1 country code using "$temp/wgi_reg_quality"
drop _merge

save "$temp/wgi_wide", replace

*Long form

use "$temp/wgi_gov_effectiveness", clear
reshape long eff_estimate_, i(country code) j(year)
save "$temp/wgi_gov_effectiveness_long", replace

use "$temp/wgi_reg_quality", clear
reshape long reg_estimate_, i(country code) j(year)
save "$temp/wgi_reg_quality_long", replace

use "$temp/wgi_gov_effectiveness_long", clear

merge 1:1 country code year using "$temp/wgi_reg_quality_long"
drop _merge 
rename *_ *

save "$temp/wgi_long", replace

//Merge and transform control variable datasets (gdp, ghg, pop)

use "$temp/worldbank_gdp", clear

merge 1:1 country code using "$temp/worldbank_ghg"
drop _merge

merge 1:1 country code using "$temp/worldbank_pop"
drop _merge

save "$temp/controls_wide", replace

*Reshape and save

foreach v in "gdp" "ghg" "pop" {
	use "$temp/worldbank_`v'", clear
	reshape long `v', i(country code) j(year)
	save "$temp/worldbank_`v'_long", replace
}

use "$temp/worldbank_gdp_long", clear

merge 1:1 country code year using "$temp/worldbank_ghg_long"
drop _merge

merge 1:1 country code year using "$temp/worldbank_pop_long"
drop _merge

save "$temp/controls_long", replace

//Merge all datasets

*Merge with pledge data

use "$temp/iws", clear 

merge m:1 country using "$temp/pledge"
tab country if _merge == 1
*Hong Kong, Macao, Taiwan unmatched

keep if _merge == 1 | _merge == 3
drop _merge

*Merge with ccpi data

merge m:1 country year using "$temp/ccpi_long"
tab country if _merge == 1
tab country if _merge == 2
*16 countries unmatched, including Hong Kong and Macao

keep if _merge == 1 | _merge == 3
drop _merge

*Merge with governance data

merge m:1 country year using "$temp/wgi_long"
tab country if _merge == 1

keep if _merge == 1 | _merge == 3
drop _merge

*Merge with country-level controls

merge m:1 country year using "$temp/controls_long"
tab country if _merge == 1
*Taiwan unmatched

keep if _merge == 1 | _merge == 3
drop _merge

order country code company year

/*Drop Taiwan since they can't participate in the UN
https://www.washingtonpost.com/world/asia_pacific/taiwan-china-emissions-cop26-climate/2021/11/09/534f8724-4038-11ec-9404-50a28a88b9cd_story.html

Taiwan, which lost its U.N. seat to China in 1971 and has been blocked by Beijing from participating in U.N.-affiliated bodies because of the dispute over its political status, cannot sign on to the U.N. Framework Convention on Climate Change (UNFCCC). Beijing, which repeatedly claims that Taiwan is part of China, does not include Taiwan's emissions in its count.
*/

drop if country == "Taiwan"

*Create binary variable for pledge strength
gen pledge_strong = 0
replace pledge_strong = 1 if pledge_strength == "partially_sufficient"
replace pledge_strong = 1 if pledge_strength == "sufficient"

save "$prepped_data/full_dataset", replace
