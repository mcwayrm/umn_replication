* Setup paths
clear 
do setup.do

*****************************************************************
**** Ex-post MDE for publishability at 80 percent power      ****
*****************************************************************

* Load data for all experiments
use "${data_folder}/main_study_cleaned.dta", clear 

local outcome publish
reghdfe `outcome' i.($treatments),  absorb(id vignette) vce(cluster id)


* Define the bootstrap program that perform the main analysis.
capture program drop main_analysis
program main_analysis, rclass

	* estimate main regression
	reghdfe publish i.($treatments),  absorb(id vignette) vce(cluster id)

	* p-value of the main effect
	local t = _b[1.low]/_se[1.low]
	local p =2*ttail(e(df_r),abs(`t'))

    return scalar significant = `p' < 0.05
	end

* Counterfactual effect size D across null and non-null treatment arm
local effect_size = 3.98
local mean_difference = 14.058
replace `outcome' = `outcome' + `mean_difference' - `effect_size' if low & !missing(`outcome')

* Perform bootstrap and export statistics
bootstrap significant=r(significant),  seed(3322) cluster(id) size(480) saving("${out_folder}/data/power.dta", replace) reps(1001): main_analysis

* Calculate the share of significant results for the given, counterfactual effect size D
preserve
qui use "${out_folder}/data/power.dta", clear
qui summ significant
qui local power = r(mean)
restore

* Effect size in standard deviations of the control group
qui summ `outcome' if !low, de
di `effect_size' / r(sd)

* Ex-post power for an effect size of D
di "Percent of significant results = `power'"


*****************************************************************
**** Ex-post MDE for qualityfob at 80 percent power      ****
*****************************************************************

* Define the bootstrap program that perform the main analysis.
capture program drop main_analysis
program main_analysis, rclass

	* estimate main regression
	reghdfe qualityfob i.($treatments),  absorb(id vignette) vce(cluster id)

	* p-value of the main effect
	local t = _b[1.low]/_se[1.low]
	local p =2*ttail(e(df_r),abs(`t'))

    return scalar significant = `p' < 0.05
	end

* Load data for all experiments
use "${data_folder}/main_study_cleaned.dta", clear 

local outcome qualityfob 
reghdfe `outcome' i.($treatments),  absorb(id vignette) vce(cluster id)

* Counterfactual effect size D across null and non-null treatment arm
local effect_size = 4.49
local mean_difference = 7.475
replace `outcome' = `outcome' + `mean_difference' - `effect_size' if low & !missing(`outcome')

* Perform bootstrap and export statistics
bootstrap significant=r(significant),  seed(3322) cluster(id) size(230) saving("${out_folder}/data/power.dta", replace) reps(1001): main_analysis

* Calculate the share of significant results for the given, counterfactual effect size D
preserve
qui use "${out_folder}/data/power.dta", clear
qui summ significant
qui local power = r(mean)
restore

* Effect size in standard deviations of the control group
qui summ `outcome' if low, de
di `effect_size' / r(sd)

* Ex-post power for an effect size of D
di "Percent of significant results = `power'"


*****************************************************************
**** Ex-post MDE for importancefob at 80 percent power      ****
*****************************************************************

* Define the bootstrap program that perform the main analysis.
capture program drop main_analysis
program main_analysis, rclass

	* estimate main regression
	reghdfe importancefob i.($treatments),  absorb(id vignette) vce(cluster id)

	* p-value of the main effect
	local t = _b[1.low]/_se[1.low]
	local p =2*ttail(e(df_r),abs(`t'))

    return scalar significant = `p' < 0.05
	end

* Load data for all experiments
use "${data_folder}/main_study_cleaned.dta", clear 

local outcome importancefob 
reghdfe `outcome' i.($treatments),  absorb(id vignette) vce(cluster id)

* Counterfactual effect size D across null and non-null treatment arm
local effect_size = 4.95
local mean_difference = 8.115
replace `outcome' = `outcome' + `mean_difference' - `effect_size' if low & !missing(`outcome')

* Perform bootstrap and export statistics
bootstrap significant=r(significant),  seed(3322) cluster(id) size(230) saving("${out_folder}/data/power.dta", replace) reps(1001): main_analysis

* Calculate the share of significant results for the given, counterfactual effect size D
preserve
qui use "${out_folder}/data/power.dta", clear
qui summ significant
qui local power = r(mean)
restore

* Effect size in standard deviations of the control group
qui summ `outcome' if low, de
di `effect_size' / r(sd)

* Ex-post power for an effect size of D
di "Percent of significant results = `power'"
