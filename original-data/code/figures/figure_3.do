* Setup paths
clear 
do setup.do


* Load data for all experiments
use "${data_folder}/main_study_cleaned.dta", clear 


* ------------------------------ Figure ------------------------------

rename speciality* *					 										
					
* Run regression 
					
eststo clear 
foreach x of varlist labor public development political finance experimental behavioral theory macro econometrics {
eststo publish_`x': qui reghdfe publish i.low i.($crosstreatments) if `x'==1, absorb(id) vce(cluster id)
eststo qualityfob_`x': qui reghdfe qualityfob i.low i.($crosstreatments) if `x'==1, absorb(id) vce(cluster id)
eststo importancefob_`x': qui reghdfe importancefob i.low i.($crosstreatments) if `x'==1, absorb(id) vce(cluster id)
}				
 
coefplot (publish_*,nokey symbol(circle))      || (qualityfob_*,label("Quality") symbol(circle))    (importancefob_*,label("Importance") symbol(circle_hollow))       || , keep(1.low) aseq swapnames      bylabels("Publishability" "Private beliefs") subtitle(, size(medsmall))           eqlabels(, asheading) eqrename(publish_* = "" qualityfob_* = "" importancefob_* = "") xline(0) norecycle   
		   
* Export			   
graph export "${figure_folder}/figure_3.pdf", replace
