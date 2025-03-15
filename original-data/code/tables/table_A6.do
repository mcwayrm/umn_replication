* Setup paths
clear 

* Load data for all experiments
use "${data_folder}/main_study_cleaned.dta", clear 

***************************************************
************ Create the table *********************
***************************************************

local outcomes publish z_qualityfob z_qualitysob z_importancefob z_importancesob
local table table_A6.tex

***************************************************************
********* Panel A: Baseline      ******************************
***************************************************************


eststo clear 
foreach var of varlist `outcomes' { 
	qui eststo `var': reghdfe `var' i.($treatments),  absorb(id vignette) vce(cluster id)
}

esttab * using "${table_folder}/`table'", replace gaps se f b(3) keep (1.low) coeflabel(1.low "Null result treatment")  label noobs  starlevels( * 0.10 ** 0.05 *** 0.01) mgroups("Publishability" "Quality (z-scored)" "Importance (z-scored)", pattern(1 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("\shortstack{Beliefs\\in percent}" "\shortstack{First-order\\beliefs}" "\shortstack{Second-order\\beliefs}" "\shortstack{First-order\\beliefs}" "\shortstack{Second-order\\beliefs}") stats(N N_clust, labels("Observations" "Respondents") fmt(%9.0fc a3)) refcat(1.low "& & & & \\ \textbf{Panel A: Baseline}", nolabel) 	


***************************************************************
********* Panel B: High power             *********************
***************************************************************

eststo clear
foreach var of varlist `outcomes' { 
	qui eststo `var': reghdfe `var' i.($treatments) if inlist(vignette, 3, 4, 5),  absorb(id vignette) vce(cluster id)
}

esttab * using "${table_folder}/`table'", append gaps se f b(3) keep (1.low) coeflabel(1.low "Null result treatment")  label noobs  starlevels( * 0.10 ** 0.05 *** 0.01) stats(N N_clust, labels("Observations" "Respondents") fmt(%9.0fc a3)) refcat(1.low "& & & & \\ \textbf{Panel B: High power}", nolabel) collabels(none) nonumber nomtitles

***************************************************************
********* Panel C: Low-powered studies    *********************
***************************************************************

eststo clear
foreach var of varlist `outcomes' { 
	qui eststo `var': reghdfe `var' i.($treatments) if !inlist(vignette, 3, 4, 5),  absorb(id vignette) vce(cluster id)
}

esttab * using "${table_folder}/`table'", append gaps se f b(3) keep (1.low) coeflabel(1.low "Null result treatment")  label noobs  starlevels( * 0.10 ** 0.05 *** 0.01) stats(N N_clust, labels("Observations" "Respondents") fmt(%9.0fc a3)) refcat(1.low "& & & & \\ \textbf{Panel C: Low power}", nolabel) collabels(none) nonumber nomtitles

***************************************************************
********* Panel D: High power + applied micro  ****************
***************************************************************

egen no_applied_experience = rowtotal(specialitymacro specialityinternational specialityfinance specialitytheory)
replace no_applied_experience = (no_applied_experience > 0)

eststo clear
foreach var of varlist `outcomes' { 
	qui eststo `var': reghdfe `var' i.($treatments) if !no_applied_experience & inlist(vignette, 3, 4, 5),  absorb(id vignette) vce(cluster id)
}

esttab * using "${table_folder}/`table'", append gaps se f b(3) keep (1.low) coeflabel(1.low "Null result treatment")  label noobs  starlevels( * 0.10 ** 0.05 *** 0.01) stats(N N_clust, labels("Observations" "Respondents") fmt(%9.0fc a3)) refcat(1.low "& & & & \\ \textbf{Panel D: Empirical micro sample}", nolabel) collabels(none) nonumber nomtitles

**********************************************************************************************
********* Statistical differences across high/low-powered vignettes  ****************
**********************************************************************************************

* Test for statistically significant differences across high- and low-powered vignettes
eststo clear
qui eststo highpower: reg publish low exlow exhigh field phd unilow pval ib1.vignette ib1.id if inlist(vignette, 3, 4, 5)
qui eststo lowpower: reg publish low exlow exhigh field phd unilow pval ib1.vignette ib1.id if inlist(vignette, 1, 2)
eststo quality: qui suest highpower lowpower , vce(cluster id)
test [highpower_mean]low = [lowpower_mean]low 
