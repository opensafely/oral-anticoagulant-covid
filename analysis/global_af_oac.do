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
global logdir "$projectdir/output/oac_log"
di "$logdir"
global tempdir "$projectdir/output/oac_tempdata" 
di "$tempdir"
global tabfigdir "$projectdir/output/oac_tabfig" 
di "$tabfigdir"

adopath + "$projectdir/analysis/extra_ados"

* Create directories required 
capture mkdir "$outdir/oac_tabfig"
capture mkdir "$outdir/oac_log"
capture mkdir "$outdir/oac_tempdata"

* Set globals that will print in programs and direct output

global population "Obj_1_AF"
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

				   
global coviddeathfullvarlist i.imd 			///
				   i.obese4cat			    ///
				   i.smoke_nomiss		    ///
				   i.diab_control			///
				   i.myocardial_infarct		///
				   i.pad					///
				   i.hypertension			///		
				   i.heart_failure			///		
				   i.vte                    ///	
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
				   
global admitfullvarlist i.imd 				///
				   i.obese4cat			    ///
				   i.smoke_nomiss		    ///
				   i.diab_control			///
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
