* Setup paths
clear 
do setup.do


* Load data for all experiments
use "${data_folder}/main_study_cleaned.dta", clear 


* ------- TABLE: SUMMARY STATISTICS FOR EACH WAVE ------

replace duration = . if order>1 

winsor duration, gen(durationw) p(0.05) highonly
winsor pagetime, gen(pagetimew) p(0.05) highonly

eststo clear 
local variables duration durationw pagetime pagetimew 
 
eststo: estpost su `variables',detail 

***************************************************
**** Step 3: Write out to table *******************
***************************************************

esttab  using "${table_folder}/table_A10.tex", replace  cells("count p25 p50 p75 min(fmt(1 1 1 1)) max(fmt(1 1 1 1)) mean(fmt(1 1 1 1)) sd(fmt(1 1 1 1))")   ///
    coeflabel(duration "Duration in seconds" durationw "Duration (winsorized)" pagetime "Page time (in seconds)" pagetimew "Page time (winsorized)") nonumber nomtitle noobs booktabs f
