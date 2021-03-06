*!excel_wrapper_for_iwplot_svyp version 1.1 2016-06-07

/**********************************************************************
Program Name:              excel_wrapper_for_iwplot_svyp
Purpose:                   Program to allow users to use an excel file as input for iwplot_svyp
Project:                   
Charge Number:  
Date Created:    			2016-05-12
Date Modified:  
Input Data:                 
Output2:                                
Comments: 
Author:         Mary Kay Trimner

Stata version:    14.0
**********************************************************************/
capture program drop excel_wrapper_for_iwplot_svyp

program define excel_wrapper_for_iwplot_svyp

	* Set the local for xlsname for importing data
	local xlsname `1'
	
	capture program drop iwplot_svyp
	
	set more off
	
	* read the main worksheet with info about distributions, markvalues,
	* clipping, lcb ticks, ucb ticks, shading behind distributions
	* and customized text for the right margin
	import excel using "`xlsname'", sheet("distribution_info") firstrow allstring clear
	capture quietly destring rownumber , replace
	capture quietly destring param1, replace
	capture quietly destring param2, replace
	capture quietly destring areaintensity, replace
	capture quietly destring markvalue, replace
	capture quietly destring clip, replace
	capture quietly destring lcb , replace
	capture quietly destring ucb , replace
	tempfile distribution
	save `distribution', replace

	* read & save info about any desired vertical lines
	import excel using "`xlsname'", sheet("vertical_lines") firstrow allstring clear
	if `=_N' > 0 {
		capture quietly destring xcoord  , replace
		capture quietly destring ystart  , replace
		capture quietly destring ystop   , replace
		tempfile vl
		save `vl', replace
		local verplot verlinesdata(`vl')
	}

	* read & save info about any desired horizontal lines
	import excel using "`xlsname'", sheet("horizontal_lines") firstrow allstring clear
	if `=_N' > 0 {
		capture quietly destring ycoord , replace
		capture quietly destring xstart , replace
		capture quietly destring xstop  , replace
		tempfile hl
		save `hl', replace
		local horplot horlinesdata("`hl'")	
	}
	
	* read & save info about any desired text to put on top of the plot
	* (Note that CI text at right is handled with the citext option
	*  and graph and axis titles should be specified using the iwplot_vcqi
	*  options...this textbox business is for additional text on top 
	*  of the plot to call attention to something special.)
	import excel using "`xlsname'", sheet("textbox") firstrow allstring clear
	if `=_N' > 0 {
		capture quietly destring xcoordtext , replace
		capture quietly destring ycoordtext , replace
		tempfile tx
		save `tx', replace
		local textplot textonplotdata("`tx'")	
	}

	* read & save info about any desired arrows
	import excel using "`xlsname'", sheet("arrows") firstrow allstring clear
	if `=_N' > 0 {
		capture quietly destring xcoordend, replace
		capture quietly destring ycoordend, replace
		capture quietly destring xcoordtip, replace
		capture quietly destring ycoordtip, replace
		tempfile ar
		save `ar', replace
		local arrowplot arrowsdata("`ar'")	
	}

	* Call the program that makes and saves and exports the plot;
	* note that additional options are available; look at the comments
	* at the top of the program to learn more
	
	* The example below specifies 
	* nl(20)
	* which is to say that every distribution will be made of 20 x,y
	* pairs to define the shape of the top half of the distribution;
	* this will run faster if you specify nl(5) until the plot looks the
	* way you want it, and then switch to nl(20) (or higher) to make
	* your final plots for presentation
	
	* The example below specifies 
	* citext(3)
	* but you can also specify 1, 2, 4, or 5
	* or leave the option off altogether
	*
	
	* Pull in command_lines tab from spreadsheet to create local variables for iwplot_vcqi program
	* save info about command_lines


	import excel using "`xlsname'", sheet("command_lines") firstrow allstring clear
	capture quietly destring nl  			, replace
	capture quietly destring xaxisrange		, replace
	capture quietly destring xsize  		, replace
	capture quietly destring ysize  		, replace
	capture quietly destring equalarea 		, replace
	capture quietly destring polygon 		, replace
	
	if `=_N' > 0 {
		* Create the command_line locals based on the values from the spreadsheet
		forvalues i = 1/`=_N' {
			foreach v in nl xtitle ytitle title subtitle note xaxisrange xsize ysize citext equalarea saving name export cleanwork twoway {
				local `v' 
				if !missing(`v'[`i'])	local `v' `v'(`=`v'[`i']')

			}
			
			preserve
	
			iwplot_svyp, 						///
				inputdata("`distribution'") 		///
				`nl'								///
				`xtitle' `ytitle' `title' ///
				`subtitle' `note' `xaxisrange' `xsize' `ysize' ///
				`verplot' `horplot'  `textplot' `arrowplot' ///
				`citext' `equalarea' ///
				`saving' `name' `export' `cleanwork' `twoway'

			restore
		}
	}

	
	capture erase arrows.dta
	capture erase textbox.dta
	capture erase test1.dta
	capture erase vertical_lines.dta
	capture erase horizontal_lines.dta
	capture erase distribution_info.dta
*	capture erase distribution_info_l.dta
*	capture erase distribution_info_w.dta
end

