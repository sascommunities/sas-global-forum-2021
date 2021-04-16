/******************************************************************************\
* 1136-2021: Modernizing Scenario Analysis with SAS Viya and Visual Analytics
*
* Name: MyJob
*
* Purpose: This Viya Job is used for the Pretzel Scenario Analysis dashboard 
*          and performs two functions:
*
*           1. Creates an HTML form input for users 
*           2. Runs scoring code in /Public/Scoring Code.sas
*           3. Displays a result webpage
*
* Author: Stu Sztukowski
*
*             Name            Type      |  Value
* Parameters: _action       | Character |  form
*             _output_type  | Character |  html
*             price         | Numeric   |  2.49
*             cost          | Numeric   |  0.25
*
* Programs: /Public/MyJob Scoring Code.sas | Model Scoring Code
*
* Output: HTML result page
*
* History: 14APR2021 | v1.0 - Initial coding
*
\******************************************************************************/

/* The scoring code is saved in the Viya Files Service (/Public/MyJob Scoring Code.sas).
   The filesrvc engine connects the SAS Programming Runtime Environment (SPRE)
   to the Viya Files Service
*/
filename code filesrvc
    folderpath="/Public";

/* Run the Scoring Code program */
%include code('MyJob Scoring Code.sas');

/* Display a result webpage the end of the job */
data _null_;
    length line $32767.;

    file _webout; /* _webout will display HTML to the user since the parameter _output_type=html */
    input;        /* Read the HTML from the datalines4 statement */
    
    line = resolve(_INFILE_); /* Treat all &-prefixed data as macro variables */
    
    put line;     /* Write to _webout */
    
    datalines4;
<html lang="en">
    <head>
        <style type="text/css">
            @font-face {
              font-family:AvenirNext;
              src:url("/SASJobExecution/images/AvenirNextforSAS.woff") format("woff");
            }
            
            body {
              font-family: AvenirNext,Helvetica,Arial,sans-serif;
              text-rendering: optimizeLegibility;
              -webkit-tap-highlight-color: rgba(0,0,0,0);
              text-align: center
            }
        </style>
    </head>
    
    <body>
        <p>Pretzel modification successful.</p>
        <br/>
        <a href="/SASJobExecution/?_program=&_program">Go back</a>
    </body>
</html>
;;;;
run;
