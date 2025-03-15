* Setup paths
clear 
do setup.do

* Load data for all experiments
use "${data_folder}/main_study_cleaned.dta", clear 


* use pagetime, not duration.
winsor2 pagetime, cuts(5 95) suffix(_w)


label define vignette_lab 1 "Equal sharing (80 extra words)" 2 "Female empowerment" 3 "Financial literacy (35 extra words)" 4 "Merit aid (1 extra word)" 5 "Salience of poverty (22 extra words)", replace
label values vignette vignette_lab

* analysis
eststo clear
eststo: reg pagetime ib2.vignette, vce(cluster id)
eststo: reg pagetime i.($treatments) ib2.vignette, vce(cluster id)
eststo: reg pagetime_w ib2.vignette, vce(cluster id)
eststo: reg pagetime_w i.($treatments) ib2.vignette, vce(cluster id)

estadd ysumm : _all

* export table
esttab * using "${table_folder}/table_A11.tex", replace  se f b(3)coeflabel(1.low "Null result treatment" 1.exhigh "High expert forecast (43 extra words)" 1.exlow "Low expert forecast (43 extra words)")    keep(1.vignette 3.vignette 5.vignette 4.vignette 1.low 1.exlow 1.exhigh 1.field 1.phd 1.unilow) order(1.vignette 3.vignette 5.vignette 4.vignette 1.low 1.exlow 1.exhigh 1.field 1.phd 1.unilow )   label  stats(N N_clust ymean, labels("Observations" "Respondents" "Dep. var. mean") fmt(%9.0fc a3 %9.3fc))   starlevels( * 0.10 ** 0.05 *** 0.01)    mgroups("Non-winsorized" "Winsorized", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) nomtitles gaps nobase noomitted prehead("&\multicolumn{@M}{c}{Dependent variable: Page time (in seconds)}\\\cmidrule(lr){2-@span}")
