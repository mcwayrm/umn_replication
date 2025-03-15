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


* Merge weights
merge 1:1 id using "${out_folder}/data/weights.dta"
drop _merge

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
    local mean_`var' : di %9.3fc `=r(mean)'
    local obs_`var' : di %9.0fc `=r(N)'

    * weighted mean
    qui summ `var' [aw=weights], de
    local weight_`var' : di %9.3fc `=r(mean)'

}

* Variables where the median is potentially interesting
foreach var in years_since_phd {
    qui summ `var', de
    local mean_`var' : di %9.3fc `=r(mean)'
    local median_`var' : di %9.3gc `=r(p50)'
    local obs_`var' : di %9.0fc `=r(N)'

    * weighted mean
    qui summ `var' [aw=weights], de
    local weight_`var' : di %9.3fc `=r(mean)'
}

* Andre and Falk summary stats
local af_stats af_female af_year_since_first_pub af_cont_europe af_cont_northernamerica af_cont_aus_nz af_cont_asia af_hindex af_num_top5 af_referee_con af_editor_real_top100
foreach var in `af_stats' {
    qui summ `var'_mean
    local `var'_mean : di %9.3fc `=r(mean)'

    qui summ `var'_median
    local `var'_median : di %9.3gc `=r(mean)'
}

************************************************************************
***** Manual data entry due to privacy concerns regarding the CV data:
************************************************************************

* Unweighted summary statistics.
local mean_gscitations "4,348.34"
local median_gscitations "846"
local obs_gscitations "328"
local mean_gshindex "17.22"
local median_gshindex "11.5"
local obs_gshindex "328"
local mean_top5count "1.27"
local obs_top5count "462"

* Weighted means
local weight_gscitations "4,579.753"
local weight_gshindex "16.905"
local weight_top5count "1.184"


**********************************
* Open file for writing
**********************************
file open sumstats_table_af using "${table_folder}/table_A4.tex", write replace

* Header
file write sumstats_table_af "      &  \multicolumn{2}{c}{Survey sample}                        &   \multicolumn{1}{c}{Sampling population}  \\" _n
file write sumstats_table_af "         \cmidrule(lr){2-3}                                                    \cmidrule(lr){4-4}" _n
file write sumstats_table_af "                             &  Original mean                     &   Reweighted mean                            &   Mean                                     \\" _n
file write sumstats_table_af "      \midrule    " _n


**********************************
*  Block 1: Demographics         *
**********************************

file write sumstats_table_af "\addlinespace" _n
file write sumstats_table_af "\textbf{Demographics}:       &                           &                                   &                                          \\ " _n

file write sumstats_table_af " \; Female*                   & `mean_female'             &   `weight_female'*                 &  `af_female_mean'                        \\ " _n
file write sumstats_table_af " \; Years since PhD          & `mean_years_since_phd'    &   `weight_years_since_phd'        &  `af_year_since_first_pub_mean'          \\ " _n
file write sumstats_table_af " \; PhD student              & `mean_phd_student'        &   `weight_phd_student'            &                                          \\ " _n
file write sumstats_table_af "\addlinespace" _n



**********************************
*  Block 2: Region               *
**********************************

file write sumstats_table_af "\addlinespace" _n
file write sumstats_table_af "\textbf{Region of institution}:            &                           &                               &                                 \\ " _n

file write sumstats_table_af " \; Europe*                   & `mean_region_europe'          &   `weight_region_europe'*        &  `af_cont_europe_mean'               \\ " _n
file write sumstats_table_af " \; North America*            & `mean_region_northamerica'    &   `weight_region_northamerica'*  &  `af_cont_northernamerica_mean'          \\ " _n
file write sumstats_table_af " \; Australia*                & `mean_region_australia'       &   `weight_region_australia'*     &  `af_cont_aus_nz_mean'               \\ " _n
file write sumstats_table_af " \; Asia*                     & `mean_region_asia'            &   `weight_region_asia'*          &  `af_cont_asia_mean'                \\ " _n
file write sumstats_table_af "\addlinespace" _n



**********************************
*  Block 3: Academic output      *
**********************************

file write sumstats_table_af "\addlinespace" _n
file write sumstats_table_af "\textbf{Academic output}:            &                             &                                &                                      \\ " _n

file write sumstats_table_af " \; H-index                          & `mean_gshindex'             &   `weight_gshindex'            &  `af_hindex_mean'                    \\ " _n
file write sumstats_table_af " \; Citations                        & `mean_gscitations'          &   `weight_gscitations'         &                                      \\ " _n
file write sumstats_table_af " \; Number of top 5 publications     & `mean_top5count'            &   `weight_top5count'           &  `af_num_top5_mean'                  \\ " _n
file write sumstats_table_af " \; Number of top 5s refereed for    & `mean_number_top5_referee'  &   `weight_number_top5_referee' &                                      \\ " _n
file write sumstats_table_af " \; Repeated top 5 referee*           & `mean_repeated_top_5_ref'   &   `weight_repeated_top_5_ref'*  &  `af_referee_con_mean'               \\ " _n
file write sumstats_table_af "\addlinespace" _n




**********************************
*  Block 4: Research evaluation  *
**********************************

file write sumstats_table_af "\addlinespace" _n
file write sumstats_table_af "\textbf{Research evaluation}:    &                                   &                                       &                           \\ " _n

file write sumstats_table_af " \; Current editor*               & `mean_current_editor'             &   `weight_current_editor'*             &  `af_editor_real_top100_mean'     \\ " _n
file write sumstats_table_af " \; Current associate editor     & `mean_current_associate_editor'   &   `weight_current_associate_editor'   &                        \\ " _n
file write sumstats_table_af " \; Ever editor                  & `mean_ever_editor'                &   `weight_ever_editor'                &                        \\ " _n
file write sumstats_table_af " \; Ever associate editor        & `mean_ever_associate_editor'      &   `weight_ever_associate_editor'      &                        \\ " _n
file write sumstats_table_af "\addlinespace" _n



**********************************
*  Block 5: Professional memberships  *
**********************************

file write sumstats_table_af "\addlinespace" _n
file write sumstats_table_af "\textbf{Professional memberships}:  &                                 &                               &                                \\ " _n

file write sumstats_table_af " \; NBER affiliate                  & `mean_nbermember'               &   `weight_nbermember'         &                                 \\ " _n
file write sumstats_table_af " \; CEPR affiliate                  & `mean_ceprmember'               &   `weight_ceprmember'         &                                 \\ " _n
file write sumstats_table_af "\addlinespace" _n



**********************************
*  Block 6: Academic fields      *
**********************************

file write sumstats_table_af "\addlinespace" _n
file write sumstats_table_af "\textbf{Academic fields}:  &                                           &                                         &                                          \\ " _n

file write sumstats_table_af " \; Labor                            & `mean_speciality_labor'         &   `weight_speciality_labor'             &                                          \\ " _n
file write sumstats_table_af " \; Public                           & `mean_speciality_public'        &   `weight_speciality_public'            &                                          \\ " _n
file write sumstats_table_af " \; Development                      & `mean_speciality_development'   &   `weight_speciality_development'       &                                          \\ " _n
file write sumstats_table_af " \; Political                        & `mean_speciality_political'     &   `weight_speciality_political'         &                                          \\ " _n
file write sumstats_table_af " \; Finance                          & `mean_speciality_finance'       &   `weight_speciality_finance'           &                                          \\ " _n
file write sumstats_table_af " \; Experimental                     & `mean_speciality_experimental'  &   `weight_speciality_experimental'      &                                          \\ " _n
file write sumstats_table_af " \; Behavioral                       & `mean_speciality_behavioral'    &   `weight_speciality_behavioral'        &                                          \\ " _n
file write sumstats_table_af " \; Theory                           & `mean_speciality_theory'        &   `weight_speciality_theory'            &                                          \\ " _n
file write sumstats_table_af " \; Macro                            & `mean_speciality_macro'         &   `weight_speciality_macro'             &                                          \\ " _n
file write sumstats_table_af " \; Econometrics                     & `mean_speciality_econometrics'  &   `weight_speciality_econometrics'      &                                          \\ " _n
file write sumstats_table_af "\addlinespace" _n

**********************************
* Close the file
**********************************
file close sumstats_table_af
**********************************
**********************************
