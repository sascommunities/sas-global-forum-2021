# 1136-2021: Modernizing Scenario Analysis with SAS Viya and Visual Analytics

Code and Example Data for 1136-2021: Modernizing What-If Analysis with SAS Viya and Visual Analytics. 

## Description of Folders

### pretzel-scenario-analysis
SAS scoring code, SAS job code, HTML interface code, data and a Visual Analytics 8.5 dashboard for the example discussed in the first part of the paper, "Creating a Job to Run Scoring Code from an Interface."

### residual-car-analysis
Example SAS code and data for the second part of the paper, "Advanced Scenario Topics in Visual Analytics."

## Software Version Requirements
Code: Viya 3.4 or higher

Reports: Visual Analytics 8.5 or higher

## Instructions for Importing Data
All data within the data folders are stored as .csv files. These files should be imported as promoted CAS tables in the CASUSER CASLIB. You can import these files with PROC IMPORT or directly through the Data Import tab within Visual Analytics.

## Instructions for Importing All Necessary SAS Files and Reports
Importing the JSON package within the code folder is the quickest way to install all necessary SAS files and jobs. All SAS jobs, code, and reports will be automatically imported to the /Public folder. See the below instructions starting at Step 2 for importing JSON packages to SAS Viya using the Import Wizard. You must be logged in as a SAS Administrator within SAS Environment Manager to import this package. 

https://go.documentation.sas.com/doc/en/calcdc/3.5/calpromotion/n0djzpossyj6rrn1vvi1wfvp2qhp.htm#p1h997oay4wsjon1uby6m99zzhsx

### If the JSON package cannot be imported
Individual SAS and HTML code are provided to manually add required code.

### Instructions for Importing Reports
If you are unable to import the JSON package, the Visual Analytics report may be manually imported. To manually import a Visual Analytics report, do the following:

1. Download the dashboard .txt file to your desktop
2. Log in to SAS Visual Analytics and enter Editor mode
3. Press Ctrl + Alt + B
4. In the pop-up box, click "Open" and select the dashboard .txt file
5. Click "Load"
6. Save the report to /Public
