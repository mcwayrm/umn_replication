
clear 

* load raw data
use "${data_folder}/raw/main_study_raw.dta", clear

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


* Merge with external data expert demographics
* not included as individual-level data: gshindex gscitations top5count 

local external male years_since_phd phd_student region_europe region_northamerica region_australia region_asia number_top5_referee current_editor ever_editor nbermember ceprmember speciality_* highcite anytop5

merge 1:1 id using "${data_folder}/expert_demographics.dta", keepusing(`external')
drop _merge 


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
keep if count==4 
drop count 

* rename the quality variables 

foreach var of varlist qualityfob_* qualitysob_* {
local x = substr("`var'",1,17)  
rename `var' `x'
}

* Drop values we don't need 

drop lowpval* highpval* stat_text* 

* Rename the timer 

rename *_page_submit page_submit_*
rename page_submit_timer* pagetime* 

* Local list of vignettes

local vignettes finlit fememp salpov equsha meraid 

* Reshape the data 

keep qualityfob* qualitysob* publish* field* low* prof* unilow* exlow* exhigh* fobsobwording date duration finished pagetime* stat* order* `external' id

* Remove the underline 

foreach var of varlist * {
local x = subinstr("`var'", "_", "",.) 
rename `var' `x'
}

* Local outcomes 

local outcomes qualityfob qualitysob publish  
local treatments field low professor unilow exlow exhigh 

* cap drop id 
rename id demographics_id
gen id = _n

reshape long `outcomes' `treatments' order stat pagetime , i(id) j(v,string)
order `outcomes' `treatments'
encode v, gen(vignette)
drop v 
drop if missing(publish)

* Split the quality variable into importance/quality 

clonevar importancefob = qualityfob 
clonevar importancesob = qualitysob 

foreach x of varlist qualityfob qualitysob {
replace `x' = . if fobsobwording=="importance"	
}
foreach x of varlist importancefob importancesob {
replace `x' = . if fobsobwording=="quality"	
}

drop fobsobwording* 

* Fix stat

gen pval = stat=="pval" 
drop stat 

* Create indicators 

foreach var of varlist `treatments' {
	replace `var' = 0 if missing(`var')	
}


* Create an indicator for whether vignette involved team of PhD students (this is NOT the PhD status of the respondent!)
recode professor (0 = 1 "PhD student") (1 = 0 "Professor"), gen(phd)
la var phd

* Label the values 

la var qualityfob "Quality (first-order beliefs)"
la var qualitysob "Quality (second-order beliefs)"
la var importancefob "Importance (first-order beliefs)"
la var importancesob "Importance (second-order beliefs)"
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
la var order "Order of vignettes"

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

local outcomes publish qualityfob qualitysob importancefob importancesob   

order `outcomes'

* Create z-scored variables
foreach var in `outcomes' {
	capture drop z_`var'
	qui summ `var' if low==0
	qui gen z_`var' = (`var' - r(mean)) / r(sd)
}

* study id
gen study_id = `number' 
label data "Study `number'"
la var study_id "Study ID"


order publish qualityfob qualitysob importancefob importancesob field low professor unilow exlow exhigh id duration pagetime demographics_id order date male phdstudent numbertop5referee nbermember ceprmember evereditor currenteditor regionasia regionaustralia regioneurope regionnorthamerica specialitymacro specialitymicro specialityeconometrics specialitypublic specialitylabor specialitydevelopment specialitypolitical specialityeducation specialityinternational specialityfinance specialityexperimental specialitybehavioral specialityhealth specialityenvironmental specialitytheory specialitystatistics vignette pval phd z_publish z_qualityfob z_qualitysob z_importancefob z_importancesob study_id anytop5 highcite

***********************************************
********* Save the file ***********************
***********************************************

save "$data_folder/main_study_cleaned.dta", replace
