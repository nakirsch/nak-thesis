
*Merge Original Datasets to create full_dataset
*Created: November 11, 2022
*Modified: November 14, 2022

cd "/Users/nakirsch/Documents/Georgetown 2.1/Thesis/git/nak-thesis"
global wd "/Users/nakirsch/Documents/Georgetown 2.1/Thesis/git/nak-thesis"
global orig_data "$wd/1_orig_data"
global do_files "$wd/2_do"
global prepped_data "$wd/3_prepped_data"
global temp "$wd/4_temp"
global output "$wd/5_output"

*Harvard Business School Impact-Weighted Accounts

import excel "$orig_data/IWA-Environmental-Dataset-Final-Sample-External.xlsx", sheet("Final Raw Sample(0%)") firstrow allstring clear

keep Year CompanyName Country GICSSubIndustry IndustryExiobase EnvironmentalIntensitySales EnvironmentalIntensityOpInc TotalEnvironmentalCost Imputed

rename _all, lower
rename companyname company

foreach v of varlist country gicssubindustry industryexiobase {
	replace `v' = proper(`v')
}

foreach v of varlist year environmentalintensitysales environmentalintensityopinc totalenvironmentalcost imputed {
	replace `v' = " " if `v' == "NA"
	destring `v', replace
}

replace country = "Republic of Korea" if country == "Korea, Republic Of"
replace country = "Taiwan" if country == "Taiwan, Province Of China"
replace country = "British Virgin Islands" if country == "Virgin Islands (British)"
replace country = "United Kingdom" if country == "United Kingdom Of Great Britain And Northern Ireland"
replace country = "Isle of Man" if country == "Isle Of Man"
replace country = "United States of America" if country == "United States Of America"

order country company year
sort country company year

save "$temp/iws", replace

*Watson (2019). The Truth Behind Climate Pledges.

import excel "$orig_data/converted_data.xlsx", sheet("Watson_2019_Climate_Pledges") firstrow allstring clear

drop H I J K

replace country = "Republic of Congo" if country == "Congo (Republic of)"

save "$temp/pledge", replace

*Climate Change Performance Index

import excel "$orig_data/converted_data.xlsx", sheet("CCPI_Policy") firstrow allstring clear

drop S
drop if _n > 59
destring ccpi_overall* ccpi_policy_score*, replace 

foreach v of varlist ccpi_policy_overall* ccpi_policy_national* ccpi_policy_international* {
	replace `v' = lower(`v')
}

replace country = "Taiwan" if country == "Chinese Taipei"
replace country = "United States of America" if country == "United States"
replace country = "Czechia" if country == "Czech Republic"

save "$temp/ccpi", replace

*World Bank - Worldwide Governance Indicators

*Government Effectiveness

import excel "$orig_data/wgidataset.xlsx", sheet("GovernmentEffectiveness") cellrange(A14:EJ229) firstrow allstring clear

ren A country
ren B code

keep country code AM-DX

foreach v of varlist AM-DX {
	local x : variable label `v'
	local beg = strtoname(`v'[1])
	rename `v' eff_`beg'_`x'
	rename eff_`beg'_`x', lower
}

drop if _n == 1

foreach v of varlist eff_estimate_2005-eff_upper_2019 {
	replace `v' = " " if `v' == "#N/A"
	destring `v', replace
}
					
replace country = "Czechia" if country == "Czech Republic"
replace country = "Hong Kong" if country == "Hong Kong SAR, China"
replace country = "Jersey" if country == "Jersey, Channel Islands"
replace country = "Republic of Korea" if country == "Korea, Rep."
replace country = "Taiwan" if country == "Taiwan, China"
replace country = "Turkey" if country == "Türkiye"
replace country = "United States of America" if country == "United States"

save "$temp/wgi_gov_effectiveness", replace

*Regulatory Quality

import excel "$orig_data/wgidataset.xlsx", sheet("RegulatoryQuality") cellrange(A14:EJ229) firstrow allstring clear

ren A country
ren B code

keep country code AM-DX

foreach v of varlist AM-DX {
	local x : variable label `v'
	local beg = strtoname(`v'[1])
	rename `v' reg_`beg'_`x'
	rename reg_`beg'_`x', lower
}

drop if _n == 1

foreach v of varlist reg_estimate_2005-reg_upper_2019 {
	replace `v' = " " if `v' == "#N/A"
	destring `v', replace
}

replace country = "Czechia" if country == "Czech Republic"
replace country = "Hong Kong" if country == "Hong Kong SAR, China"
replace country = "Jersey" if country == "Jersey, Channel Islands"
replace country = "Republic of Korea" if country == "Korea, Rep."
replace country = "Taiwan" if country == "Taiwan, China"
replace country = "Turkey" if country == "Türkiye"
replace country = "United States of America" if country == "United States"

save "$temp/wgi_reg_quality", replace

*World Bank - GDP

import delimited using "$orig_data/API_NY.GDP.MKTP.CD_DS2_en_csv_v2_4570866.csv", clear

drop if _n < 3

foreach v of varlist v1-v4 {
   local vname = strtoname(`v'[1])
   rename `v' `vname'
}

ren Country_Name country 
ren Country_Code code

keep country code v50-v64

local i = 2005
foreach v of varlist v50-v64 {
	rename `v' gdp`i'
	label variable gdp`i' "`i'"
	local i = `i' + 1
}

replace country = "Czechia" if country == "Czech Republic"
replace country = "Hong Kong" if country == "Hong Kong SAR, China"
replace country = "Republic of Korea" if country == "Korea, Rep."
replace country = "Turkey" if country == "Turkiye"
replace country = "United States of America" if country == "United States"

drop if _n == 1

save "$temp/worldbank_gdp", replace

*World Bank - GHG

import delimited using "$orig_data/API_EN.ATM.GHGT.KT.CE_DS2_en_csv_v2_4570451.csv", clear

drop if _n < 3

foreach v of varlist v1-v4 {
   local vname = strtoname(`v'[1])
   rename `v' `vname'
}

ren Country_Name country 
ren Country_Code code

keep country code v50-v64

local i = 2005
foreach v of varlist v50-v64 {
	rename `v' ghg`i'
	label variable ghg`i' "`i'"
	local i = `i' + 1
}

replace country = "Czechia" if country == "Czech Republic"
replace country = "Hong Kong" if country == "Hong Kong SAR, China"
replace country = "Republic of Korea" if country == "Korea, Rep."
replace country = "Turkey" if country == "Turkiye"
replace country = "United States of America" if country == "United States"

drop if _n == 1

save "$temp/worldbank_ghg", replace

*World Bank - Population

import delimited using "$orig_data/API_SP.POP.TOTL_DS2_en_csv_v2_4570891.csv", clear

drop if _n < 3

foreach v of varlist v1-v4 {
   local vname = strtoname(`v'[1])
   rename `v' `vname'
}

ren Country_Name country 
ren Country_Code code

keep country code v50-v64

local i = 2005
foreach v of varlist v50-v64 {
	rename `v' pop`i'
	label variable pop`i' "`i'"
	local i = `i' + 1
}

replace country = "Czechia" if country == "Czech Republic"
replace country = "Hong Kong" if country == "Hong Kong SAR, China"
replace country = "Republic of Korea" if country == "Korea, Rep."
replace country = "Turkey" if country == "Turkiye"
replace country = "United States of America" if country == "United States"

drop if _n == 1

save "$temp/worldbank_pop", replace

***Transform and merge all datasets

**Reshape ccpi dataset 

use "$temp/ccpi", clear

reshape long ccpi_overall_ ccpi_policy_score_ ccpi_policy_overall_ ccpi_policy_national_ ccpi_policy_international_, i(country) j(year)

rename *_ *

save "$temp/ccpi_long", replace

**Reshape and merge governance datasets (gov_effectiveness, reg_quality)

use "$temp/wgi_gov_effectiveness", clear

merge 1:1 country code using "$temp/wgi_reg_quality"
drop _merge

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

use "$temp/iws", clear 

merge m:1 country using "$temp/pledge"
tab country if _merge == 1
tab country if _merge == 2

/*COME BACK TO THIS - SOME COUNTRIES MAY NEED TO BE RECLASSIFIED

Check the following, which are not found in Watson_2019_Climate_Pledges:

Bermuda - UK
British Virgin Islands - UK
Cayman Islands - UK
Gibraltar - UK
Hong Kong - China
Isle of Man - UK
Jersey - UK

*/

keep if _merge == 1 | _merge == 3
drop _merge

merge m:1 country year using "$temp/ccpi_long"
tab country if _merge == 1
tab country if _merge == 2

keep if _merge == 1 | _merge == 3
drop _merge

merge m:1 country year using "$temp/wgi_long"
tab country if _merge == 1
tab country if _merge == 2

keep if _merge == 1 | _merge == 3
drop _merge

merge m:1 country year using "$temp/controls_long"
tab country if _merge == 1
tab country if _merge == 2

keep if _merge == 1 | _merge == 3
drop _merge

order country code company year

save "$prepped_data/full_dataset"
