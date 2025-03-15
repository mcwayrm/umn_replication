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


* Panel A: Expert forecast 
foreach var of varlist `outcomes' { 
	eststo `var': reghdfe `var' i.low##i.(exlow exhigh) $treatments,  absorb(id vignette) vce(cluster id)
}

esttab * using "${table_folder}/table_4.tex", replace  se  f b(3)  coeflabel(1.low "\addlinespace[1ex] Null result treatment")  keep(1.low 1.exlow 1.exhigh 1.low#1.exlow 1.low#1.exhigh) label  starlevels( * 0.10 ** 0.05 *** 0.01)    mgroups("Publishability" "Quality (z-scored)" "Importance (z-scored)", pattern(1 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))   mtitle("\shortstack{Beliefs\\in percent}" "\shortstack{First-order\\beliefs}" "\shortstack{Second-order\\beliefs}" "\shortstack{First-order\\beliefs}" "\shortstack{Second-order\\beliefs}")   refcat(1.low "& & & & \\ \textbf{Panel A}: Expert forecast", nolabel) noobs nogaps compress order(1.low 1.low#1.exlow 1.low#1.exhigh 1.exlow 1.exhigh)

* Panel B: Field journal 
foreach var of varlist `outcomes' { 
	eststo `var': reghdfe `var' i.low##i.(field) $treatments,  absorb(id vignette) vce(cluster id)
}

esttab * using "${table_folder}/table_4.tex", append  se  f b(3)  coeflabel(1.low "\addlinespace[1ex] Null result treatment")  keep(1.low 1.field 1.low#1.field) label  starlevels( * 0.10 ** 0.05 *** 0.01) refcat(1.low "& & & & \\ \textbf{Panel B}: Field journal", nolabel) collabels(none) nonumber nomtitles noobs nogaps compress order(1.low 1.low#1.field 1.field)


* Panel C: PhD student 
foreach var of varlist `outcomes' { 
	eststo `var': reghdfe `var' i.low##i.(phd) $treatments,  absorb(id vignette) vce(cluster id)
}

esttab * using "${table_folder}/table_4.tex", append  se  f b(3)  coeflabel(1.low "\addlinespace[1ex] Null result treatment")  keep(1.low 1.phd 1.low#1.phd) label  starlevels( * 0.10 ** 0.05 *** 0.01) refcat(1.low "& & & & \\ \textbf{Panel C}: PhD student", nolabel) collabels(none) nonumber nomtitles noobs nogaps compress order(1.low 1.low#1.phd 1.phd)

* Panel D: Low-ranked 
foreach var of varlist `outcomes' { 
	eststo `var': reghdfe `var' i.low##i.(unilow) $treatments,  absorb(id vignette) vce(cluster id)
}

esttab * using "${table_folder}/table_4.tex", append  se  f b(3)  coeflabel(1.low "\addlinespace[1ex] Null result treatment")  keep(1.low 1.unilow 1.low#1.unilow) label  starlevels( * 0.10 ** 0.05 *** 0.01) refcat(1.low "& & & & \\ \textbf{Panel D}: Low-ranked universiy", nolabel) collabels(none) nonumber nomtitles noobs nogaps compress order(1.low 1.low#1.unilow 1.unilow)

* Panel E: P-value framing without individual FEs
foreach var of varlist `outcomes' { 
	eststo `var': reghdfe `var' i.low##i.(pval) $treatments,  absorb(vignette) vce(cluster id)
}
esttab * using "${table_folder}/table_4.tex", append  se  f b(3)  coeflabel(1.low "\addlinespace[1ex] Null result treatment")  keep(1.low 1.pval 1.low#1.pval) label  starlevels( * 0.10 ** 0.05 *** 0.01) refcat(1.low "& & & & \\ \textbf{Panel E}: P-value framing", nolabel) collabels(none) nonumber nomtitles stats(N N_clust, labels("Observations" "Respondents") fmt(%9.0fc a3)) nogaps compress order(1.low 1.low#1.pval 1.pval)
