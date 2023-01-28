///Master file
///Created: November 11, 2022
///Modified: January 28, 2023

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
global switch_1 "off"
global switch_2 "off"
global switch_3 "on"

global switch_4 "off"
global switch_5 "off"
global switch_6 "off"
global switch_7 "off"

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

if "$switch_explore_data" == "on" {
	do "$do_files/explore_data.do"
}

