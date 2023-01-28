
*Merge cleaned datasets to create full_dataset
*Created: November 11, 2022
*Modified: November 27, 2022

cd "/Users/nakirsch/Documents/Georgetown 2.1/Thesis/git/nak-thesis"
global wd "/Users/nakirsch/Documents/Georgetown 2.1/Thesis/git/nak-thesis"
global orig_data "$wd/1_orig_data"
global do_files "$wd/2_do"
global prepped_data "$wd/3_prepped_data"
global temp "$wd/4_temp"
global output "$wd/5_output"

**Reshape ccpi dataset 

use "$temp/ccpi", clear

reshape long ccpi_overall_ ccpi_policy_score_ ccpi_policy_overall_ ccpi_policy_national_ ccpi_policy_international_, i(country) j(year)

rename *_ *

save "$temp/ccpi_long", replace

**Reshape and merge governance datasets (gov_effectiveness, reg_quality)

use "$temp/wgi_gov_effectiveness", clear

merge 1:1 country code using "$temp/wgi_reg_quality"
drop _merge

*Drop Hong Kong and Macao, need to give them China's governance indicators
drop if (country == "Hong Kong") | (country == "Macao") 

save "$temp/wgi_wide", replace

*Long form

use "$temp/wgi_gov_effectiveness", clear
reshape long eff_estimate_ eff_stderr_ eff_numsrc_ eff_rank_ eff_lower_ eff_upper_, i(country code) j(year)
save "$temp/wgi_gov_effectiveness_long", replace

use "$temp/wgi_reg_quality", clear
reshape long reg_estimate_ reg_stderr_ reg_numsrc_ reg_rank_ reg_lower_ reg_upper_, i(country code) j(year)
save "$temp/wgi_reg_quality_long", replace

use "$temp/wgi_gov_effectiveness_long", clear

merge 1:1 country code year using "$temp/wgi_reg_quality_long"
drop _merge 
rename *_ *

*Drop Hong Kong and Macao, need to give them China's governance indicators
drop if (country == "Hong Kong") | (country == "Macao") 

save "$temp/wgi_long", replace

**Merge and transform control variable datasets (gdp, ghg, pop)

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

**Merge all datasets

*Note: For Hong Kong and Macao, provide own characteristics but China's governance regime

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
*15 countries unmatched, including Hong Kong and Macao

keep if _merge == 1 | _merge == 3
drop _merge

*Merge with governance data

merge m:1 country year using "$temp/wgi_long"
tab country if _merge == 1
*Hong Kong, Macao unmatched 

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

*Give China's values to Hong Kong where missing
/*
What should I do with Hong Kong and Macao?

I thought I could give them their own control characteristics (GDP, pop, GHG) but China's governance and pledges. 

But I realized that Hong Kong and Macao don't have their own GDPs. They do have their own values for governance, GDP, and pop. Which also means that their GDP and pop won't be included in the China numbers… 

Should I drop them? Should I include them as part of China? 
*/

save "$prepped_data/full_dataset"
