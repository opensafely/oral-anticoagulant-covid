import delimited `c(pwd)'/output/input_general_population_flow_chart.csv, clear

*set filepaths
global projectdir `c(pwd)'
di "$projectdir"
global outdir "$projectdir/output" 
di "$outdir"
global logdir "$projectdir/output/oac_log"
di "$logdir"

adopath + "$projectdir/analysis/extra_ados"

* Create directories required 
capture mkdir "$outdir/oac_log"

