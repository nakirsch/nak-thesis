///Clean original datasets to prepare them for merging
///Created: November 11, 2022
///Modified: February 25, 2023

///Harvard Business School Impact-Weighted Accounts

//Environmental intensity
import delimited using "$orig_data/full_dataset_tabular.csv", clear

ren v4 var_type
drop grandtotal
keep if var_type == "Environmental Intensity (Sales)"

reshape long v, i(country company) j(year)

ren v environmental_intensity_sales
drop var_type

local j = 2019
forval i = 5/14 {
	replace year = `j' if year == `i'
	local j = `j' - 1
}

save "$temp/iws_intensity", replace

//Total environmental cost
import delimited using "$orig_data/full_dataset_tabular.csv", clear

ren v4 var_type
drop grandtotal
keep if var_type == "Total Environmental Cost"

reshape long v, i(country company) j(year)

ren v tot_environmental_cost
drop var_type

local j = 2019
forval i = 5/14 {
	replace year = `j' if year == `i'
	local j = `j' - 1
}

save "$temp/iws_cost", replace

//Merge datasets and finish cleaning
use "$temp/iws_intensity", clear
merge 1:1 country company year gicssubindustry using "$temp/iws_cost"

drop _merge

replace country = "Czechia" if country == "Czech Republic"
replace country = "United States of America" if country == "United States"
replace country = "Republic of Korea" if country == "South Korea"
replace country = "Russian Federation" if country == "Russia"
replace country = "Macao" if country == "Macau"

*Reclassify countries under UK, Denmark
replace country = "United Kingdom" if country == "Bermuda"
replace country = "United Kingdom" if country == "Gibraltar"
replace country = "United Kingdom" if country == "Isle of Man"
replace country = "United Kingdom" if country == "Jersey"
replace country = "United Kingdom" if country == "Guernsey"
replace country = "Denmark" if country == "Faeroe Island"

order country company year
sort country company year

*Clean intensity and cost variables, create sales variable
replace environmental_intensity_sales = subinstr(environmental_intensity_sales, "%", "", .) 
destring environmental_intensity_sales, replace
replace environmental_intensity_sales = environmental_intensity_sales/100

replace tot_environmental_cost = subinstr(tot_environmental_cost, ",", "", .) 
replace tot_environmental_cost = subinstr(tot_environmental_cost, "$", "", .) 
replace tot_environmental_cost = subinstr(tot_environmental_cost, "(", "-", .) 
replace tot_environmental_cost = subinstr(tot_environmental_cost, ")", "", .) 
destring tot_environmental_cost, replace

gen tot_sales = tot_environmental_cost/environmental_intensity_sales

save "$temp/iws", replace

///Watson (2019). The Truth Behind Climate Pledges.

import excel "$orig_data/converted_data.xlsx", sheet("Watson_2019_Climate_Pledges") firstrow allstring clear

drop H I J K
replace country = "Republic of Congo" if country == "Congo (Republic of)"
keep country pledge_strength 

save "$temp/pledge", replace

///Climate Change Performance Index

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

reshape long ccpi_overall_ ccpi_policy_score_ ccpi_policy_overall_ ccpi_policy_national_ ccpi_policy_international_, i(country) j(year)

rename *_ *

save "$temp/ccpi_long", replace

///World Bank - Worldwide Governance Indicators

//Government Effectiveness

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
replace country = "Macao" if country == "Macao SAR, China"
replace country = "Jersey" if country == "Jersey, Channel Islands"
replace country = "Republic of Korea" if country == "Korea, Rep."
replace country = "Taiwan" if country == "Taiwan, China"
replace country = "Turkey" if country == "Türkiye"
replace country = "United States of America" if country == "United States"

keep country code eff_estimate*

save "$temp/wgi_gov_effectiveness", replace

//Regulatory Quality

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
replace country = "Macao" if country == "Macao SAR, China"
replace country = "Jersey" if country == "Jersey, Channel Islands"
replace country = "Republic of Korea" if country == "Korea, Rep."
replace country = "Taiwan" if country == "Taiwan, China"
replace country = "Turkey" if country == "Türkiye"
replace country = "United States of America" if country == "United States"

keep country code reg_estimate*

save "$temp/wgi_reg_quality", replace

//Reshape and merge governance datasets (gov_effectiveness, reg_quality)

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

//World Bank - GDP

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
replace country = "Macao" if country == "Macao SAR, China"
replace country = "Republic of Korea" if country == "Korea, Rep."
replace country = "Turkey" if country == "Turkiye"
replace country = "United States of America" if country == "United States"

drop if _n == 1

save "$temp/worldbank_gdp", replace

//World Bank - GHG

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
replace country = "Macao" if country == "Macao SAR, China"
replace country = "Republic of Korea" if country == "Korea, Rep."
replace country = "Turkey" if country == "Turkiye"
replace country = "United States of America" if country == "United States"

drop if _n == 1

save "$temp/worldbank_ghg", replace

//World Bank - Population

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
replace country = "Macao" if country == "Macao SAR, China"
replace country = "Republic of Korea" if country == "Korea, Rep."
replace country = "Turkey" if country == "Turkiye"
replace country = "United States of America" if country == "United States"

drop if _n == 1

save "$temp/worldbank_pop", replace

*Reshape and save

foreach v in "gdp" "ghg" "pop" {
	use "$temp/worldbank_`v'", clear
	reshape long `v', i(country code) j(year)
	save "$temp/worldbank_`v'_long", replace
}

///World Bank Regions 
/*
Regions from the World Bank, found at:
https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-groups
*/

import excel "$orig_data/WB_regions.xlsx", firstrow allstring clear
save "$temp/WB_regions", replace
