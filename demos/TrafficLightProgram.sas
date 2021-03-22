 /************************************************************************/
 /* Demonstrate a powerful, but lesser known programming technique for   */
 /* how to use Formats and ODS style options with SAS Procedure output   */
 /* to add highlights to SAS report output.                              */
 /*                                                                      */
 /* The Base SAS procedures that currently allow these ODS features to   */
 /* be applied on their statements, are the PRINT, REPORT, and TABULATE  */
 /* procedures.                                                          */
 /* -------------------------------------------------------------------- */
 /* For the first example, the SASHELP.DEMOGRAPHICS is the input data.   */
 /* This data set has some older (1998-2004) demographic data related to */
 /* Countries around the world. Some of the country demongraphics are    */
 /* population, poverty, and  primary education enrollment. This         */
 /* demonstration will massage the data to produce a working data set:   */
 /* WORK.EDUCATION. The country identifying columns will be removed and  */
 /* an arbitrary, random ID number will be created. Also, in the         */
 /* original data set there are 2 variables representing percentages of  */
 /* the male and female population that have enrolled in primary schools */
 /* by country. An average is calculated and based on the percentage     */
 /* values found in the now 3 columns (average, male, and female), a     */
 /* PROC PRINT is generated using ODS STYLE options so that if the       */
 /* percentages are 70% or above, the result will display with a green   */
 /* background, 60% to 70% will display with a yellow background, 50% to */
 /* 60% will display with a red background, and below 50% will display   */
 /* with a black background. If a country has missing data, then the     */
 /* percentage will be set to 0, and will be displayed with a blue       */
 /* background. User defined formats are used to align different color   */
 /* attributes based on different percentage range values, making the    */
 /* coloration applied, a dynamic, data driven process.                  */ 
 /*                                                                      */
 /* These results are then pushed to Excel workbook (xlsx file) and to   */
 /* an Adobe Acrobate file (or a PDF file) using ODS destination         */
 /* statements, where we can see that the color attributes applied in    */
 /* the procedure, are also seen in the Excel worksheet/workbook and the */
 /* PDF files created.                                                   */
 /* -------------------------------------------------------------------- */
 /* In a second example, a summary data set will be produced:            */
 /* WORK.EDUCATIONSUM using the WORK.EDUCATION data created in the first */
 /* example. The data from the WORK.EDUCATION will be grouped by various */
 /* Primary School Enrollment percentages, and then counted and averaged */
 /* for all the countries that fit into each grouping.                   */
 /*                                                                      */
 /* Filtered HTML Detail reports are created for each percentage group,  */
 /* and a Summary HTML report is created listing the percentage groups   */
 /* with their counts and averages. Again, using a user defined format   */
 /* to align the different groups to the HTML files containing their     */
 /* respective filtered detail report, it will be demonstrated how the   */
 /* HTML detail reports can be accessed via a group value HYPERLINK that */
 /* is displayed on the Summary Report.                                  */ 
 /* -------------------------------------------------------------------- */
 /* Author: Brian Gayle                                                  */
 /* Date:   2021-05-20                                                   */
 /************************************************************************/

 /*==============================================================*/
 /* NOTICE! Change this to a path YOU can write to:              */
 /* Set up a macro variable that will hold folder/directory      */
 /* location for generated output to be written.                 */
 /*==============================================================*/
%let outpath = C:/bgg/SAS/Projects/SGF_2021/output;


 /*==============================================================*/
 /* Part ONE - Set Up                                            */
 /*      - Browse the input data set column data and Metadata    */
 /*      - Prepare a data set to use and then view it            */
 /*        (197 observations and 5 variables)                    */
 /*==============================================================*/

 /*--------------------------------------------------*/
 /* Browse the input data set column data & Metadata */
 /* ------------------------------------------------ */
 /* Look at the columns that exist in the            */
 /* SASHELP.Demographics input data set. This data   */
 /* is quite old (1998-2004), but will be useful for */
 /* this demonstration. The ODS SELECT statement     */
 /* allows the Proc CONTENTS output to contain       */
 /* only the variable listing from the CONTENTS      */
 /* procedure and then resets procedure output to    */
 /* the session default (all procedure output).      */
 /*                                                  */
 /* The PRINT procedure provides a sample of         */
 /* selected variables that will be used from the    */
 /* input data set for this program.                 */
 /*--------------------------------------------------*/

 /*     ----------------------------------------     */
 /* Browse/Review the columns and labels from the    */
 /* Input Data Set: SASHELP.DEMOGRAPHICS
 /*     ----------------------------------------     */
 /* ods trace on; */
 /* proc contents data=sashelp.Demographics varnum;  */
 /* run; */
 /* ods trace off; */
 /*
    ods select position; 
    title 'Column Listing of SASHELP.Demographics'; 
    proc contents data=sashelp.Demographics varnum; 
    run;
    title; 
    ods select default; 
 */ 

 /*     ----------------------------------------     */
 /* Browse/Review a few rows of the original data    */
 /*     ----------------------------------------     */
title 'sashelp.Demographics - Formatted';
proc print data=sashelp.Demographics(obs=10) noobs;
  var cont id iso name pop maleschoolpct femaleschoolpct; 
run;
title;
title 'sashelp.Demographics - UnFormatted';
proc print data=sashelp.Demographics(obs=10) noobs;
  var maleschoolpct femaleschoolpct; 
	format maleschoolpct femaleschoolpct;
run;
title;

 /*--------------------------------------------------*/
 /* Prepare a data set to use and then view it       */
 /* ------------------------------------------------ */
 /* Create unique, arbitrary CountryIDs to remove    */
 /* all Country identification for the purpose of    */
 /* this demonstration.                              */
 /*                                                  */
 /* Validate that there are unique CountryIDs        */
 /*                                                  */
 /* Calculate a new NePrimaryPct value that equates  */
 /* to the average of the two primary school         */
 /* enrollment ratios FemaleSchoolPct and            */
 /* MaleSchoolPct data as the input for the average  */
 /*                                                  */
 /* Then browse a sample of the resulting data set:  */
 /* Work.Education                                   */
 /*--------------------------------------------------*/

 /*     ----------------------------------------     */
 /* Create the unique IDs using the RAND function.   */
 /* The RAND function does not guarantee uniqueness, */
 /* but if the range is wide enough, there should be */
 /* no problem attaining unique values (see the      */
 /* SAS documentation for the RAND function for more */
 /* details).                                        */
 /*                                                  */
 /* Keep only columns needed for this demonstration  */
 /*     ----------------------------------------     */
data work.Education;
	CountryID = rand('integer',100000,999999);
  set sashelp.Demographics
	    (keep=pop maleschoolpct femaleschoolpct 
       rename=(pop=Population));
	NetPrimaryPct = round(sum(0,maleschoolpct,femaleschoolpct)/2,0.01);
	format NetPrimaryPct percent9.2;
run;

 /*     ----------------------------------------     */
 /* Validate Uniqueness of the new IDs               */
 /*     ----------------------------------------     */
title 'Count of Unique Countries: SASHELP.DEMOGRAPHICS';
proc freq data=sashelp.demographics order=freq nlevels;
  tables name / noprint;
run;
title 'Count of Unique Countries: WORK.EDUCATION';
proc freq data=work.education order=freq nlevels;
  tables countryid / noprint;
run;
title;

 /*     ----------------------------------------     */
 /* Browse/Review a few rows of the resulting data   */
 /* Remove formats so can see stored raw data values */
 /*     ----------------------------------------     */
title 'Work.Demographics - UnFormatted';
proc print data=work.Education;
  format maleschoolpct femaleschoolpct NetPrimaryPct;
run;
title;



 /*==============================================================*/
 /* Part TWO: Create Formats to use later with ODS Style options */
 /*           in a Proc Print:                                   */
 /* ------------------------------------------------------------ */
 /*		   BKG = Background color based on column values           */
 /*		   FRG = ForeGround/Font color based on column values      */
 /*		   WT  = Weight of the font based on column values         */
 /* ------------------------------------------------------------ */
 /* Colors and weights can be expressed many ways in ODS:        */
 /* - By SAS Color Names in the SAS Registry                     */
 /* - By RGB Color Code (Red Green Blue)                         */
 /*   In HEX there are 256 settings for each Hue (00-FF)         */
 /* - By HLS (HSL) Color Code (Hue Lightness Saturation)         */
 /*   In HEX H expresses this is an HLS code, followed by a hex  */
 /*   code representing an angle 0-360 degrees (or 000-168 hex), */
 /*   Blue=0 to Red=120 to Green=240 back to Blue at 360 degrees,*/
 /*   followed by percents 0%-100% broken into 256 hex levels    */
 /*   (00-FF)                                                    */
 /* - By Grey Scale Color (Hex 00-FF varying shades of grey)     */
 /* - There are others you can use with SAS                      */
 /*==============================================================*/
proc format;
  value bkg /* Background Color */
    0.7 -  1.0 	= 'light green' /* SAS Color Name */
    0.6 -< 0.7 	= 'yellow'      /* SAS Color Name */
	  0.5 -< 0.6 	= 'tomato'      /* SAS Color Name */
		0.0 -< 0.5  = gray00        /* Black in Gray Scale */
		0.0         = H00099FF      /* Blue in HSL */
    other    		= cxFFFFFF;     /* White in RGB */
  value frg /* Foreground Font Color */
    0.7 -  1.0	= 'black'
		0.5 -< 0.7	= 'dark blue'
		0.0 -< 0.5  = 'white'
    other   		= 'black';
  value wt  /* Font Weight */
    0.7 - 1.0		= 'medium'
		0.5 -< 0.7	= 'bold'
		0.0 -< 0.5  = 'extra_bold'
    other     	= 'medium';
run;



 /*==============================================================*/
 /* Part THREE: Create Report and Export to Excel                */
 /* ------------------------------------------------------------ */
 /* Proc Print is one of the SAS procedures where you can        */
 /* apply ODS style options (others are Proc Report and          */
 /* Proc Tabulate). This print demonstrates using ODS style      */
 /* options within the Proc Print (there are many more ODS style */
 /* options that can be applied to these procedures - the        */
 /* options applied here are a small sub-set of the options      */
 /* available to alter the visualization of your output). Used   */
 /* in this demonstration are options that apply to the data     */
 /* only. There are also options that can be applied to other    */
 /* report LOCATIONS (labels, headers, tables, etc.)             */
 /* ------------------------------------------------------------ */
 /* Additionally, the Proc Print is wrapped by ODS statements    */
 /* (these are often called the ODS SANDWICH set of statements)  */
 /* that will create a spreadsheet in an Excel workbook          */
 /* containing the results of the print including the ODS style  */
 /* options that were applied (for this example, there is some   */
 /* traffic lighting coloration of the results).                 */
 /* ------------------------------------------------------------ */
 /* In Version 1, the _ALL_ key word was used on the VAR         */
 /* statement so that all the variables have the same ODS        */
 /* options applied.                                             */
 /*                                                              */
 /* In Version 2, if it is desired to handle different variables */
 /* with different options, multiple VAR statements can be used  */
 /* in the Proc Print, with each VAR statement having different  */
 /* ODS options. VAR statements are adjunctive.                  */
 /*                                                              */
 /* In Version 3, both reports are run to a single ODS Excel     */
 /* workbook. This demonstrates that each procedure creates a    */
 /* separate worksheet in the Excel workbook.                    */
 /*                                                              */
 /* In Version 4, both reports are run to a single ODS Excel     */
 /* workbook. This demonstrates that both procedures are         */
 /* written to a single worksheet in the Excel workbook.         */
 /*==============================================================*/

 /*--------------------------------------------------*/
 /* Version 1 - apply the ODS style options to all   */
 /*             the variables being printed          */
 /*           - Embeds Titles into the worksheet     */
 /*           - Uses default output style: HTMLBlue  */ 
 /*           - Uses Default worksheet name          */
 /*                                                  */
 /* Styles that come with a SAS installation can be  */
 /* viewed in EG by accessing the Style Manager:     */
 /* Tools Menu Item --> Style Manager                */
 /*                                                  */
 /* All SAS user interfaces can run the following    */
 /* code to see the names of all the styles that     */
 /* come with SAS:                                   */
 /*     proc template;                               */
 /*       list styles;                               */
 /*     run;                                         */
 /*--------------------------------------------------*/
 /*
   proc template;
     list styles;
   run;
 */
title "Primary Education Enrollment by Country";
title2 "Highlight All Data";
ods excel file="&outpath\TrafficLightV1.xlsx"
    options(embedded_titles="yes");
proc print data=work.Education noobs;
	var _All_ / style(data)={font_weight=wt.
							             foreground=frg.
							             background=bkg.};
run;
ods excel close;
title;

 /*--------------------------------------------------*/
 /* Version 2 - apply the ODS style options to       */
 /*             specific variables only              */
 /*           - Embeds Titles into the worksheet     */
 /*           - Applies provided style: Harvest      */
 /*           - Freeze Row Headers in EXCEL          */ 
 /*           - Applies provided worksheet name:     */
 /*             EducationData                        */
 /*--------------------------------------------------*/
title "Primary Education Enrollment by Country";
title2 "Highlight Gender Percents Only";
ods excel file="&outpath\TrafficLightV2.xlsx"
    options(sheet_name='EducationData' embedded_titles="yes"
            frozen_headers="on") style=harvest;
proc print data=work.Education noobs;
  var countryid population NetPrimaryPct;
	var maleschoolpct femaleschoolpct /
      style(data)={font_weight=wt.
							     foreground=frg.
							     background=bkg.};
run;
ods excel close;
title;

 /*--------------------------------------------------*/
 /* Version 3 - Produce a single Excel workbook      */
 /*             containing 3 reports, each report    */
 /*             writing to a distinct worksheet in   */ 
 /*             the workbook.                        */
 /*           - Embeds Titles into the worksheet     */
 /*           - Applies provided style: Barrettsblue */
 /*           - Freeze Row Headers                   */ 
 /*           - Applies provided worksheet names:    */
 /*             EducationData_ALL & EducationData_MF */
 /*--------------------------------------------------*/
title "Primary Education Enrollment by Country";
title2 "Highlight All Data";
ods excel file="&outpath\TrafficLightV3.xlsx"
    options(sheet_name='EducationData_ALL' embedded_titles="yes"
            frozen_headers="on") style=barrettsblue;
proc print data=work.Education noobs;
	var _All_ / style(data)={font_weight=wt.
							             foreground=frg.
							             background=bkg.};
run;
title2 "Highlight Gender Percents Only";
ods excel options(sheet_name='EducationData_MF');
proc print data=work.Education noobs;
  var countryid population NetPrimaryPct;
	var maleschoolpct femaleschoolpct /
      style(data)={font_weight=wt.
							     foreground=frg.
							     background=bkg.};
run;
 /* With BarrettsBlue Style, note the
    background color change by changing
    the columns on the VAR statements   */
title2 "Highlight All Percents Only";
ods excel options(sheet_name='EducationData_Pct');
proc print data=work.Education noobs;
  var countryid population;
	var maleschoolpct femaleschoolpct NetPrimaryPct /
      style(data)={font_weight=wt.
							     foreground=frg.
							     background=bkg.};
run;
ods excel close;
title;

 /*--------------------------------------------------*/
 /* Version 4 - Produce a single Excel workbook      */
 /*             containing both reports, both        */
 /*             reports writing to a single          */ 
 /*             worksheet in the workbook.           */
 /*           - Embeds Titles into the worksheet     */
 /*           - Applies provided style: Ocean        */
 /*           - Add option to load both reports into */
 /*             a single worksheet:                  */
 /*             (sheet_interval="none")              */
 /*           - Freeze Row Headers (using column #)  */ 
 /*           - Applies provided worksheet name:     */
 /*             EducationData                        */
 /*--------------------------------------------------*/
title "Primary Education Enrollment by Country";
title2 "First Report: Highlight All Data";
title3 "Second Report: Highlight Only Gender Percents";
ods excel file="&outpath\TrafficLightV4.xlsx"
    options(sheet_name='EducationData' embedded_titles="yes"
            sheet_interval="none" frozen_headers="5") style=ocean;
proc print data=work.Education noobs;
	var _All_ / style(data)={font_weight=wt.
							             foreground=frg.
							             background=bkg.};
run;
proc print data=work.Education noobs;
  var countryid population NetPrimaryPct;
	var maleschoolpct femaleschoolpct /
      style(data)={font_weight=wt.
							     foreground=frg.
							     background=bkg.};
run;
ods excel close;
title;



 /*==============================================================*/
 /* Part FOUR - Push the same reports to a PDF file              */
 /*==============================================================*/

 /*--------------------------------------------------*/
 /* For PDF output, we want the report to have a     */
 /* landscape orientation and a date/time that is    */
 /* stamped on each page by default to be suppressed.*/ 
 /*                                                  */
 /* In this output, it is desired to have both       */
 /* reports be included in the single PDF file. A    */
 /* Table of Contents will be included and will      */
 /* present when the file is opened, with the report */
 /* nodes unexpanded.                                */
 /*                                                  */
 /* Additional Features for the PDF output:          */
 /* - Change the orientation to Landscape and        */
 /*   suppress the date/time from printing on the    */
 /*   PDF pages through an OPTIONS global session    */
 /*   statement                                      */ 
 /* - TOC Labels will be applied using the ODS       */
 /*   PROCLABEL statement                            */
 /* - The table of contents entries will not expand  */
 /*   and remain at a closed level (PDFTOC=1)        */
 /* - Each report will start at page #1              */
 /* - Apply provided style: NetDraw                  */
 /*                                                  */
 /* The Proc PRINT steps have not changed at all,    */
 /* and will still present with the TrafficLight     */
 /* data driven coloration in the PDF.               */ 
 /*--------------------------------------------------*/
/*options orientation=landscape dtreset;*/
options orientation=landscape nodate;
title "Primary Education Enrollment by Country";
title2 "Highlight All Data";
ods pdf file="&outpath\TrafficLight.pdf"
    pdftoc=1 style=netdraw;
ods proclabel "Education - All";
proc print data=work.Education noobs;
	var _All_ / style(data)={font_weight=wt.
							             foreground=frg.
							             background=bkg.};
run;
 /* reset page number back to 1 for second report */
options pageno=1; 
title2 "Highlight Gender Percents Only";
ods proclabel "Education - Gender";
proc print data=work.Education noobs;
  var countryid population NetPrimaryPct;
	var maleschoolpct femaleschoolpct /
      style(data)={font_weight=wt.
							     foreground=frg.
							     background=bkg.};
run;
 /* With NetDraw Style, note the background color
    by changing the columns on the VAR statements */
 /* reset page number back to 1 for second report */
options pageno=1; 
title2 "Highlight All Percents Only";
ods proclabel "Education - PCT";
proc print data=work.Education noobs;
  var countryid population;
	var maleschoolpct femaleschoolpct NetPrimaryPct /
      style(data)={font_weight=wt.
							     foreground=frg.
							     background=bkg.};
run;
ods pdf close;
title;
options orientation=portrait;



 /*==============================================================*/
 /* Part FIVE - Using HyperLink URLs in Style options            */
 /* First refer back to the slides at Slide #3                   */
 /* ------------------------------------------------------------ */
 /* Demonstate HyperLinking from a summary report HTML file, to  */
 /* detail report HTML files. With the help of the URL ODS Style */
 /* options to activate a Hyperlink, and a user-defined format   */
 /* to relate report data to a HTML file, the Hyperlink can be   */
 /* accomplished.                                                */
 /*==============================================================*/

 /*--------------------------------------------------*/
 /* In this example we are going to create a summary */
 /* report with URL links to more detailed reports.  */
 /*                                                  */
 /* Using the same input data, we will run a single  */
 /* SQL step to organize the data into Percentage    */
 /* groupings as well as summarize the data at the   */
 /* same time.                                       */
 /*                                                  */
 /* The groupings are percentage breakdowns:         */
 /*     >90, 80-90, 70-80, 60-70, 50-60, below 50,   */
 /*     and a group for countries with missing data  */
 /* The summarizations are:                          */
 /*     a count and an average for each group        */
 /* ------------------------------------------------ */
 /* Following the SQL step is a series of two steps: */
 /* a data step followed by a SQL step. This is      */
 /* provided for those people who are not SQL savvy. */
 /* This 2 step combination will result in the same  */
 /* group summarized data that will be used for the  */
 /* summary report be demonstrated.                  */
 /*--------------------------------------------------*/

 /*     ----------------------------------------     */
 /* Version 1 - a single SQL step                    */
 /* This Proc SQL step will perform both the         */
 /* grouping and the summarizing of the data all in  */
 /* a single step.                                   */
 /*     ----------------------------------------     */
proc sql;
  create table work.EducationSum as
  select case
           when (NetPrimaryPct >= 0.9)       then 'Group A 90+'
	         when (0.8 <= NetPrimaryPct < 0.9) then 'Group B 80'
			     when (0.7 <= NetPrimaryPct < 0.8) then 'Group C 70'
			     when (0.6 <= NetPrimaryPct < 0.7) then 'Group D 60'
			     when (0.5 <= NetPrimaryPct < 0.6) then 'Group E 50'
			     when (0.0 <  NetPrimaryPct < 0.5) then 'Group F <50'
	   			 when (NetPrimaryPct = 0.0)				 then	'Group G Missing'
					 else 'Group Z No-Grp'
         end as LitGrp,
	       count(NetPrimaryPct) as Count,
         round(avg(NetPrimaryPct),0.01) as AvgPct
		from work.Education
   group by LitGrp
   order by LitGrp;

	 select * from work.EducationSum;
quit;

 /*     ----------------------------------------     */
 /* Version 2 - A Data Step to group the data,       */
 /*             followed by either a Proc Means step */
 /*             or a SQL step to summarize.          */
 /* Here is the series of 2 steps to provide the     */
 /* same resulting summary data without using SQL.   */
 /* Run a Data Step to create Grouped data and push  */
 /* the result to a new data set: work.EducationGrp  */
 /*     ----------------------------------------     */
data work.EducationGrp;
  set work.Education;
	length LitGrp $15;
  select;
    when (NetPrimaryPct >= 0.9) 			LitGrp = 'Group A 90+';
    when (0.8 <= NetPrimaryPct < 0.9)	LitGrp = 'Group B 80';
    when (0.7 <= NetPrimaryPct < 0.8)	LitGrp = 'Group C 70';
    when (0.6 <= NetPrimaryPct < 0.7)	LitGrp = 'Group D 60';
	  when (0.5 <= NetPrimaryPct < 0.6)	LitGrp = 'Group E 50';
	  when (0.0 <  NetPrimaryPct < 0.5)	LitGrp = 'Group F <50';
	  when (NetPrimaryPct = 0.0)				LitGrp = 'Group G Missing';
		otherwise LitGrp = 'Group Z No-Grp';
	end;
run;

 /*     ----------------------------------------     */
 /* Using the grouped data set, work.EducationGrp,   */
 /* run a Proc Means step to summarize the data:     */
 /* generate Counts, and Averages per grouping.      */
 /*                                                  */
 /* Output the summary data to another new data set: */
 /* work.EducationSum                                */
 /*                                                  */
 /* NOTE: Be sure to validate the data set column    */
 /* names as they will be different than the         */
 /* columns generated as part of the printed results */
 /* that the MEANS procedure automatically produces. */
 /*     ----------------------------------------     */
proc means data=work.EducationGrp mean n nonobs maxdec=2;
  var NetPrimaryPct;
	class LitGrp;
	output out=work.EducationSum (keep=LitGrp AvgPct Count)
         mean=AvgPct n=Count;
	ways 1;
run;


 /*     ----------------------------------------     */
 /* As a 3rd alternative to generate the grouped     */
 /* summary data set, a Proc SQL step can be run     */
 /* instead of a Proc Means.                         */
 /*                                                  */
 /* Using the grouped data set, run a Proc SQL step  */
 /* to summarize the data: Counts, and Averages per  */
 /* grouping. Output the summary data to another new */
 /* data set: work.EducationSum                      */
 /*     ----------------------------------------     */
proc sql;
  create table work.EducationSum as
	select LitGrp,
	       count(NetPrimaryPct) as Count,
         round(avg(NetPrimaryPct),0.01) as AvgPct
		from work.EducationGrp
   group by LitGrp
   order by LitGrp;

	select * from work.EducationSum;
quit;

 /*     ----------------------------------------     */
 /* I have also provided a 4th alternative to create */
 /* both the WORK.EDUCATION and WORK.EDUCATIONSUM    */
 /* data sets all in a single DATA STEP. The code    */
 /* for this is below in this program in Part SIX.   */
 /*                                                  */
 /* It is provided as a reference, if interested,    */
 /* but will not be discussed in this presentation.  */
 /*     ----------------------------------------     */


 /*--------------------------------------------------*/
 /* Now comes the set up to create the detail        */
 /* reports that our summary report will contain as  */
 /* URL Hyperlinks within the summary report.        */
 /*                                                  */
 /* Create HTML output using the ODS HTML            */
 /* destination for each detail report. Each detail  */
 /* report will be filtered by various groupings.    */
 /* There will be a detail report file for each      */
 /* group saved in HTML format. When these are       */
 /* referenced from our summary report, they will    */
 /* present the web page (HTML file containing the   */
 /* detail report) of the detail data for the group. */
 /*                                                  */
 /* This code could easily be set up to use SAS      */
 /* Macro code producing a data driven process to    */
 /* generate all of the Proc Print steps, but for    */
 /* our purposes, the steps are hardcoded to view    */
 /* the steps being run. There are only 7 steps, so  */
 /* the hardcoded steps were not too tedious to put  */
 /* together.                                        */
 /*--------------------------------------------------*/
 /* For Windows:
    ods html close;
 */

 /* Group for >90% Literacy */
ods html path="&outpath" body="NetPrime90.html" style=BarrettsBlue;
title 'Primary School Enrollment - 90% and Above';
proc print data=work.Education noobs;
  var countryid population;
	var maleschoolpct femaleschoolpct NetPrimaryPct /
      style(data)={font_weight=wt.
							     foreground=frg.
							     background=bkg.};
  where NetPrimaryPct >= 0.9;
run;
title;
ods html close;
 /* Group for 80%-90% Literacy */
ods html path="&outpath" body="NetPrime80.html" style=BarrettsBlue;
title 'Primary School Enrollment - 80% to 89%';
proc print data=work.Education noobs;
  var countryid population;
	var maleschoolpct femaleschoolpct NetPrimaryPct /
      style(data)={font_weight=wt.
							     foreground=frg.
							     background=bkg.};
	where 0.8 <= NetPrimaryPct < 0.9;
run;
title;
ods html close;
 /* Group for 70%-80% Literacy */
ods html path="&outpath" body="NetPrime70.html" style=BarrettsBlue;
title 'Primary School Enrollment - 70% to 79%';
proc print data=work.Education noobs;
  var countryid population;
	var maleschoolpct femaleschoolpct NetPrimaryPct /
      style(data)={font_weight=wt.
							     foreground=frg.
							     background=bkg.};
	where 0.7 <= NetPrimaryPct < 0.8;
run;
title;
ods html close;
 /* Group for 60%-70% Literacy */
ods html path="&outpath" body="NetPrime60.html" style=BarrettsBlue;
title 'Primary School Enrollment - 60% to 69%';
proc print data=work.Education noobs;
  var countryid population;
	var maleschoolpct femaleschoolpct NetPrimaryPct /
      style(data)={font_weight=wt.
							     foreground=frg.
							     background=bkg.};
	where 0.6 <= NetPrimaryPct < 0.7;
run;
title;
ods html close;
 /* Group for 50%-60% Literacy */
ods html path="&outpath" body="NetPrime50.html" style=BarrettsBlue;
title 'Primary School Enrollment - 50% to 59%';
proc print data=work.Education noobs;
  var countryid population;
	var maleschoolpct femaleschoolpct NetPrimaryPct /
      style(data)={font_weight=wt.
							     foreground=frg.
							     background=bkg.};
	where 0.5 <= NetPrimaryPct < 0.6;
run;
title;
ods html close;
 /* Group for <50% Literacy */
ods html path="&outpath" body="NetPrimeLow.html" style=BarrettsBlue;
title 'Primary School Enrollment - Less than 50%';
proc print data=work.Education noobs;
  var countryid population;
	var maleschoolpct femaleschoolpct NetPrimaryPct /
      style(data)={font_weight=wt.
							     foreground=frg.
							     background=bkg.};
  where 0.0 < NetPrimaryPct < 0.5
    and NetPrimaryPct is not missing;
run;
title;
ods html close;
 /* Group where Literacy data was Missing */
ods html path="&outpath" body="NetPrime00.html" style=BarrettsBlue;
title 'Primary School Enrollment - Missing';
proc print data=work.Education noobs;
  var countryid population;
	var NetPrimaryPct /
      style(data)={font_weight=wt.
							     foreground=frg.
							     background=bkg.};
	var  maleschoolpct femaleschoolpct;
  where NetPrimaryPct = 0;
run;
title;
ods html close;

 /* For Windows:
    ods html;
 */


 /*--------------------------------------------------*/
 /* We will utilize a format to provide the URL      */
 /* hyperlinks to our detail reports. The format     */
 /* will be referenced on the appropriate data       */
 /* column in the summary report. The character      */
 /* based format will be called $LINK                */
 /*--------------------------------------------------*/
proc format;
	value $link 
	      'Group A 90+'			= 'NetPrime90.html'      
        'Group B 80'			= 'NetPrime80.html'
        'Group C 70'			= 'NetPrime70.html'
        'Group D 60'			= 'NetPrime60.html'
        'Group E 50'			= 'NetPrime50.html'
        'Group F <50'			= 'NetPrimeLow.html'
        'Group G Missing'	=	'NetPrime00.html';
run;


 /*--------------------------------------------------*/
 /* Time to create the summary report with the       */
 /* hyperlinks to our detail reports.                */
 /* ------------------------------------------------ */
 /* Again, using the ods HTML destination statement, */
 /* the summary report will run and output the Proc  */
 /* PRINT step to a HTML file.                       */
 /*                                                  */
 /* In the Proc PRINT, we are using the same         */
 /* techniques that we learned earlier. The one      */
 /* difference, is that we are adding the URL option */
 /* the to Style option on the variable LitGrp (this */
 /* columns holds the group values we assigned from  */
 /* the SQL step above). By then applying our format */
 /* on the URL option, the group values displayed on */
 /* the summary report will actually be hyperlinks   */
 /* to the other detail reports that we stored as    */
 /* files earlier as well. When these hyperlinks are */
 /* clicked, through the $Link format, the HTML      */
 /* files holding the detail reports will present in */
 /* the browser.                                     */
 /*--------------------------------------------------*/
ods html path="&outpath" body="NetPrime_Summary.html";
title 'Primary School Enrollment Summary';
title2 'Grouped by Overall Percent';
proc print data=work.EducationSum noobs;
  var LitGrp / style(data)={url=$link.};
  var Count;
	var AvgPct /
      style(data)={font_weight=wt.
							     foreground=frg.
							     background=bkg.};
run;
title;
ods html close;









 /*==============================================================*/
 /* Part SIX - Run a single Data Step that will result in both   */
 /* The original WORK.EDUCATION detail data set, and also the    */
 /* WORK.EDUCATIONSUM summary data set.                          */
 /* ------------------------------------------------------------ */
 /* This Data Step is a little more involved in terms off added  */
 /* logic, but it reads the SASHELP.DEMOGRAPHICS data only a     */
 /* single time to create the two data sets. Very Efficient!!    */
 /*==============================================================*/
data work.Education    (keep=CountryID Population NetPrimaryPct
                             FemaleSchoolPct MaleSchoolPct)
     work.EducationSum (keep=LitGrp Count AvgPct);
	CountryID = rand('integer',100000,999999);
	length LitGrp $15;
  set sashelp.Demographics
	    (keep=pop maleschoolpct femaleschoolpct
       rename=(pop=Population)) end=eof;
	NetPrimaryPct = round(sum(0,maleschoolpct,femaleschoolpct)/2,0.01);
  select;
    when (NetPrimaryPct >= 0.9) do;
			Grp90Sum + NetPrimaryPct;
			Grp90Cnt + 1;
		end;
    when (0.8 <= NetPrimaryPct < 0.9) do;
			Grp80Sum + NetPrimaryPct;
			Grp80Cnt + 1;
		end;
    when (0.7 <= NetPrimaryPct < 0.8) do;
			Grp70Sum + NetPrimaryPct;
			Grp70Cnt + 1;
		end;
    when (0.6 <= NetPrimaryPct < 0.7) do;
			Grp60Sum + NetPrimaryPct;
			Grp60Cnt + 1;
		end;
	  when (0.5 <= NetPrimaryPct < 0.6) do;
			Grp50Sum + NetPrimaryPct;
			Grp50Cnt + 1;
		end;
	  when (0.0 <  NetPrimaryPct < 0.5) do;
			GrpLowSum + NetPrimaryPct;
			GrpLowCnt + 1;
		end;
	  when (NetPrimaryPct = 0.0)	do;
			GrpMCnt + 1;
		end;
		otherwise do;
      GrpNoCnt + 1;
		end;
	end;
	output work.Education;
	select (eof);
	  when (1) do;
      LitGrp = 'Group A 90+';
		  AvgPct = round((Grp90Sum/Grp90Cnt), 0.01);
			Count  = Grp90Cnt;
			output work.EducationSum;
      LitGrp = 'Group B 80';
		  AvgPct = round((Grp80Sum/Grp80Cnt), 0.01);
			Count  = Grp80Cnt;
			output work.EducationSum;
      LitGrp = 'Group C 70';
		  AvgPct = round((Grp70Sum/Grp70Cnt), 0.01);
			Count  = Grp70Cnt;
			output work.EducationSum;
      LitGrp = 'Group D 60';
		  AvgPct = round((Grp60Sum/Grp60Cnt), 0.01);
			Count  = Grp60Cnt;
			output work.EducationSum;
      LitGrp = 'Group E 50';
		  AvgPct = round((Grp50Sum/Grp50Cnt), 0.01);
			Count  = Grp50Cnt;
			output work.EducationSum;
      LitGrp = 'Group F <50';
		  AvgPct = round((GrpLowSum/GrpLowCnt), 0.01);
			Count  = GrpLowCnt;
			output work.EducationSum;	
      LitGrp = 'Group G Missing';
			AvgPct = 0;
			Count  = GrpMCnt;
			output work.EducationSum;
    end;
		otherwise do;
		  if GrpNoCnt > 0  then do;
        LitGrp = 'Group Z No-Grp';
				Count  = GrpNoCnt;
				output work.EducationSum;
			end; /* if */
		end;   /* otherwise */
  end;     /* select */
run;


 /*==============================================================*/
 /* Part SEVEN - SAS Documentation References                    */
 /* ------------------------------------------------------------ */
 /* Here are some Navigations in the SAS Documentation to help   */
 /* find some pertinent information about using ODS Style        */
 /* Options with the SAS PRINT Procedure                         */
 /*==============================================================*/
 /*
   1) Use ODS Styles with Proc Print
      https://support.sas.com/documentation 
      -->	SAS Programming: SAS 9.4 and Viya 3.5
      --> Syntax - Quick Links
      -->	Procedures --> By Name
      -->	P
      --> Print
      Go to the Left-Hand Side Menu
      -->	Overview: Print Procedure
      -->	Usage: Print Procedure
      --> Use ODS Styles with Proc Print

      (https://go.documentation.sas.com/?cdcId=pgmsascdc&cdcVersion=
               9.4_3.5&docsetId=proc&docsetTarget=
               p19yo2oj9l1m58n1utb71ps1vf1b.htm&locale=en)

   --------------------------------------------------------------------

   2) ODS Style Attributes Values
      https://support.sas.com/documentation 
      -->	SAS Programming: SAS 9.4 and Viya 3.5
      Go to the Left-Hand Side Menu
      -->	Output and Graphics
      -->	Output Delivery System (ODS)
      -->	SAS Output Delivery System: User's Guide
      -->	ODS Styles Reference
      -->	Style Attributes
      -->	Style Attributes Values

      (https://go.documentation.sas.com/?cdcId=pgmsascdc&cdcVersion=
               9.4_3.5&docsetId=odsug&docsetTarget=
               p0jrvtifiwse7qn1kgce32eg83dl.htm&locale=en)

   --------------------------------------------------------------------

   3) Locations (or the parts of the report) that ODS Style Options 
      can affect with Proc Print
      https://support.sas.com/documentation 
      -->	SAS Programming: SAS 9.4 and Viya 3.5
      -->	Syntax - Quick Links
      -->	Procedures --> By Name
      -->	P
      -->	Print
      -->	Syntax - Proc Print <options> Statement Link
      -->	Go down the page to the section labeled: 
          Specifying Locations in the Style Option

      (https://go.documentation.sas.com/?cdcId=pgmsascdc&cdcVersion=
               9.4_3.5&docsetId=proc&docsetTarget=
               n17dcq1elcvpvkn1pkecj41cva6j.htm&locale=en)

   --------------------------------------------------------------------

   4) Dictionary of ODS Language Statements
      https://support.sas.com/documentation 
      -->	SAS Programming: SAS 9.4 and Viya 3.5
	    --> Scroll down to Output and Graphics
	    --> Select SAS Output Delivery System: User's Guide
	    --> ODS Statements
	    --> Dictionary of ODS Statements

      (https://go.documentation.sas.com/?cdcId=pgmsascdc&cdcVersion=
       9.4_3.5&docsetId=odsug&docsetTarget=
       p12kuaym0e53mpn1o818euwkk7pk.htm&locale=en)

   --------------------------------------------------------------------

   5) Color-Naming Schemes Explained 
      https://support.sas.com/documentation 
      -->	SAS Programming: SAS 9.4 and Viya 3.5
      Go to the Left-Hand Side Menu
      -->	Output and Graphics
      -->	ODS Graphics Suite
	    --> SAS Graph Template Language
	    --> SAS Graph Template Language: User's Guide
	    --> Appendixes
	    --> Display Attributes
	    --> Color-Naming Schemes

      (https://go.documentation.sas.com/?cdcId=pgmsascdc&cdcVersion=
       9.4_3.5&docsetId=grstatug&docsetTarget=
       p0edl20cvxxmm9n1i9ht3n21eict.htm&locale=en)
 */

 /* To see how SAS color names map to hex values */
proc registry list startat="COLORNAMES";
run;
