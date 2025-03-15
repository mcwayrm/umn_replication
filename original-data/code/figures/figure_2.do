* Setup paths
clear 
do setup.do

* Load data for all experiments
use "${data_folder}/main_study_cleaned.dta", clear 

* ------------------------------ Figure ------------------------------

eststo clear 

foreach x of varlist male phdstudent evereditor highcite anytop5 {
eststo publish_`x'1: qui reghdfe publish i.low i.($crosstreatments) if `x'==1, absorb(id) vce(cluster id)
eststo qualityfob_`x'1: qui reghdfe qualityfob i.low i.($crosstreatments) if `x'==1, absorb(id) vce(cluster id)
eststo importancefob_`x'1: qui reghdfe importancefob i.low i.($crosstreatments) if `x'==1, absorb(id) vce(cluster id)
eststo publish_`x'0: qui reghdfe publish i.low i.($crosstreatments) if `x'==0, absorb(id) vce(cluster id)
eststo qualityfob_`x'0: qui reghdfe qualityfob i.low i.($crosstreatments) if `x'==0, absorb(id) vce(cluster id)
eststo importancefob_`x'0: qui reghdfe importancefob i.low i.($crosstreatments) if `x'==0, absorb(id) vce(cluster id)
}		

		   
coefplot (publish_*,nokey symbol(circle)) ///
      || (qualityfob_*,label("Quality") symbol(circle)) ///
	   (importancefob_*,label("Importance") symbol(circle_hollow))  ///
      || , keep(1.low) aseq swapnames ///
	    eqlabels(, asheading) eqrename(publish_* = "" qualityfob_* = "" importancefob_* = "") xline(0) norecycle ///
		    groups(phdstudent? = "{bf: PhD student}" ///
		male? = "{bf: Gender}" evereditor? = "{bf: Editor}" anytop5? = "{bf: Top five}" highcite? = "{bf: Citations}")  ///
		coeflabels(phdstudent0 = "No" phdstudent1 = "Yes" ///
		male0 = "Female" male1 = "Male" ///
		evereditor0 = "No" evereditor1 = "Yes" ///
		anytop50 = "No" anytop51 = "Yes" ///
		highcite0 = "Low" highcite1 = "High",labsize(small)) xlab(-20(5)5)  bylabels("Publishability" "Private beliefs") subtitle(, size(medsmall)) 

graph export "${figure_folder}/figure_2.pdf", replace
