***************************************************************
************           Main Do-File             ***************
***************************************************************

* Install required packages
capture ssc install estout
capture ssc install blindschemes
capture ssc install rwolf2
capture ssc install addplot
capture ssc install cdfplot
capture ssc install reghdfe
capture ssc install coefplot
capture ssc install grstyle
capture ssc install winsor
capture ssc install winsor2

* MANUAL CHANGES REQUIRED:
* Set the working directory to the folder where the data is stored
* in the setup file.
do setup

***************************************************************
************           Analysis                 ***************
***************************************************************

* Tables
do tables/table_1
do tables/table_3
do tables/table_4
do tables/table_5
do tables/table_A1
do tables/table_A2
do tables/table_A3
do tables/table_A4
do tables/table_A5
do tables/table_A6
do tables/table_A7_A8
do tables/table_A9
do tables/table_A10
do tables/table_A11
do tables/table_A12

* Figure
do figures/figure_2.do
do figures/figure_3.do
do figures/figure_A1.do
do figures/figure_A2.do
do figures/figure_A3.do

* Other
do other/ex_post_power_with_bootstrap.do
do other/other_statistics.do

***************************************************************
*   Weights: The calculation of weights is done in R          *
***************************************************************

* R-script can be found here:
*   code/weights_R/calculate_weights.R

***************************************************************
************           End of do-file           ***************
***************************************************************
