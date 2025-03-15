* Setup paths
clear 
do setup

* Load data for all experiments
use "${data_folder}/main_study_cleaned.dta", clear 

local table table_A1.tex

egen tmp_max = max(low), by(id)
egen tmp_min = min(low), by(id)
gen low_variation = tmp_max != tmp_min
drop tmp_min tmp_max
summ low_variation

***************************************************
************ Create the table *********************
***************************************************

eststo clear 

local outcomes publish z_qualityfob z_qualitysob z_importancefob z_importancesob


* Panel A: No individual fixed effects
eststo clear
qui eststo: reg publish i.low##i.pval,  vce(cluster id)
qui eststo: reghdfe publish i.low##i.pval, absorb(vignette) vce(cluster id)
qui eststo: reg publish i.low##i.pval $treatments, vce(cluster id)
qui eststo: reghdfe publish i.low##i.pval $treatments, absorb(vignette) vce(cluster id)
qui eststo: reghdfe publish i.low##i.($treatments), absorb(vignette) vce(cluster id)

esttab * , se b(3) keep(1.low 1.low#1.pval) nobase noomitted starlevels( * 0.10 ** 0.05 *** 0.01) order(1.low 1.low#1.pval) cells(b(fmt(3) star) se(fmt(3) par) p(fmt(3) par("[" "]"))) label nomtitles varwidth(30)   

estadd local vignette_fe "Yes" : est2 est4 est5
estadd local other_treatments "Yes" : est3 est4 est5
estadd local full_interaction "Yes" : est5
estadd local individual_fe "No" : _all


esttab * using "${table_folder}/`table'", replace se b(3) keep(1.low 1.low#1.pval) nobase noomitted starlevels( * 0.10 ** 0.05 *** 0.01) order(1.low 1.low#1.pval) cells(b(fmt(3) star) se(fmt(3) par) p(fmt(3) par("[" "]"))) label nomtitles varwidth(30)   interaction(" $\times$ ") collabels(none) mgroup("Dependent variable: Publishability (in \%)", pattern(1 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) stats(N N_clust individual_fe vignette_fe other_treatments full_interaction, labels("Observations" "Respondents" "Respondent fixed effects"  "Vignette fixed effects" "Controls: Other treatment arms" "All treatment arms $\times$ Null result") fmt(%9.0fc a3)) fragment booktabs gaps refcat(1.low "& & & & & \\ \textbf{Panel A: No individual FE}", nolabel)


* Panel B: No individual fixed effects
eststo clear
qui eststo: reghdfe publish i.low##i.pval, absorb(id)  vce(cluster id)
qui eststo: reghdfe publish i.low##i.pval, absorb(id vignette) vce(cluster id)
qui eststo: reghdfe publish i.low##i.pval $treatments, absorb(id) vce(cluster id)
qui eststo: reghdfe publish i.low##i.pval $treatments, absorb(id vignette) vce(cluster id)
qui eststo: reghdfe publish i.low##i.($treatments), absorb(id vignette) vce(cluster id)
summ low_variation
estadd scalar effective_N = round(r(mean) * e(N_clust),0) : _all

esttab * , se b(3) keep(1.low 1.low#1.pval) nobase noomitted starlevels( * 0.10 ** 0.05 *** 0.01) order(1.low 1.low#1.pval) cells(b(fmt(3) star) se(fmt(3) par) p(fmt(3) par("[" "]"))) label nomtitles varwidth(30)   

estadd local vignette_fe "Yes" : est2 est4 est5
estadd local other_treatments "Yes" : est3 est4 est5
estadd local full_interaction "Yes" : est5
estadd local individual_fe "Yes" : _all

esttab * using "${table_folder}/`table'", append se b(3) keep(1.low 1.low#1.pval) nobase noomitted starlevels( * 0.10 ** 0.05 *** 0.01) order(1.low 1.low#1.pval) cells(b(fmt(3) star) se(fmt(3) par) p(fmt(3) par("[" "]"))) label nomtitles varwidth(30)   interaction(" $\times$ ") collabels(none) stats(N N_clust effective_N individual_fe vignette_fe other_treatments full_interaction, labels("Observations" "Respondents" "Respondents with null variation" "Respondent fixed effects"  "Vignette fixed effects" "Controls: Other treatment arms" "All treatment arms $\times$ Null result") fmt(%9.0fc a3)) fragment booktabs gaps refcat(1.low "& & & & & \\ \textbf{Panel B: Individual FE}", nolabel) nonumber nomtitles
