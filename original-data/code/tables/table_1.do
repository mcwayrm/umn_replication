* Setup paths
clear 

* Load expert demographics and merge with Andre and Falk (2022) data
use "${data_folder}/expert_demographics.dta"
rename id tmp_id
gen id = 1

* Merge AF data
merge m:1 id using "${data_folder}/composition.dta"
drop _merge
drop id
rename tmp_id id


* Auxiliary variables
gen female = 1 - male if !missing(male)

gen repeated_top_5_ref = number_top5_referee > 1 if !missing(number_top5_referee)

gen af_year_since_first_pub_mean = 2021 - af_year_first_pub_mean
gen af_year_since_first_pub_median = 2021 - af_year_first_pub_median


* ------------------------------ TABLE: SUMMARY STATISTICS  ------------------------------

local stats female phd_student region_europe region_northamerica region_australia region_asia  number_top5_referee repeated_top_5_ref current_editor current_associate_editor ever_editor ever_associate_editor nbermember ceprmember speciality_labor speciality_public speciality_development speciality_political speciality_finance speciality_experimental speciality_behavioral speciality_theory speciality_macro speciality_econometrics

* Variables where the median is not interesting
foreach var of varlist `stats' {
    qui summ `var', de
    local mean_`var' : di %9.2fc `=r(mean)'
    local obs_`var' : di %9.0fc `=r(N)'
}

* Variables where the median is potentially interesting
foreach var in years_since_phd {
    qui summ `var', de
    local mean_`var' : di %9.2fc `=r(mean)'
    local median_`var' : di %9.3gc `=r(p50)'
    local obs_`var' : di %9.0fc `=r(N)'
}

* Manual data entry due to privacy concerns regarding the CV data:
local mean_gscitations "4,348.34"
local median_gscitations "846"
local obs_gscitations "328"
local mean_gshindex "17.22"
local median_gshindex "11.5"
local obs_gshindex "328"
local mean_top5count "1.27"
local obs_top5count "462"


* Andre and Falk summary stats
local af_stats af_female af_year_since_first_pub af_cont_europe af_cont_northernamerica af_cont_aus_nz af_cont_asia af_hindex af_num_top5 af_referee_con af_editor_real_top100
foreach var in `af_stats' {
    qui summ `var'_mean
    local `var'_mean : di %9.2fc `=r(mean)'

    qui summ `var'_median
    local `var'_median : di %9.2gc `=r(mean)'
}

**********************************
* Open file for writing
**********************************
file open sumstats_table using "${table_folder}/table_1.tex", write replace

* Header
file write sumstats_table "      &  \multicolumn{3}{c}{Survey sample}         &   \multicolumn{2}{c}{Sampling population}  \\" _n
file write sumstats_table "         \cmidrule(lr){2-4}                            \cmidrule(lr){5-6}" _n
file write sumstats_table "                             &  Mean        &   Median      &  Obs.      &   Mean     &   Median  \\" _n
file write sumstats_table "      \midrule    " _n


**********************************
*  Block 1: Demographics         *
**********************************

file write sumstats_table "      &     &    \\ " _n
file write sumstats_table "\textbf{Demographics}:       &                &               &                   &            &            \\ " _n

file write sumstats_table " \; Female       & `mean_female'  &   `median_female'    &    `obs_female'   &  `af_female_mean'  &    `af_female_median'  \\ " _n
file write sumstats_table " \; Years since PhD       & `mean_years_since_phd'  &   `median_years_since_phd'    &    `obs_years_since_phd'   &  `af_year_since_first_pub_mean'  &    `af_year_since_first_pub_median'  \\ " _n
file write sumstats_table " \; PhD student       & `mean_phd_student'  &   `median_phd_student'    &    `obs_phd_student'   &                 &               \\ " _n
file write sumstats_table "\addlinespace" _n



**********************************
*  Block 2: Region               *
**********************************

file write sumstats_table "      &     &    \\ " _n
file write sumstats_table "\textbf{Region of institution}:       &                &               &                   &            &            \\ " _n

file write sumstats_table " \; Europe               & `mean_region_europe'             &   `median_region_europe'         &    `obs_region_europe'          &  `af_cont_europe_mean'  &    `af_cont_europe_median'  \\ " _n
file write sumstats_table " \; North America        & `mean_region_northamerica'    &   `median_region_northamerica'    &    `obs_region_northamerica'      &  `af_cont_northernamerica_mean'  &    `af_cont_northernamerica_median'  \\ " _n
file write sumstats_table " \; Australia            & `mean_region_australia'        &   `median_region_australia'    &    `obs_region_australia'           &  `af_cont_aus_nz_mean'  &    `af_cont_aus_nz_median'  \\ " _n
file write sumstats_table " \; Asia            & `mean_region_asia'            &   `median_region_asia'            &    `obs_region_asia'              &        `af_cont_asia_mean'  &    `af_cont_asia_median'  \\ " _n
file write sumstats_table "\addlinespace" _n



**********************************
*  Block 3: Academic output      *
**********************************

file write sumstats_table "      &     &    \\ " _n
file write sumstats_table "\textbf{Academic output}:       &                &               &                   &            &            \\ " _n

file write sumstats_table " \; H-index                          & `mean_gshindex'             &   `median_gshindex'             &    `obs_gshindex'            &  `af_hindex_mean'      & `af_hindex_median'  \\ " _n
file write sumstats_table " \; Citations                        & `mean_gscitations'          &   `median_gscitations'          &    `obs_gscitations'         &                        &               \\ " _n
file write sumstats_table " \; Number of top 5 publications     & `mean_top5count'            &   `median_top5count'            &    `obs_top5count'           &  `af_num_top5_mean'    & `af_num_top5_median'  \\ " _n
file write sumstats_table " \; Number of top 5s refereed for    & `mean_number_top5_referee'  &   `median_number_top5_referee'  &    `obs_number_top5_referee' &                        &                    \\ " _n
file write sumstats_table " \; Repeated top 5 referee           & `mean_repeated_top_5_ref'   &   `median_repeated_top_5_ref'   &    `obs_repeated_top_5_ref'  &  `af_referee_con_mean' & `af_referee_con_median'  \\ " _n
file write sumstats_table "\addlinespace" _n




**********************************
*  Block 4: Research evaluation  *
**********************************

file write sumstats_table "      &     &    \\ " _n
file write sumstats_table "\textbf{Research evaluation}:       &                &               &                   &            &            \\ " _n

file write sumstats_table " \; Current editor               & `mean_current_editor'             &   `median_current_editor'             &    `obs_current_editor'  &  `af_editor_real_top100_mean' & `af_editor_real_top100_median'    \\ " _n
file write sumstats_table " \; Current associate editor     & `mean_current_associate_editor'   &   `median_current_associate_editor'   &    `obs_current_associate_editor'  &                        &                       \\ " _n
file write sumstats_table " \; Ever editor                  & `mean_ever_editor'                &   `median_ever_editor'                &    `obs_ever_editor'               &                        &                       \\ " _n
file write sumstats_table " \; Ever associate editor        & `mean_ever_associate_editor'      &   `median_ever_associate_editor'      &    `obs_ever_associate_editor'     &                        &                       \\ " _n
file write sumstats_table "\addlinespace" _n



**********************************
*  Block 5: Professional memberships  *
**********************************

file write sumstats_table "      &     &    \\ " _n
file write sumstats_table "\textbf{Professional memberships}:       &                &               &                   &            &            \\ " _n

file write sumstats_table " \; NBER affiliate & `mean_nbermember'   &   `median_nbermember'   &    `obs_nbermember'  &                        &                       \\ " _n
file write sumstats_table " \; CEPR affiliate & `mean_ceprmember'   &   `median_ceprmember'   &    `obs_ceprmember'  &                        &                       \\ " _n
file write sumstats_table "\addlinespace" _n



**********************************
*  Block 6: Academic fields      *
**********************************

file write sumstats_table "      &     &    \\ " _n
file write sumstats_table "\textbf{Academic fields}:        &                &               &                   &            &            \\ " _n

file write sumstats_table " \; Labor          & `mean_speciality_labor'         &   `median_speciality_labor'           &    `obs_speciality_labor'  &  &  \\ " _n
file write sumstats_table " \; Public         & `mean_speciality_public'        &   `median_speciality_public'          &    `obs_speciality_public'  &  &  \\ " _n
file write sumstats_table " \; Development    & `mean_speciality_development'   &   `median_speciality_development'     &    `obs_speciality_development'  &  &  \\ " _n
file write sumstats_table " \; Political      & `mean_speciality_political'     &   `median_speciality_political'       &    `obs_speciality_political'  &  &  \\ " _n
file write sumstats_table " \; Finance        & `mean_speciality_finance'       &   `median_speciality_finance'         &    `obs_speciality_finance'  &  &  \\ " _n
file write sumstats_table " \; Experimental   & `mean_speciality_experimental'  &   `median_speciality_experimental'    &    `obs_speciality_experimental'  &  &  \\ " _n
file write sumstats_table " \; Behavioral     & `mean_speciality_behavioral'    &   `median_speciality_behavioral'      &    `obs_speciality_behavioral'  &  &  \\ " _n
file write sumstats_table " \; Theory         & `mean_speciality_theory'        &   `median_speciality_theory'          &    `obs_speciality_theory'  &  &  \\ " _n
file write sumstats_table " \; Macro          & `mean_speciality_macro'         &   `median_speciality_macro'           &    `obs_speciality_macro'  &  &  \\ " _n
file write sumstats_table " \; Econometrics   & `mean_speciality_econometrics'  &   `median_speciality_econometrics'    &    `obs_speciality_econometrics'  &  &  \\ " _n
file write sumstats_table "\addlinespace" _n


 

**********************************
* Close the file
**********************************
file close sumstats_table
**********************************
**********************************
