* Setup paths
clear 
do setup.do

* Load data for all experiments
use "${data_folder}/main_study_cleaned.dta", clear 


* Pluralistic ignorance, quality 
eststo clear 
eststo fob: xi: qui reg z_qualityfob low exlow exhigh field phd unilow i.id i.vignette 
eststo sob: xi:  qui reg z_qualitysob low exlow exhigh field phd unilow i.id i.vignette 
qui eststo quality: qui suest fob sob , vce(cluster id)
test [fob_mean]low = [sob_mean]low 

* Pluralistic ignorance, importance
eststo clear 
eststo fob: xi: qui reg z_importancefob  low exlow exhigh field phd unilow  i.id i.vignette 
eststo sob: xi: qui reg z_importancesob low exlow exhigh field phd unilow i.id i.vignette 

qui eststo quality: qui suest fob sob , vce(cluster id)
test [fob_mean]low = [sob_mean]low 

egen tmp_max = max(publish), by(id)
egen tmp_min = min(publish), by(id)
gen publish_constant = tmp_max == tmp_min
gen publish_little_variation = abs(tmp_max- tmp_min) < 5
gen publish_maxdiff = abs(tmp_max - tmp_min)

summ publish_little_variation if order==1
summ publish_constant if order==1
summ publish_maxdiff, de
