* Setup paths
clear 
do setup.do

* Load data for all experiments
use "${data_folder}/main_study_cleaned.dta", clear 

* ------------------------------ Figure ------------------------------

eststo clear 

foreach x of varlist male phdstudent evereditor highcite anytop5 {
* First-order beliefs 
eststo qualityfob_`x'1: qui reghdfe qualityfob i.low i.($crosstreatments) if `x'==1, absorb(id) vce(cluster id)
eststo importancefob_`x'1: qui reghdfe importancefob i.low i.($crosstreatments) if `x'==1, absorb(id) vce(cluster id)
eststo qualityfob_`x'0: qui reghdfe qualityfob i.low i.($crosstreatments) if `x'==0, absorb(id) vce(cluster id)
eststo importancefob_`x'0: qui reghdfe importancefob i.low i.($crosstreatments) if `x'==0, absorb(id) vce(cluster id)

* Second-order beliefs 
eststo qualitysob_`x'1: qui reghdfe qualitysob i.low i.($crosstreatments) if `x'==1, absorb(id) vce(cluster id)
eststo importancesob_`x'1: qui reghdfe importancesob i.low i.($crosstreatments) if `x'==1, absorb(id) vce(cluster id)
eststo qualitysob_`x'0: qui reghdfe qualitysob i.low i.($crosstreatments) if `x'==0, absorb(id) vce(cluster id)
eststo importancesob_`x'0: qui reghdfe importancesob i.low i.($crosstreatments) if `x'==0, absorb(id) vce(cluster id)
}		

coefplot  (qualityfob_*,symbol(circle)) ///  ///
	   (qualitysob_*,symbol(circle_hollow))  ///
	   ///
      || (importancefob_*,symbol(circle)) ///
	   (importancesob_*,symbol(circle_hollow))  ///
      , keep(1.low) aseq swapnames ///
	    eqlabels(, asheading) eqrename(importancesob_* = "" qualitysob_* = "" qualityfob_* = "" importancefob_* = "")  xline(0) norecycle ///
		    groups(phdstudent? = "{bf: PhD student}" ///
		male? = "{bf: Gender}" evereditor? = "{bf: Editor}" anytop5? = "{bf: Top five}" highcite? = "{bf: Citations}")  ///
		coeflabels(phdstudent0 = "No" phdstudent1 = "Yes" ///
		male0 = "Female" male1 = "Male" ///
		evereditor0 = "No" evereditor1 = "Yes" ///
		anytop50 = "No" anytop51 = "Yes" ///
		highcite0 = "Low" highcite1 = "High",labsize(small)) xlab(-20(5)5)  bylabels("Quality" "Importance") subtitle(, size(medsmall)) byopts(legend(off))

												
addplot 1: , legend(order(2 "Own" 4 "Other") (position(6)) on) norescaling
addplot 2: , legend(order(6 "Own" 8 "Other") (position(6)) on) norescaling
												
graph export "${figure_folder}/figure_A1.pdf", replace
												

															


