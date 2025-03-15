* Setup paths
clear 
do setup.do


* Load data for all experiments
use "${data_folder}/main_study_cleaned.dta", clear 

* ------------------------------ Figure ------------------------------

* run figures 

foreach var of varlist publish qualityfob qualitysob importancefob importancesob {
qui reghdfe `var' i.low##i.vignette i.($crosstreatments), absorb(id) vce(cluster id)
eststo `var': margins, dydx(low) at(vignette = (1(1)5)) post
}

coefplot (publish,label("Publishability") symbol(circle)) (qualityfob,label("Quality: FOB") symbol(diamond)) (qualitysob,label("Quality: SOB") symbol(square)) (importancefob,label("Importance: FOB") symbol(diamond)) (importancesob,label("Importance: SOB") symbol(X)) , legend(row(1) pos(6)) ciopts(recast(rcap)) vertical yline(0) ytitle("Treatment effect") ylab(,gmin gmax) coeflabels(1._at = "Equal sharing" 2._at = "Female empowerment" 3._at = "Financial literacy" 4._at = "Merit aid" 5._at = "Salience of poverty") ylab(-20(5)5)

graph export "${figure_folder}/figure_A2.pdf", replace
