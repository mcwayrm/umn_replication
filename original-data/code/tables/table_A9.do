* Setup paths
clear 
do setup.do


* Load data for all experiments
use "${data_folder}/main_study_cleaned.dta", clear 


***************************************************
************ Preparations    *********************
***************************************************

gen speciality_matches_vignettes = 0

* 1 = equsha, 2 = fememp, 3 = finlit, 4 = meraid, 5 = salpov
replace speciality_matches_vignettes = 1 if vignette == 1 & (specialitypublic == 1 | specialitylabor == 1 | specialitydevelopment == 1)
replace speciality_matches_vignettes = 1 if vignette == 2 & (specialitydevelopment == 1 | specialitylabor == 1)
replace speciality_matches_vignettes = 1 if vignette == 3 & (specialityfinance  == 1 | specialityeducation == 1 | specialitydevelopment == 1 | specialitylabor == 1)
replace speciality_matches_vignettes = 1 if vignette == 4 & (specialitypublic == 1 | specialityeducation == 1 | specialitylabor==1)
replace speciality_matches_vignettes = 1 if vignette == 5 & (specialityexperimental == 1 | specialitydevelopment == 1)

egen any_field_vignette_match = max(speciality_matches_vignettes), by(id)
 
***************************************************
************ Create the table *********************
***************************************************

local table table_A9.tex
local outcomes publish z_qualityfob z_qualitysob z_importancefob z_importancesob


* Panel A
eststo clear 
foreach var of varlist `outcomes' { 
	qui eststo `var': reghdfe `var' i.($treatments) i.low##i.speciality_matches_vignettes,  absorb(id vignette) vce(cluster id)
}

esttab * using "${table_folder}/`table'", replace  se f b(3) starlevels( * 0.10 ** 0.05 *** 0.01) coeflabel(1.low "Null result treatment" 1.low#1.speciality_matches_vignettes "Null result treatment x Matching field" 1.speciality_matches_vignettes "Matching field")  keep(1.low 1.low#1.speciality_matches_vignettes 1.speciality_matches_vignettes)  varwidth(40) mgroups("Publishability" "Quality (z-scored)" "Importance (z-scored)", pattern(1 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("\shortstack{Beliefs\\in percent}" "\shortstack{First-order\\beliefs}" "\shortstack{Second-order\\beliefs}" "\shortstack{First-order\\beliefs}" "\shortstack{Second-order\\beliefs}")  refcat(1.low "& & & & \\ \textbf{Panel A}", nolabel) stats(N N_clust, labels("Observations" "Respondents") fmt(%9.0fc a3))

* Panel B
eststo clear 
foreach var of varlist `outcomes' { 
	qui eststo `var': reghdfe `var' i.($treatments) if !any_field_vignette_match,  absorb(id vignette) vce(cluster id)
}

esttab * using "${table_folder}/`table'", append se keep(1.low) nomtitles f b(3) gaps collabels(none) nonumber stats(N N_clust, labels("Observations" "Respondents") fmt(%9.0fc a3)) starlevels( * 0.1 ** 0.05 *** 0.01)   refcat(1.low "& & & & \\ \textbf{Panel B: Non-matching fields}", nolabel)  coeflabel(1.low "Null result treatment") order(`outcomes') 					


* Panel C
eststo clear 
foreach var of varlist `outcomes' { 
	qui eststo `var': reghdfe `var' i.($treatments) if speciality_matches_vignettes==1,  absorb(id vignette) vce(cluster id)
}

esttab * using "${table_folder}/`table'", append se keep(1.low) nomtitles f b(3) gaps collabels(none) nonumber stats(N N_clust, labels("Observations" "Respondents") fmt(%9.0fc a3)) starlevels( * 0.1 ** 0.05 *** 0.01)   refcat(1.low "& & & & \\ \textbf{Panel C: Matching fields}", nolabel)  coeflabel(1.low "Null result treatment") order(`outcomes') 					
