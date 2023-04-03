///DD Results Plot
///Created: February 2, 2023
///Modified: April 2, 2023

graph set window fontface "Times"

*All_unw
use "$prepped_data/dd_all_unw", clear

tostring year, replace
encode year, gen(yearcode)
order yearcode, a(year)

encode company, gen(companycode)
order companycode, a(company)

decode yearcode, gen(t)
destring t, force replace

reg environmental_intensity_sales i.post##i.pledge_strong eff_estimate ln_gdp_percap ln_pop c.yearcode##c.yearcode , coefl
predict y
  
tw (lpoly y yearcode if pledge_strong == 0, lc(maroon) lw(thick)) ///
   (lpolyci y yearcode if pledge_strong == 1, lc(navy) lw(thick) alw(none) fc(gray%30)) ///
   , legend(on order(3 "Strong" 1 "Weak")) ///
   title("All Data, Unweighted") ///
   ytitle("Fitted values") ///
   xtitle("") ///
   xlabel(none) ///
   plotregion(fcolor(white)) ///
   graphregion(color(white)) ///
   legend(region(color(white))) ///
   saving(dd_all_unw, replace)

*Nomiss_unw
use "$prepped_data/dd_nomiss_unw", clear

tostring year, replace
encode year, gen(yearcode)
order yearcode, a(year)

encode company, gen(companycode)
order companycode, a(company)

decode yearcode, gen(t)
destring t, force replace

reg environmental_intensity_sales i.post##i.pledge_strong eff_estimate ln_gdp_percap ln_pop c.yearcode##c.yearcode , coefl
predict y
  
tw (lpoly y yearcode if pledge_strong == 0, lc(maroon) lw(thick)) ///
   (lpolyci y yearcode if pledge_strong == 1, lc(navy) lw(thick) alw(none) fc(gray%30)) ///
   , legend(on order(3 "Strong" 1 "Weak")) ///
   title("No Missing Data, Unweighted") ///
   ytitle("") ///
   xtitle("") ///
   xlabel(none) ///
   plotregion(fcolor(white)) ///
   graphregion(color(white)) ///
   legend(region(color(white))) ///
   saving(dd_nomiss_unw, replace)

*All_w
use "$prepped_data/dd_all_w", clear

tostring year, replace
encode year, gen(yearcode)
order yearcode, a(year)

encode country, gen(countrycode)
order countrycode, a(country)

decode yearcode, gen(t)
destring t, force replace

reg environmental_intensity_sales i.post##i.pledge_strong eff_estimate ln_gdp_percap ln_pop c.yearcode##c.yearcode , coefl
predict y
  
tw (lpoly y yearcode if pledge_strong == 0, lc(maroon) lw(thick)) ///
   (lpolyci y yearcode if pledge_strong == 1, lc(navy) lw(thick) alw(none) fc(gray%30)) ///
   , legend(on order(3 "Strong" 1 "Weak")) ///
   title("All Data, Weighted") ///
   ytitle("Fitted values") ///
   xtitle("") ///
   xlabel(1 "2010" 2 "2011" 3 "2012" 4 "2013" 5 "2014" 6 "2015" 7 "2016" 8 "2017" 9 "2018" 10 "2019") ///
   xline(7, lcolor(black)) ///
   plotregion(fcolor(white)) ///
   graphregion(color(white)) ///
   legend(region(color(white))) ///
   saving(dd_all_w, replace)

*Nomiss_w
use "$prepped_data/dd_nomiss_w", clear

tostring year, replace
encode year, gen(yearcode)
order yearcode, a(year)

encode country, gen(countrycode)
order countrycode, a(country)

decode yearcode, gen(t)
destring t, force replace

reg environmental_intensity_sales i.post##i.pledge_strong eff_estimate ln_gdp_percap ln_pop c.yearcode##c.yearcode , coefl
predict y
  
tw (lpoly y yearcode if pledge_strong == 0, lc(maroon) lw(thick)) ///
   (lpolyci y yearcode if pledge_strong == 1, lc(navy) lw(thick) alw(none) fc(gray%30)) ///
   , legend(on order(3 "Strong" 1 "Weak")) ///
   title("No Missing Data, Weighted") ///
   ytitle("") ///
   xtitle("") ///
   xlabel(1 "2010" 2 "2011" 3 "2012" 4 "2013" 5 "2014" 6 "2015" 7 "2016" 8 "2017" 9 "2018" 10 "2019") ///
   xline(7, lcolor(black)) ///
   plotregion(fcolor(white)) ///
   graphregion(color(white)) ///
   legend(region(color(white))) ///
   saving(dd_nomiss_w, replace)
   
*Combine
grc1leg dd_all_unw.gph dd_nomiss_unw.gph dd_all_w.gph dd_nomiss_w.gph , ycommon scheme(s1color)
graph export "$output/dd_results_plot.png", replace

/*
tw (scatter y yearcode if pledge_strong == 0 , m(.) mc(black) msize(tiny) jitter(5)) ///
   (scatter y yearcode if pledge_strong == 1 , m(x) mc(red) jitter(5)) ///
   (lpoly y yearcode if pledge_strong == 0, lc(black) lw(thick)) ///
   (lpolyci y yearcode if pledge_strong == 1, lc(red) lw(thick) alw(none) fc(gray%30)) ///
   , legend(on order(3 "Weak" 5 "Strong")) ///
   saving(dd_all_w, replace)
*/

*xlabel(none) 
*xlabel(2010 (1) 2019)
*xline(2016, lcolor(black)) 
