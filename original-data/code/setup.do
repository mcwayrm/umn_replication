* -------------                Configuration                    ----------------
clear 
global pm = char(177)
set more off

gl date = c(current_date)
if c(os) == "MacOSX" gl user "/Users/`c(username)'"
else if c(os) == "Windows" gl user "C:\Users\\`c(username)'"
else if c(os) == "Unix" gl user "/usr/`c(username)'"
di "$user" 

set cformat %5.3f

* -------------           Paths for each user                   ----------------

* USER INPUT: Set your user name here and the path to the root of the replication package
if "$user" == "ryanm"{
	global dirpath "D:\umn_replication\original-data"		
}
// Hard coded so I can use the external hard-drive 
global dirpath "D:\umn_replication\original-data"

* -------------           Common paths                   ---------------------------

* processed data folder
global data_folder "${dirpath}/data"

* out folder
global out_folder "${dirpath}/out" 

* code folder 
global code_folder "${dirpath}/code" 

* table folder 
global table_folder "${dirpath}/out/tables"

* external figure folder 
global figure_folder "${dirpath}/out/figures"  

* change directory to the code folder.
cd "$code_folder"

* ---------      Set figure scheme       ---------------

set scheme plotplainblind
grstyle init
grstyle set plain, grid noextend dotted compact horizontal
grstyle set legend 3, nobox klength(4)
grstyle set size 10pt: heading

* ------------- CONTROL VARIABLES ---------------------

global treatments low exlow exhigh field phd unilow pval
global crosstreatments exlow exhigh field phd unilow 
