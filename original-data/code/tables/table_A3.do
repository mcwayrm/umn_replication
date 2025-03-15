* Setup paths
clear 


* Load data for all experiments
use "${data_folder}/main_study_cleaned.dta", clear 

rename id id_tmp
rename demographics_id id

merge m:1 id using "${out_folder}/data/weights.dta"
drop _merge

rename id demographics_id
rename id_tmp id

***************************************************
************ Create the table *********************
***************************************************

eststo clear 

local outcomes publish z_qualityfob z_qualitysob z_importancefob z_importancesob

local table table_A3.tex

***************************************************************
********* Panel A: Fixed effect baseline  ******************************
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
	refcat(1.low "& & & & \\ \textbf{Panel A: Baseline with FEs}", nolabel) 	

***************************************************************
********* Panel B: Fixed effect reweighted  ******************************
***************************************************************


foreach var of varlist `outcomes' { 
	eststo `var': reghdfe `var' i.($treatments) [aw=weights],  absorb(id vignette) vce(cluster id)
}


esttab * using "${table_folder}/`table'", append se /// 
	keep(1.low) ///
	nomtitles ///
	f b(3) gaps collabels(none) nonumber ///
	stats(N N_clust, labels("Observations" "Respondents") fmt(%9.0fc a3)) ///
	starlevels( * 0.1 ** 0.05 *** 0.01)  ///
	refcat(1.low "& & & & \\ \textbf{Panel B: Baseline with FEs, re-weighted}", nolabel)  ///
	coeflabel(1.low "Null result treatment") order(`outcomes') 					



***************************************************************
********* Panel C: OLS baseline  ******************************
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
	refcat(1.low "& & & & \\ \textbf{Panel C: OLS}", nolabel)  ///
	coeflabel(1.low "Null result treatment") order(`outcomes') 					



***************************************************************
********* Panel D: OLS baseline, re-weighted  *****************
***************************************************************


eststo clear 
foreach var of varlist `outcomes' { 
	eststo `var': reghdfe `var' i.($treatments) [aw=weights],  absorb(vignette) vce(cluster id)
}

esttab * using "${table_folder}/`table'", append se /// 
	keep(1.low) ///
	nomtitles ///
	f b(3) gaps collabels(none) nonumber ///
	stats(N N_clust, labels("Observations" "Respondents") fmt(%9.0fc a3)) ///
	starlevels( * 0.1 ** 0.05 *** 0.01)  ///
	refcat(1.low "& & & & \\ \textbf{Panel D: OLS, re-weighted}", nolabel)  ///
	coeflabel(1.low "Null result treatment") order(`outcomes') 					
