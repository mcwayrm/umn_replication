* Setup paths
clear 
do setup.do


* Load data for all experiments
use "$data_folder/main_study_cleaned.dta", clear 


***************************************************
************ Create the table *********************
***************************************************

eststo clear 


local outcomes publish z_qualityfob z_qualitysob z_importancefob z_importancesob

local table table_A12.tex

***************************************************************
********* Panel A: Fixed effect  ******************************
***************************************************************


eststo clear
foreach var of varlist `outcomes' { 
	qui eststo `var': reghdfe `var' i.($treatments) if duration >=4*60,  absorb(vignette id) vce(cluster id)
}

esttab * using "$table_folder/`table'", replace  se f b(3) keep (1.low) coeflabel(1.low "Null result treatment")  label noobs  starlevels( * 0.10 ** 0.05 *** 0.01) mgroups("Publishability" "Quality (z-scored)" "Importance (z-scored)", pattern(1 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("\shortstack{Beliefs\\in percent}" "\shortstack{First-order\\beliefs}" "\shortstack{Second-order\\beliefs}" "\shortstack{First-order\\beliefs}" "\shortstack{Second-order\\beliefs}") stats(N N_clust, labels("Observations" "Respondents") fmt(%9.0fc a3)) refcat(1.low "& & & & & \\ \textbf{Panel A:} 4+ minutes", nolabel)


eststo clear
foreach var of varlist `outcomes' { 
	qui eststo `var': reghdfe `var' i.($treatments) if duration >=6*60,  absorb(vignette id) vce(cluster id)
}

esttab * using "$table_folder/`table'", append se f b(3) keep (1.low) coeflabel(1.low "Null result treatment")  label noobs  starlevels( * 0.10 ** 0.05 *** 0.01) nomtitles stats(N N_clust, labels("Observations" "Respondents") fmt(%9.0fc a3)) refcat(1.low "& & & & & \\ \textbf{Panel B:} 6+ minutes", nolabel)  collabels(none) nonumber


eststo clear
foreach var of varlist `outcomes' { 
	qui eststo `var': reghdfe `var' i.($treatments) if duration >=8*60,  absorb(vignette id) vce(cluster id)
}

esttab * using "$table_folder/`table'", append se f b(3) keep (1.low) coeflabel(1.low "Null result treatment")  label noobs  starlevels( * 0.10 ** 0.05 *** 0.01) nomtitles stats(N N_clust, labels("Observations" "Respondents") fmt(%9.0fc a3)) refcat(1.low "& & & & & \\ \textbf{Panel C:} 8+ minutes", nolabel)  collabels(none) nonumber


eststo clear
foreach var of varlist `outcomes' { 
	qui eststo `var': reghdfe `var' i.($treatments) if duration >=10*60,  absorb(vignette id) vce(cluster id)
}

esttab * using "$table_folder/`table'", append se f b(3) keep (1.low) coeflabel(1.low "Null result treatment")  label noobs  starlevels( * 0.10 ** 0.05 *** 0.01) nomtitles stats(N N_clust, labels("Observations" "Respondents") fmt(%9.0fc a3)) refcat(1.low "& & & & & \\ \textbf{Panel D:} 10+ minutes", nolabel)  collabels(none) nonumber
