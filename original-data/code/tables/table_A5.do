* Setup paths
clear 
do setup.do


* Load data for all experiments
use "${data_folder}/main_study_cleaned.dta", clear 


***************************************************
************ Create the table *********************
***************************************************

eststo clear 

local outcomes publish z_qualityfob z_qualitysob z_importancefob z_importancesob

foreach var of varlist `outcomes' { 
eststo `var': reghdfe `var' i.($treatments) if order==1, absorb(vignette) vce(cluster id)
estadd local controls "Yes" 
}

***************************************************
************** Export the table *******************
***************************************************

esttab * using "${table_folder}/table_A5.tex", replace  se ///
	f b(3) ///
	keep (1.low) ///
	coeflabel(1.low "Null result treatment") ///
	label gaps /// 
	stat(N N_clust controls, labels("Observations" "Respondents" "Controls") fmt(%9.0fc %9.0fc a3)) ///
	starlevels( * 0.10 ** 0.05 *** 0.01) ///
	mgroups("Publishability" "Quality (z-scored)" "Importance (z-scored)", pattern(1 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	mtitle("\shortstack{Beliefs\\in percent}" "\shortstack{First-order\\beliefs}" "\shortstack{Second-order\\beliefs}" "\shortstack{First-order\\beliefs}" "\shortstack{Second-order\\beliefs}")
