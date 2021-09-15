/***************************************************************************
***************************************************************************
Objective 1: Compare oral anticoagulant treated vs untreated
in people with atrial fibrillation
***************************************************************************
======================================================================*/
*set filepaths
global projectdir `c(pwd)'
di "$projectdir"
global outdir "$projectdir/output" 
di "$outdir"
global tempdir_main_analysis "$projectdir/output/oac_tempdata" 
di "$tempdir_main_analysis"
global logdir "$projectdir/output/post_hoc_3_af_oac_log"
di "$logdir"
global tempdir "$projectdir/output/post_hoc_3_af_oac_tempdata" 
di "$tempdir"
global tabfigdir "$projectdir/output/post_hoc_3_af_oac_tabfig" 
di "$tabfigdir"

adopath + "$projectdir/analysis/extra_ados"

* Create directories required 
capture mkdir "$outdir/post_hoc_3_af_oac_tabfig"
capture mkdir "$outdir/post_hoc_3_af_oac_log"
capture mkdir "$outdir/post_hoc_3_af_oac_tempdata"

* Set globals that will print in programs and direct output

global population "Obj_1_AF"
global cum_death_ymax 0.1
global dagvarlist i.imd 					///	
				  i.obese4cat			    ///
				  i.smoke_nomiss		    ///
				  i.diabcat					///
				  i.myocardial_infarct		///
				  i.pad						///
				  i.hypertension			///		
				  i.heart_failure			///		
				  i.stroke_tia              ///
				  i.vte                     ///
				  i.dementia				///
				  i.oestrogen 				///	
				  i.antiplatelet            ///
				  i.flu_vaccine 			

global fullvarlist i.imd 					///
				   i.obese4cat			    ///
				   i.smoke_nomiss		    ///
				   i.diabcat				///
				   i.myocardial_infarct		///
				   i.pad					///
				   i.hypertension			///		
				   i.heart_failure			///		
				   i.stroke_tia             ///
				   i.vte                    ///
				   i.oestrogen 				///	
				   i.antiplatelet           ///
				   i.flu_vaccine 			///
				   i.ckd	 				///		
				   i.copd                   ///
				   i.other_respiratory      ///
				   i.immunodef_any		 	///
				   i.cancer     		    ///
				   i.dementia				///
				   i.ae_attendance_last_year ///
				   i.gp_consult 			

/* SET FU DATES===============================================================*/ 
* Censoring dates for each outcome
* https://github.com/opensafely/rapid-reports/blob/master/notebooks/latest-dates.ipynb
global onscoviddeathcensor   	= "28/09/2020"
global apcscensor           	= "01/10/2020"
global indexdate 			    = "01/03/2020"
global covidtestcensor          = "30/09/2020"
