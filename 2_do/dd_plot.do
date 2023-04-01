use "$prepped_data/dd_sub4_agg_all.dta", clear

tostring year, replace
encode year, gen(yearcode)
order yearcode, a(year)

encode country, gen(countrycode)
order countrycode, a(country)

decode yearcode, gen(t)
destring t, force replace

reg environmental_intensity_sales i.post##i.pledge_strong eff_estimate ln_gdp_percap ln_pop c.yearcode##c.yearcode , coefl
predict y

tw (scatter y yearcode if pledge_strong == 0 , m(.) mc(black) msize(tiny) jitter(5)) ///
   (scatter y yearcode if pledge_strong == 1 , m(x) mc(red) jitter(5)) ///
   (lpoly y yearcode if pledge_strong == 0, lc(black) lw(thick)) ///
   (lpolyci y yearcode if pledge_strong == 1, lc(red) lw(thick) alw(none) fc(gray%30)) ///
   , legend(on order(3 "Weak" 5 "Strong")) yscale(reverse)
   
   -
   reghdfe environmental_intensity_sales postxstrong ///
			eff_estimate ln_gdp_percap ln_pop, a(countrycode yearcode)
