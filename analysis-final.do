/******************************************************************************	
	
	Project: Summer RA Training - STATA
			
--------------	
    THIS CODE:	
--------------

	Date Created: 06/26/2024
	Author: Yu Hui
	Code description: Problem Set 4

******************************************************************************/


** -----------------------------------------------------------------------------
**# SECTION 1: PRELIMINARY STEPS   
** -----------------------------------------------------------------------------
 * Load the dataset
use health.dta, clear
 
 ** descriptive analysis
 
graph bar gagne_sum_t, over(tm1_alcohol_elixhauser)
graph bar gagne_sum_t, over(tm1_drugabuse_elixhauser)

local variables gagne_sum_t tm1_alcohol_elixhauser tm1_drugabuse_elixhauser tm1_dem_age_band_1824 tm1_dem_age_band_2534 tm1_dem_age_band_3544 tm1_dem_age_band_4554 tm1_dem_age_band_5564 tm1_dem_age_band_6574 tm1_dem_age_band_75 tm1_dem_black tm1_dem_female cost_t


 ** description 
summarize `variables'
 
* Summarize the data to get an overview of missing values
misstable summarize `variables'


local variables gagne_sum_t tm1_alcohol_elixhauser tm1_drugabuse_elixhauser tm1_dem_age_band_1824 tm1_dem_age_band_2534 tm1_dem_age_band_3544 tm1_dem_age_band_4554 tm1_dem_age_band_5564 tm1_dem_age_band_6574 tm1_dem_age_band_75 tm1_dem_black tm1_dem_female cost_t

* Summarize the variables to get their statistics
summarize `variables'


* Clean the dataset -- abnormal cost removed


** -----------------------------------------------------------------------------
**# SECTION 2: REGRESSION ANALYSIS
** -----------------------------------------------------------------------------

* Descriptive analysis -- lifestyle and illness

* Set the graph font to Times New Roman
graph set window fontface "Times New Roman"
graph set print fontface "Times New Roman"

* Bar plot for alcohol abuse and active illness
collapse (mean) gagne_sum_t, by(tm1_alcohol_elixhauser)
label define alcohol_abuse 0 "No" 1 "Yes"
label values tm1_alcohol_elixhauser alcohol_abuse
graph bar (mean) gagne_sum_t, over(tm1_alcohol_elixhauser) ///
    title("Average Number of Active Illnesses by Alcohol Abuse") ///
    ytitle("Average Number of Active Illnesses") ///
    xtitle("Alcohol Abuse") ///
    bar(1, color(navy)) ///
    legend(off)
graph export "bar_plot_alcohol_abuse.png", replace

** Descriptive analysis -- medical cost and illness(scatter plot cannot be used here since the the outcome var is categorical)

* Set the graph font to Times New Roman
graph set window fontface "Times New Roman"
graph set print fontface "Times New Roman"

* 1. Bar plot for alcohol abuse and active illness
collapse (mean) gagne_sum_t, by(tm1_alcohol_elixhauser)
label define alcohol_abuse 0 "No" 1 "Yes"
label values tm1_alcohol_elixhauser alcohol_abuse
graph bar (mean) gagne_sum_t, over(tm1_alcohol_elixhauser) ///
    title("Average Number of Active Illnesses by Alcohol Abuse") ///
    ytitle("Average Number of Active Illnesses") ///
    bar(1, color(navy)) ///
    legend(off)
graph export "bar_plot_alcohol_abuse.png", replace

* 2.* Bar plot for drug abuse and active illness
collapse (mean) gagne_sum_t, by(tm1_drugabuse_elixhauser)
label define drug_abuse 0 "No" 1 "Yes"
label values tm1_drugabuse_elixhauser drug_abuse
graph bar (mean) gagne_sum_t, over(tm1_drugabuse_elixhauser) ///
    title("Average Number of Active Illnesses by Drug Abuse") ///
    ytitle("Average Number of Active Illnesses") ///
    bar(1, color(navy)) ///
    legend(off)
graph export "bar_plot_drug_abuse.png", replace

* 3. * Bar plot for obesity and active illness
collapse (mean) gagne_sum_t, by(tm1_obesity_elixhauser)
label define obesity 0 "No" 1 "Yes"
label values tm1_obesity_elixhauser obesity
graph bar (mean) gagne_sum_t, over(tm1_obesity_elixhauser) ///
    title("Average Number of Active Illnesses by Obesity") ///
    ytitle("Average Number of Active Illnesses") ///
    bar(1, color(navy)) ///
    legend(off)
graph export "bar_plot_obesity.png", replace


* Descriptive analysis -- control and illness
* Bar plot for age and active illness
* Generate average number of active illnesses for each age band
collapse (mean) gagne_sum_t, by(tm1_dem_age_band_1824 tm1_dem_age_band_2534 tm1_dem_age_band_3544 tm1_dem_age_band_4554 tm1_dem_age_band_5564 tm1_dem_age_band_6574 tm1_dem_age_band_75)

* Reshape the data for plotting
gen age_band = .
replace age_band = 1 if tm1_dem_age_band_1824 == 1
replace age_band = 2 if tm1_dem_age_band_2534 == 1
replace age_band = 3 if tm1_dem_age_band_3544 == 1
replace age_band = 4 if tm1_dem_age_band_4554 == 1
replace age_band = 5 if tm1_dem_age_band_5564 == 1
replace age_band = 6 if tm1_dem_age_band_6574 == 1
replace age_band = 7 if tm1_dem_age_band_75 == 1

label define age_band 1 "18-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55-64" 6 "65-74" 7 "75+"
label values age_band age_band

graph set window fontface "Times New Roman"
graph set print fontface "Times New Roman"

* Create the bar plot
graph bar (mean) gagne_sum_t, over(age_band) ///
    title("Average Number of Active Illnesses by Age Band") ///
    ytitle("Average Number of Active Illnesses") ///
    bar(1, color(navy)) ///
    legend(off)

graph export "bar_plot_age_band.png", replace

** -----------------------------------------------------------------------------
**# SECTION 3: REGRESSION ANALYSIS
** -----------------------------------------------------------------------------

* Define the variables

*----------
* Alcohol

* First regression
regress gagne_sum_t tm1_alcohol_elixhauser  ///
    tm1_dem_age_band_1824 tm1_dem_age_band_2534 tm1_dem_age_band_3544 ///
    tm1_dem_age_band_4554 tm1_dem_age_band_5564 tm1_dem_age_band_6574 ///
    tm1_dem_age_band_75 tm1_dem_black tm1_dem_female 

* Save first regression results
est store model1

* Generate predicted values
predict gagne_sum_hat

* IV regression (2SLS)
ivregress 2sls cost_t (gagne_sum_t = tm1_alcohol_elixhauser) ///
    tm1_dem_age_band_1824 tm1_dem_age_band_2534 tm1_dem_age_band_3544 ///
    tm1_dem_age_band_4554 tm1_dem_age_band_5564 tm1_dem_age_band_6574 ///
    tm1_dem_age_band_75 tm1_dem_black tm1_dem_female
* Save IV regression results
est store iv_model1

* Export all regression results to LaTeX
/* esttab model1 iv_model1 using "regression_results_alco.tex", replace ///
    title("Regression Results") ///
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons) ///
    label */


	
*-------
* Drug

drop gagne_sum_hat

* First regression
regress gagne_sum_t tm1_drugabuse_elixhauser ///
    tm1_dem_age_band_1824 tm1_dem_age_band_2534 tm1_dem_age_band_3544 ///
    tm1_dem_age_band_4554 tm1_dem_age_band_5564 tm1_dem_age_band_6574 ///
    tm1_dem_age_band_75 tm1_dem_black tm1_dem_female 
	
* Save first regression results
est store model2

* Generate predicted values
predict gagne_sum_hat	

* IV regression (2SLS)
ivregress 2sls cost_t (gagne_sum_t = tm1_drugabuse_elixhauser) ///
    tm1_dem_age_band_1824 tm1_dem_age_band_2534 tm1_dem_age_band_3544 ///
    tm1_dem_age_band_4554 tm1_dem_age_band_5564 tm1_dem_age_band_6574 ///
    tm1_dem_age_band_75 tm1_dem_black tm1_dem_female 

* Save IV regression results
est store iv_model2

* Export all regression results to LaTeX
/* esttab model1 iv_model1 model2 iv_model2 using "regression_results_combined.tex", replace ///
    title("Regression Results") ///
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons) ///
    label */

*-------
* Obesity
drop gagne_sum_hat

* First regression
regress gagne_sum_t tm1_obesity_elixhauser ///
    tm1_dem_age_band_1824 tm1_dem_age_band_2534 tm1_dem_age_band_3544 ///
    tm1_dem_age_band_4554 tm1_dem_age_band_5564 tm1_dem_age_band_6574 ///
    tm1_dem_age_band_75 tm1_dem_black tm1_dem_female 
	
* Save first regression results
est store model3

* Generate predicted values
predict gagne_sum_hat	

* IV regression (2SLS)
ivregress 2sls cost_t (gagne_sum_t = tm1_obesity_elixhauser) ///
    tm1_dem_age_band_1824 tm1_dem_age_band_2534 tm1_dem_age_band_3544 ///
    tm1_dem_age_band_4554 tm1_dem_age_band_5564 tm1_dem_age_band_6574 ///
    tm1_dem_age_band_75 tm1_dem_black tm1_dem_female 

* Save IV regression results
est store iv_model3

* Export all regression results to LaTeX
esttab model1 iv_model1 model2 iv_model2 model3 iv_model3 using "regression_results_combined1.tex", replace ///
    title("Regression Results") ///
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons) ///
    label

** -----------------------------------------------------------------------------
**# SECTION 4: Heterogenous Treatment Impact
** -----------------------------------------------------------------------------

* Create a new variable for age group categories
gen age_group = .
replace age_group = 1 if tm1_dem_age_band_1824 == 1 | tm1_dem_age_band_2534 == 1
replace age_group = 2 if tm1_dem_age_band_3544 == 1 | tm1_dem_age_band_4554 == 1 | tm1_dem_age_band_5564 == 1
replace age_group = 3 if tm1_dem_age_band_6574 == 1 | tm1_dem_age_band_75 == 1

* Label the age groups
label define age_group 1 "Young" 2 "Middle-aged" 3 "Elderly"
label values age_group age_group

* Define the control variables and lifestyle variables
local controls tm1_dem_black tm1_dem_female
local lifestyle tm1_alcohol_elixhauser/* tm1_drugabuse_elixhauser tm1_obesity_elixhauser*/

* Loop through each age group and perform the regressions
foreach group in 1 2 3 {
    * Restrict the data to the current age group
    preserve
    keep if age_group == `group'

    * First stage regression
    regress gagne_sum_t `lifestyle' `controls'
    predict gagne_sum_hat
	/*eststo first_stage_`group_label'*/
	eststo: regress gagne_sum_t `lifestyle' `controls'

    * 2SLS regression
    ivregress 2sls cost_t (gagne_sum_t = `lifestyle') `controls'
	/*eststo ivls_`group_label'*/
	eststo: ivregress 2sls cost_t (gagne_sum_t = `lifestyle') `controls'

    * Restore the full dataset for the next iteration
    restore
}



* Export the results to a LaTeX file
esttab using regression_results.tex, replace ///
    title("2SLS Regression Results by Age Group") ///
    label se b(%9.3f) star ///
    mtitles("First Stage (Young)" "2SLS (Young)" ///
            "First Stage (Middle-aged)" "2SLS (Middle-aged)" ///
            "First Stage (Elderly)" "2SLS (Elderly)")

* -----------------------------------------------------			
* Load dataset
use health.dta, clear

* Create a new variable for age group categories
gen age_group = .
replace age_group = 1 if tm1_dem_age_band_1824 == 1 | tm1_dem_age_band_2534 == 1
replace age_group = 2 if tm1_dem_age_band_3544 == 1 | tm1_dem_age_band_4554 == 1 | tm1_dem_age_band_5564 == 1
replace age_group = 3 if tm1_dem_age_band_6574 == 1 | tm1_dem_age_band_75 == 1

* Label the age groups
label define age_group 1 "Young" 2 "Middle-aged" 3 "Elderly"
label values age_group age_group

* Install the estout package if not already installed
eststo clear

* Define the control and lifestyle variables
local controls tm1_dem_black tm1_dem_female
local lifestyle tm1_drugabuse_elixhauser

* Loop through each age group and perform the regressions
foreach group in 1 2 3 {
    * Restrict the data to the current age group
    preserve
    keep if age_group == `group'

    * Store the current group label
    local group_label: label (age_group) `group'

    * First stage regression
    regress gagne_sum_t `lifestyle' `controls'
    predict gagne_sum_hat
    eststo first_stage_`group'

    * 2SLS regression
    ivregress 2sls cost_t (gagne_sum_t = `lifestyle') `controls'
    eststo sls_`group'

    * Restore the full dataset for the next iteration
    restore
}

* Export the results to a LaTeX file
esttab first_stage_1 sls_1 ///
       first_stage_2 sls_2 ///
       first_stage_3 sls_3 ///
       using regression_results_hetero2.tex, replace ///
       title("2SLS Regression Results by Age Group") label se b(%9.3f) star ///
       mtitles("First Stage (Young)" "2SLS (Young)" "First Stage (Middle-aged)" "2SLS (Middle-aged)" "First Stage (Elderly)" "2SLS (Elderly)")

* -----------------------------------------------------			
* Load dataset
use health.dta, clear

* Create a new variable for age group categories
gen age_group = .
replace age_group = 1 if tm1_dem_age_band_1824 == 1 | tm1_dem_age_band_2534 == 1
replace age_group = 2 if tm1_dem_age_band_3544 == 1 | tm1_dem_age_band_4554 == 1 | tm1_dem_age_band_5564 == 1
replace age_group = 3 if tm1_dem_age_band_6574 == 1 | tm1_dem_age_band_75 == 1

* Label the age groups
label define age_group 1 "Young" 2 "Middle-aged" 3 "Elderly"
label values age_group age_group

* Install the estout package if not already installed
eststo clear

* Define the control and lifestyle variables
local controls tm1_dem_black tm1_dem_female
local lifestyle tm1_obesity_elixhauser

* Loop through each age group and perform the regressions
foreach group in 1 2 3 {
    * Restrict the data to the current age group
    preserve
    keep if age_group == `group'

    * Store the current group label
    local group_label: label (age_group) `group'

    * First stage regression
    regress gagne_sum_t `lifestyle' `controls'
    predict gagne_sum_hat
    eststo first_stage_`group'

    * 2SLS regression
    ivregress 2sls cost_t (gagne_sum_t = `lifestyle') `controls'
    eststo sls_`group'

    * Restore the full dataset for the next iteration
    restore
}

* Export the results to a LaTeX file
esttab first_stage_1 sls_1 ///
       first_stage_2 sls_2 ///
       first_stage_3 sls_3 ///
       using regression_results_hetero2.tex, replace ///
       title("2SLS Regression Results by Age Group") label se b(%9.3f) star ///
       mtitles("First Stage (Young)" "2SLS (Young)" "First Stage (Middle-aged)" "2SLS (Middle-aged)" "First Stage (Elderly)" "2SLS (Elderly)")
	   
			
			





