clear

* load raw
use "${data_folder}/raw/mechanism_study_raw.dta", clear

* Set seed for replication purposes 
set seed 123

* Destring all 

destring *, replace

* Get all variables with value labels
ds, has(vallabel)
local vars `r(varlist)'

foreach var of local vars {
	* get the name of the value label for variable `var'
	local labname : value label `var'
	
	* create a copy with name prefix + oldname
	label copy `labname' `var'_lab, replace
	
	* assign that copy to variable `var'
	label value `var' `var'_lab
}

desc 

* Fix the date variable 

gen date = dofc(startdate)
format date %td

* rename the publish variable 

foreach var of varlist publish_* {
local x = substr("`var'",1,14)  
rename `var' `x'
}

* Create a variable for viewing order 

rename _v1 order_meraid
rename _v2 order_equsha
rename _v3 order_salpov 
rename _v4 order_fememp
rename _v5 order_finlit 

* Rename duration

rename duration__in_seconds_ duration 

* Drop if missing on all publish variables 

drop if missing(publish_meraid) & missing(publish_equsha) & missing(publish_salpov) & missing(publish_fememp) & missing(publish_finlit) 

* Count number of vignettes 

gen count = 0
foreach x of varlist publish* {	
replace count = count + 1 if !missing(`x') 
}
tab count
keep if count==5
drop count 


* Drop values we don't need 

drop lowpval* highpval* stat_text* status 

* Rename the timer 

rename *_page_submit page_submit_*
rename page_submit_timer* pagetime* 

* Local list of vignettes

local vignettes finlit fememp salpov equsha meraid 

* Reshape the data 

gen respondent_id = _n

keep id respondent_id precision* publish* field* low* prof* unilow* exlow* exhigh* date duration finished pagetime* stat* order* 



* Remove the underline 

foreach var of varlist * {
local x = subinstr("`var'", "_", "",.) 
rename `var' `x'
}

* Local outcomes 

local outcomes precision publish  
local treatments field low professor unilow exlow exhigh 


reshape long `outcomes' `treatments' order stat pagetime , i(id) j(v,string)
order `outcomes' `treatments'
encode v, gen(vignette)
drop v 

* Fix stat

gen pval = stat=="pval" 
drop stat 

* Create indicators 

foreach var of varlist `treatments' {
replace `var' = 0 if missing(`var')	
}

* Label the values 

la var precision "Precision"
la var publish "Publishability"
la var field "Field journal"
la var low "Low estimate (null finding)"
la var professor "Professor"
la var unilow "Low-ranked university"
la var exlow "Low expert forecast"
la var exhigh "High expert forecast"
la var id "ID"
la var vignette "Vignette"
la var pagetime "Seconds on vignette page"
la var date "Date"
la var pval "P-value framing"

* Create value labels and label the variables 

label define field_lab 0 "General interest journal" 1 "Field journal"
label define low_lab 0 "Positive result" 1 "Null result"
label define professor_lab 0 "Phd Student" 1 "Professor"
label define unilow_lab 0 "High-ranked university" 1 "Low-ranked university"
label define exlow_lab 0 "Not low expert forecast" 1 "Low expert forecast"
label define exhigh_lab 0 "Not high expert forecast" 1 "High expert forecast"
label define pval_lab 0 "Standard error framing" 1 "P-value framing"

local treatments `treatments' pval 

foreach v of local treatments {
     label values `v' `v'_lab 
}

* Redine list of outcomes to include importance 

local outcomes publish precision

order `outcomes'

* Create z-scored variables
foreach var in `outcomes' {
	capture drop z_`var'
	qui summ `var' if low==0
	qui gen z_`var' = (`var' - r(mean)) / r(sd)
}


***********************************************
********* Merge CV data ***********************
***********************************************

* Merge CV data
merge m:1 id using "${data_folder}/mechanism_experiment_CV_data.dta"
tab _merge
drop if _merge == 2
drop _merge

cap drop id 
rename respondentid id


***********************************************
********* Save the file ***********************
***********************************************

save "${data_folder}/mechanism_study_cleaned.dta", replace

