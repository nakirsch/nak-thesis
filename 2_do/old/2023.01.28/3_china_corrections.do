///Create subsets of the data for further analysis
///Created: January 28, 2023
///Modified: January 28, 2023

/*
Corrections for Hong Kong and Macao
Provide own characteristics - gdp, pop
But China's governance - pledge_strength, ccpi_overall, ccpi_policy_score, ccpi_policy_overall, ccpi_policy_national, ccpi_policy_international, eff_estimate, reg_estimate, ghg
*/

use "$temp/iws", clear 

gen country_orig = country
order country_orig country *
replace country = "China" if (country == "Macao") | (country == "Hong Kong")

/*Drop Taiwan since they can't participate in the UN
https://www.washingtonpost.com/world/asia_pacific/taiwan-china-emissions-cop26-climate/2021/11/09/534f8724-4038-11ec-9404-50a28a88b9cd_story.html

Taiwan, which lost its U.N. seat to China in 1971 and has been blocked by Beijing from participating in U.N.-affiliated bodies because of the dispute over its political status, cannot sign on to the U.N. Framework Convention on Climate Change (UNFCCC). Beijing, which repeatedly claims that Taiwan is part of China, does not include Taiwan's emissions in its count.
*/

drop if country == "Taiwan"

*Merge with pledge data

merge m:1 country using "$temp/pledge"
tab country if _merge == 1

keep if _merge == 1 | _merge == 3
drop _merge

*Merge with ccpi data

merge m:1 country year using "$temp/ccpi_long"
tab country if _merge == 1
tab country if _merge == 2
*14 countries unmatched

keep if _merge == 1 | _merge == 3
drop _merge

*Merge with governance data

merge m:1 country year using "$temp/wgi_long"
tab country if _merge == 1

keep if _merge == 1 | _merge == 3
drop _merge

*Merge with country-level controls

merge m:1 country year using "$temp/worldbank_ghg_long"
tab country if _merge == 1
keep if _merge == 1 | _merge == 3
drop _merge

replace country = country_orig
drop country_orig

merge m:1 country year using "$temp/worldbank_gdp_long"
tab country if _merge == 1
keep if _merge == 1 | _merge == 3
drop _merge

merge m:1 country year using "$temp/worldbank_pop_long"
tab country if _merge == 1
keep if _merge == 1 | _merge == 3
drop _merge

order country code company year

*Create binary variable for pledge strength
gen pledge_strong = 0
replace pledge_strong = 1 if pledge_strength == "partially_sufficient"
replace pledge_strong = 1 if pledge_strength == "sufficient"

save "$prepped_data/full_dataset", replace
