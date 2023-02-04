///Master file
///Created: November 11, 2022
///Modified: February 3, 2023

clear 

///Install packages
*ssc install (if needed)

///Set globals
cd "/Users/nakirsch/Documents/Georgetown 2.1/Thesis/git/nak-thesis"
global wd "/Users/nakirsch/Documents/Georgetown 2.1/Thesis/git/nak-thesis"
global orig_data "$wd/1_orig_data"
global do_files "$wd/2_do"
global prepped_data "$wd/3_prepped_data"
global temp "$wd/4_temp"
global output "$wd/5_output"

///Set switches
*Data prep
global switch_1 "on"
global switch_2 "on"
global switch_3 "on"

*Analysis
global switch_4 "on"
global switch_5 "on"
global switch_6 "on"
global switch_7 "on"

*Visuals
global switch_8 "off"
global switch_explore_data "off"

///Run files
if "$switch_1" == "on" {
	do "$do_files/1_clean_orig_data.do"
}

if "$switch_2" == "on" {
	do "$do_files/2_merge_orig_data.do"
}

if "$switch_3" == "on" {
	do "$do_files/3_create_subsets.do"
}

if "$switch_4" == "on" {
	do "$do_files/4_DD_main_analysis.do"
}

if "$switch_5" == "on" {
	do "$do_files/5_OLS_pretrends_analysis.do"
}

if "$switch_6" == "on" {
	do "$do_files/6_LPM_pledge_analysis.do"
}

if "$switch_7" == "on" {
	do "$do_files/7_first-diff_policy_analysis.do"
}

if "$switch_8" == "on" {
	do "$do_files/8_tables_figures.do"
}

if "$switch_explore_data" == "on" {
	do "$do_files/explore_data.do"
}

