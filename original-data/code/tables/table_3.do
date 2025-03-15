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
local table table_3.tex

***************************************************************
********* Panel A: Fixed effect  ******************************
***************************************************************

foreach var of varlist `outcomes' { 
	eststo `var': reghdfe `var' i.($treatments),  absorb(id vignette) vce(cluster id)
}


esttab * using "${table_folder}/`table'", replace  se ///
	f b(3) ///
	keep (1.low) ///
	coeflabel(1.low "Null result treatment") /// 
	label /// 
	noobs  ///
	starlevels( * 0.10 ** 0.05 *** 0.01) ///
	mgroups("Publishability" "Quality (z-scored)" "Importance (z-scored)", pattern(1 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	mtitle("\shortstack{Beliefs\\in percent}" "\shortstack{First-order\\beliefs}" "\shortstack{Second-order\\beliefs}" "\shortstack{First-order\\beliefs}" "\shortstack{Second-order\\beliefs}") ///
	refcat(1.low "& & & & \\ \textbf{Panel A: Individual fixed effects}", nolabel)
	

***************************************************************
********* Panel B: OLS  ******************************
***************************************************************

eststo clear 
foreach var of varlist `outcomes' { 
eststo `var': reghdfe `var' i.($treatments),  absorb(vignette) vce(cluster id)
}

esttab * using "${table_folder}/`table'", append se /// 
	keep(1.low) ///
	nomtitles ///
	f b(3) gaps collabels(none) nonumber ///
	stats(N N_clust, labels("Observations" "Respondents") fmt(%9.0fc a3)) ///
	starlevels( * 0.1 ** 0.05 *** 0.01)  ///
	refcat(1.low "& & & & \\ \textbf{Panel B: No individual FE}", nolabel)  ///
	coeflabel(1.low "Null result treatment") order(`outcomes') 					
