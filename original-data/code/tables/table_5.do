* Setup paths
clear 
do setup.do

* Load data for all experiments
use "${data_folder}/mechanism_study_cleaned.dta", clear 

***************************************************
************ Create the table *********************
***************************************************

eststo clear 

local outcomes publish z_precision 

local table table_5.tex

rename professor phd

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
	mtitle("Publishability (in percent)" "Precision (z-scored)") ///
	refcat(1.low "& & \\ \textbf{Panel A: Individual fixed effects}", nolabel) 	

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
	refcat(1.low "& & \\ \textbf{Panel B: No individual FE}", nolabel)  ///
	coeflabel(1.low "Null result treatment") order(`outcomes') 					