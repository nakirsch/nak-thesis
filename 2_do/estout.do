*Estout experiment 

*Run at the country level only
use "$prepped_data/lpm_sub4_agg_all.dta", clear 

*labels 
label var pledge_strong "Strong pledge"
label var eff_estimate "Government effectiveness (-2.5 weak to 2.5 strong)"
label var ln_ghg "Natural log of total GHG emissions (kt of CO2 equivalent)"
label var ln_gdp "Natural log of GDP (in USD)"
label var ln_pop "Natural log of total population"
label var ghg_percap "GHG emissions (kt of CO2 equivalent) per capita"
label var gdp_percap "GDP (in USD) per capita"
label var ln_gdp_percap "Natural log of GDP (in USD) per capita"
label var ccpi_overall "Climate Change Performance Index"

//Run with controls as input
eststo: reg pledge_strong eff_estimate ln_ghg ln_gdp ln_pop, cluster(region)
eststo: reg pledge_strong eff_estimate ghg_percap gdp_percap ln_pop, cluster(region)
eststo: reg pledge_strong eff_estimate ghg_percap ln_gdp ln_pop, cluster(region)
eststo: reg pledge_strong eff_estimate ln_ghg gdp_percap ln_pop, cluster(region)
eststo: reg pledge_strong eff_estimate ghg_percap ln_gdp_percap ln_pop, cluster(region)

//Run with CCPI as input
eststo: reg pledge_strong ccpi_overall, cluster(region)
esttab using "$output/LPM.tex", label replace se r2 tex 

eststo clear


sysuse auto
eststo: reg price weight mpg
eststo: reg price weight mpg foreign 
esttab using "$output/example.tex", label nostar
