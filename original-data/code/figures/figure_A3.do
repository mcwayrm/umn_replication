* Setup paths
clear 
do setup.do


* Load data for all experiments
use "${data_folder}/main_study_cleaned.dta", clear 


label define vignette_lab 1 "Equal sharing" 2 "Female empowerment" 3 "Financial literacy" 4 "Merit aid" 5 "Salience of poverty", replace
label values vignette vignette_lab

* ------------------------------ Figure ------------------------------

graph bar (median) pagetime, over(vignette, label(angle(45) labsize(medium))) by(pval,note("")) ytitle("Median time spent on vignette")  ylab(, labsize(medium))

graph export "${figure_folder}/figure_A3.pdf", replace			
