* Setup paths
clear 
ssc install rwolf2
* Load data for all experiments

use "${data_folder}/main_study_cleaned.dta", clear 

***************************************************
************ Create the table *********************
***************************************************

global treatments low exlow exhigh field phd unilow pval


* renaming because we otherwise run into naming problems
rename z_importancefob z_impfob
rename z_importancesob z_impsob
local outcomes publish z_qualityfob z_qualitysob z_impfob z_impsob


eststo clear 
foreach var in `outcomes' {
	eststo `var': reghdfe `var' i.low##i.($treatments),  absorb(id vignette) vce(cluster id)
}

esttab * , se b(3) starlevels(* 0.1 ** 0.05 *** 0.01) keep(1.low 1.low#1.exlow 1.low#1.exhigh 1.low#1.field 1.low#1.phd  1.low#1.unilow 1.low#1.pval) order(1.low 1.low#1.exlow 1.low#1.exhigh 1.low#1.field 1.low#1.phd  1.low#1.unilow 1.low#1.pval)

*MHT adjusted p-values
*storing the value of 1.m#1.n as rwolf2 generates an error. 
 
gen low_est= 1.low
gen low_low_expert= 1.low#1.exlow
gen low_high_expert= 1.low#1.exhigh 
gen low_field = 1.low#1.field 
gen low_phd= 1.low#1.phd  
gen low_unilow= 1.low#1.unilow 
gen low_pval= 1.low#1.pval

************************************************************************************
*************** DEFINE REGRESSORS AND SUBSET OF REGRESSORS FOR MHT   ***************
***************************************************************************+********
local regressors low_est low_low_expert low_high_expert low_field low_phd low_unilow low_pval exlow exhigh field phd unilow
local indepvars_mht low_est low_low_expert low_high_expert low_field low_phd low_unilow low_pval

la var low_est "Null result"
la var low_low_expert "Null result x Low expert forecast"
la var low_high_expert "Null result x High expert forecast"
la var low_field "Null result x Field journal"
la var low_phd "Null result x PhD student"
la var low_unilow "Null result x Low-ranked university"
la var low_pval "Null result x P-value framing"
la var exlow "Low expert forecast"
la var exhigh "High expert forecast"
la var field "Field journal"
la var phd "PhD student"
la var unilow "Low-ranked university"
la var pval "P-value framing"


* Perform MHT adjustment usin the rwolf2 package

rwolf2 (reghdfe publish `regressors' , absorb(id vignette) cluster(id)) (reghdfe  z_qualityfob  `regressors' , absorb(id vignette) cluster(id)) (reghdfe  z_qualitysob `regressors' , absorb(id vignette) cluster(id)) (reghdfe z_impfob `regressors' , absorb(id vignette) cluster(id))  (reghdfe z_impsob `regressors' , absorb(id vignette) cluster(id)) , indepvars(`indepvars_mht' , `indepvars_mht', `indepvars_mht', `indepvars_mht' , `indepvars_mht') reps(1000)  cluster (id) seed(2) usevalid

* Store the output from the rwolf2 command in a matrix. The third column
* contains the adjusted p-values.
matrix pvalmht = e(RW)
matrix list pvalmht

* We now have to reshape the data to match the shape of the regression table
* for which we want to add the data reshape for the table

* This is the number of overall regressors (including those for which we do not perform
* an MHT adjustment). Simply count the number of non-absorbed regressors in your reg command.
local I : word count `indepvars_mht'

* This is the number of specifications (e.g. separate regressions we are running)
local J: word count `outcomes'

* Number of regressors that are not adjusted for MHT (including _cons).
local K 6

* Create a new matrix
matrix matrix_pvals = J(`J', `I' + `K', .)

forval j = 1/`J'  {
	forval i = 1/`I' {
		* Add the correct number from the original matrix, round to 3 digits.
	    matrix matrix_pvals[`j', `i'] = round(pvalmht[`i' + (`j'-1) *`I', 3], 0.001)
	}
}
* Label the rows and columns such that it matches the names in the regression output
mat colnames matrix_pvals = `regressors' _cons
mat rownames matrix_pvals = `outcomes'

* Inspect the final result. Does it look good? :)
matrix list matrix_pvals

**************************************************
*************** CREATE THE TABLE   ***************
**************************************************

* run original regression and add the p-value data
eststo clear
local i = 0
foreach var in `outcomes' {
	local i = `i' + 1
	eststo `var': reghdfe `var' `regressors',  absorb(id vignette) vce(cluster id)
	matrix pvals_new = matrix_pvals[`i', 1...]
	estadd matrix pvals_new
}


esttab * using "${table_folder}/table_A8.tex",  replace cells(b(fmt(3) star) se(fmt(3) par) pvals_new(fmt(3) par("[" "]") star pvalue(pvals_new))) starlevel(* 0.1 ** 0.05 *** 0.01) drop(_cons)nobase noomitted stats(N N_clust, label("N" "Respondents") fmt(%9.0fc)) label refcat(low_est "& & & & \\ \textbf{Main treatment}:"  low_low_expert  "\textbf{Interaction effects}:" exlow "\textbf{Interactants}:", nolabel) mgroups("Publishability" "Quality (z-scored)" "Importance (z-scored)", pattern(1 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("\shortstack{Beliefs\\in percent}" "\shortstack{First-order\\beliefs}" "\shortstack{Second-order\\beliefs}" "\shortstack{First-order\\beliefs}" "\shortstack{Second-order\\beliefs}") collabels(none) booktabs fragment gaps sub("                    &         [.]   &         [.]   &         [.]   &         [.]   &         [.]   \\" "")



*******************************************************************************
*************** ALTERNATIVE EXHIBIT WITH SEPRATE INTERACTIONS   ***************
*******************************************************************************


************************************************************************************
*************** DEFINE REGRESSORS AND SUBSET OF REGRESSORS FOR MHT   ***************
***************************************************************************+********
local regressors low_est low_low_expert low_high_expert low_field low_phd low_unilow low_pval exlow exhigh field phd unilow

local indepvars_mht low_est low_low_expert low_high_expert low_field low_phd low_unilow low_pval

la var low_est "Null result"
la var low_low_expert "Null result x Low expert forecast"
la var low_high_expert "Null result x High expert forecast"
la var low_field "Null result x Field journal"
la var low_phd "Null result x PhD student"
la var low_unilow "Null result x Lower-ranked university"
la var low_pval "Null result x P-value framing"
la var exlow "Low expert forecast"
la var exhigh "High expert forecast"
la var field "Field journal"
la var phd "PhD student"
la var unilow "Low-ranked university"
la var pval "P-value framing"
 
local controls exlow exhigh field phd unilow pval

* Perform MHT adjustment usin the rwolf2 package
rwolf2 (reghdfe publish low_est low_low_expert low_high_expert `controls' , absorb(id vignette) cluster(id)) (reghdfe publish low_est low_field `controls' , absorb(id vignette) cluster(id)) (reghdfe publish low_est low_phd `controls' , absorb(id vignette) cluster(id)) (reghdfe publish low_est low_unilow `controls' , absorb(id vignette) cluster(id)) (reghdfe publish low_est low_pval `controls' , absorb(vignette) cluster(id)) (reghdfe z_qualityfob low_est low_low_expert low_high_expert `controls' , absorb(id vignette) cluster(id)) (reghdfe z_qualityfob low_est low_field `controls' , absorb(id vignette) cluster(id)) (reghdfe z_qualityfob low_est low_phd `controls' , absorb(id vignette) cluster(id)) (reghdfe z_qualityfob low_est low_unilow `controls' , absorb(id vignette) cluster(id)) (reghdfe z_qualityfob low_est low_pval `controls' , absorb(vignette) cluster(id)) (reghdfe z_qualitysob low_est low_low_expert low_high_expert `controls' , absorb(id vignette) cluster(id)) (reghdfe z_qualitysob low_est low_field `controls' , absorb(id vignette) cluster(id)) (reghdfe z_qualitysob low_est low_phd `controls' , absorb(id vignette) cluster(id)) (reghdfe z_qualitysob low_est low_unilow `controls' , absorb(id vignette) cluster(id)) (reghdfe z_qualitysob low_est low_pval `controls' , absorb(vignette) cluster(id)) (reghdfe z_impfob low_est low_low_expert low_high_expert `controls' , absorb(id vignette) cluster(id)) (reghdfe z_impfob low_est low_field `controls' , absorb(id vignette) cluster(id)) (reghdfe z_impfob low_est low_phd `controls' , absorb(id vignette) cluster(id)) (reghdfe z_impfob low_est low_unilow `controls' , absorb(id vignette) cluster(id)) (reghdfe z_impfob low_est low_pval `controls' , absorb(vignette) cluster(id)) (reghdfe z_impsob low_est low_low_expert low_high_expert `controls' , absorb(id vignette) cluster(id)) (reghdfe z_impsob low_est low_field `controls' , absorb(id vignette) cluster(id)) (reghdfe z_impsob low_est low_phd `controls' , absorb(id vignette) cluster(id)) (reghdfe z_impsob low_est low_unilow `controls' , absorb(id vignette) cluster(id)) (reghdfe z_impsob low_est low_pval `controls' , absorb(vignette) cluster(id)),               indepvars(low_est low_low_expert low_high_expert, low_est low_field, low_est low_phd, low_est low_unilow, low_est low_pval, low_est low_low_expert low_high_expert, low_est low_field, low_est low_phd, low_est low_unilow, low_est low_pval, low_est low_low_expert low_high_expert, low_est low_field, low_est low_phd, low_est low_unilow, low_est low_pval, low_est low_low_expert low_high_expert, low_est low_field, low_est low_phd, low_est low_unilow, low_est low_pval, low_est low_low_expert low_high_expert, low_est low_field, low_est low_phd, low_est low_unilow, low_est low_pval)     reps(1000) cluster(id) seed(2) usevalid

matrix pvalmht = e(RW)
matrix list pvalmht


* We now have to reshape the data to match the shape of the regression table
* for which we want to add the data reshape for the table

* K = number of outcomes; I = cycle length at which same regressor appears across outcomes stacked together in the matrix (=number of regressors for which we do MHT *per outcome in total*)
local K = 5
local I = 11

* Panel A: 5 regressions for 5 different outcomes with exhigh/exlow interactions
matrix matrix_pvals_A = J(`K', 3 + 6 , .)
forval j = 1/`K'  {
	forval i = 1/3 {
		* Add the correct number from the original matrix, round to 3 digits.
	    matrix matrix_pvals_A[`j', `i'] = round(pvalmht[`i' + (`j'-1) *`I', 3], 0.001)
	}
}
mat colnames matrix_pvals_A = low_est low_low_expert low_high_expert exlow exhigh field phd unilow _cons
mat rownames matrix_pvals_A = `outcomes'
matrix list matrix_pvals_A

* Panel B: 5 regressions for 5 different outcomes with field interactions
matrix matrix_pvals_B = J(`K', 2 + 6 , .)
forval j = 1/`K'  {
	forval i = 1/2 {
		* Add the correct number from the original matrix, round to 3 digits.
		* Add "3" to account for the fact that panel A has three coefficients already taken care of.
	    matrix matrix_pvals_B[`j', `i'] = round(pvalmht[3 + `i' + (`j'-1) *`I', 3], 0.001)
	}
}
mat colnames matrix_pvals_B = low_est low_field exlow exhigh field phd unilow _cons
mat rownames matrix_pvals_B = `outcomes'
matrix list matrix_pvals_B

* Panel C: 5 regressions for 5 different outcomes with phd interactions
matrix matrix_pvals_C = J(`K', 2 + 6 , .)
forval j = 1/`K'  {
	forval i = 1/2 {
		* Add the correct number from the original matrix, round to 3 digits.
	    matrix matrix_pvals_C[`j', `i'] = round(pvalmht[3 + 2 + `i' + (`j'-1) *`I', 3], 0.001)
	}
}
mat colnames matrix_pvals_C = low_est low_phd exlow exhigh field phd unilow _cons
mat rownames matrix_pvals_C = `outcomes'
matrix list matrix_pvals_C

* Panel D: 5 regressions for 5 different outcomes with unilow interactions
matrix matrix_pvals_D = J(`K', 2 + 6 , .)
forval j = 1/`K'  {
	forval i = 1/2 {
		* Add the correct number from the original matrix, round to 3 digits.
	    matrix matrix_pvals_D[`j', `i'] = round(pvalmht[3 + 2 + 2 + `i' + (`j'-1) *`I', 3], 0.001)
	}
}
mat colnames matrix_pvals_D = low_est low_unilow exlow exhigh field phd unilow _cons
mat rownames matrix_pvals_D = `outcomes'
matrix list matrix_pvals_D


* Panel D: 5 regressions for 5 different outcomes with pval interactions
matrix matrix_pvals_E = J(`K', 2 + 6 , .)
forval j = 1/`K'  {
	forval i = 1/2 {
		* Add the correct number from the original matrix, round to 3 digits.
	    matrix matrix_pvals_E[`j', `i'] = round(pvalmht[3 + 2 + 2 + 2 + `i' + (`j'-1) *`I', 3], 0.001)
	}
}
mat colnames matrix_pvals_E = low_est low_pval exlow exhigh field phd unilow _cons
mat rownames matrix_pvals_E = `outcomes'
matrix list matrix_pvals_E


**************************************************
*************** CREATE THE TABLE   ***************
**************************************************

* Panel A: Expert forecast
eststo clear
local i = 0
foreach var in `outcomes' {
	local i = `i' + 1
	eststo `var': reghdfe `var' low_est low_low_expert low_high_expert exlow exhigh field phd unilow,  absorb(id vignette) vce(cluster id)
	matrix pvals_new = matrix_pvals_A[`i', 1...]
	estadd matrix pvals_new
}


esttab * using "${table_folder}/table_A7.tex",  replace cells(b(fmt(3) star) se(fmt(3) par) pvals_new(fmt(3) par("[" "]") star pvalue(pvals_new))) starlevel(* 0.1 ** 0.05 *** 0.01) keep(low_est low_low_expert low_high_expert exlow exhigh) nobase noomitted label refcat(low_est "& & & & \\ \textbf{Panel A}: Expert forecast", nolabel) mgroups("Publishability" "Quality (z-scored)" "Importance (z-scored)", pattern(1 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitle("\shortstack{Beliefs\\in percent}" "\shortstack{First-order\\beliefs}" "\shortstack{Second-order\\beliefs}" "\shortstack{First-order\\beliefs}" "\shortstack{Second-order\\beliefs}") collabels(none) booktabs fragment sub("                &      [.]   &      [.]   &      [.]   &      [.]   &      [.]   \\" "") noobs compress nogaps coeflabel(1.low "\addlinespace[1ex] Null result treatment")


* Panel B: Field journal
eststo clear
local i = 0
foreach var in `outcomes' {
	local i = `i' + 1
	eststo `var': reghdfe `var' low_est low_field exlow exhigh field phd unilow,  absorb(id vignette) vce(cluster id)
	matrix pvals_new = matrix_pvals_B[`i', 1...]
	estadd matrix pvals_new
}

esttab * using "${table_folder}/table_A7.tex",  append cells(b(fmt(3) star) se(fmt(3) par) pvals_new(fmt(3) par("[" "]") star pvalue(pvals_new))) starlevel(* 0.1 ** 0.05 *** 0.01) keep(low_est low_field field) nobase noomitted label refcat(low_est "& & & & \\ \textbf{Panel B}: Field journal", nolabel) nomtitles collabels(none) booktabs fragment sub("                &      [.]   &      [.]   &      [.]   &      [.]   &      [.]   \\" "") noobs nonumber compress nogaps coeflabel(1.low_est "\addlinespace[1ex] Null result treatment")


* Panel C: PhD student
eststo clear
local i = 0
foreach var in `outcomes' {
	local i = `i' + 1
	eststo `var': reghdfe `var' low_est low_phd exlow exhigh field phd unilow,  absorb(id vignette) vce(cluster id)
	matrix pvals_new = matrix_pvals_C[`i', 1...]
	estadd matrix pvals_new
}

esttab * using "${table_folder}/table_A7.tex",  append cells(b(fmt(3) star) se(fmt(3) par) pvals_new(fmt(3) par("[" "]") star pvalue(pvals_new))) starlevel(* 0.1 ** 0.05 *** 0.01) keep(low_est low_phd phd) nobase noomitted label refcat(low_est "& & & & \\ \textbf{Panel C}: PhD student", nolabel) nomtitles collabels(none) booktabs fragment sub("                &      [.]   &      [.]   &      [.]   &      [.]   &      [.]   \\" "") noobs nonumber compress nogaps coeflabel(1.low "\addlinespace[1ex] Null result treatment")


* Panel D: Lower-ranked university
eststo clear
local i = 0
foreach var in `outcomes' {
	local i = `i' + 1
	eststo `var': reghdfe `var' low_est low_unilow exlow exhigh field phd unilow,  absorb(id vignette) vce(cluster id)
	matrix pvals_new = matrix_pvals_D[`i', 1...]
	estadd matrix pvals_new
}

esttab * using "${table_folder}/table_A7.tex",  append cells(b(fmt(3) star) se(fmt(3) par) pvals_new(fmt(3) par("[" "]") star pvalue(pvals_new))) starlevel(* 0.1 ** 0.05 *** 0.01) keep(low_est low_unilow unilow) nobase noomitted label refcat(low_est "& & & & \\ \textbf{Panel D}: Lower-ranked university", nolabel) nomtitles collabels(none) booktabs fragment sub("                &      [.]   &      [.]   &      [.]   &      [.]   &      [.]   \\" "") noobs nonumber compress nogaps coeflabel(1.low "\addlinespace[1ex] Null result treatment")


* Panel E: P-value framing
eststo clear
local i = 0
foreach var in `outcomes' {
	local i = `i' + 1
	eststo `var': reghdfe `var' low_est low_pval exlow exhigh field phd unilow pval,  absorb(vignette) vce(cluster id)
	matrix pvals_new = matrix_pvals_E[`i', 1...]
	estadd matrix pvals_new
}

esttab * using "${table_folder}/table_A7.tex",  append cells(b(fmt(3) star) se(fmt(3) par) pvals_new(fmt(3) par("[" "]") star pvalue(pvals_new))) starlevel(* 0.1 ** 0.05 *** 0.01) keep(low_est low_pval pval) nobase noomitted label refcat(low_est "& & & & \\ \textbf{Panel E}: P-value framing", nolabel) nomtitles collabels(none) booktabs fragment sub("                &      [.]   &      [.]   &      [.]   &      [.]   &      [.]   \\" "" "                &            &            &            &            &            \\" "") nonumber compress nogaps coeflabel(1.low "\addlinespace[1ex] Null result treatment") stats(N N_clust, label("Observations" "Respondents") fmt(%9.0fc %9.0fc))
