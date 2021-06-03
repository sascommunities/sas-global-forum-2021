# 1136-2021: Modernizing Scenario Analysis with SAS Viya and Visual Analytics

Code and Example Data for the first part of the paper, "Creating a Job to Run Scoring Code from an Interface."

## Description of Files

### code

- **MyJob HTML Form.html**: HTML interface code for MyJob
- **MyJob Scoring Code.sas**: SAS model scoring code for MyJob
- **MyJob.sas**: Raw SAS code used in MyJob
- **Pretzel Scenario Analysis.json**: Viya JSON package containing the Viya Job MyJob, model scoring code, and Visual Analytics dashboard. All files are pre-configured.
- **Pretzel Scenario VA 85 Dashboard.txt**: Visual Analytics dashboard XML

### data

- **pretzel_forecast.csv**: Baseline forecast data
- **pretzel_scenario.csv**: Initial scenario for the dashboard

## Software Version Requirements
Job and Code: Viya 3.4 or higher

Report: Visual Analytics 8.5 or higher

## Instructions for Importing Data
Import the following files as promoted CAS tables to the CASUSER CASLIB:

- pretzel_forecast.csv
- pretzel_scenario.csv

These files should not be renamed. 

## Instructions for Importing All Necessary SAS Files and Reports
Importing Pretzel Scenario Analysis.json is the quickest way to install all necessary SAS files and jobs. All SAS jobs, code, and reports will be automatically imported to the /Public folder. See the below instructions starting at Step 2 for importing JSON packages to SAS Viya using the Import Wizard. You must be logged in as a SAS Administrator within SAS Environment Manager to import this package. 

https://go.documentation.sas.com/doc/en/calcdc/3.5/calpromotion/n0djzpossyj6rrn1vvi1wfvp2qhp.htm#p1h997oay4wsjon1uby6m99zzhsx

### If Pretzel Scenario Analysis.json cannot be imported
Individual SAS and HTML code are provided to manually add required code to the Viya Job MyJob. MyJob will need to be created and its parameters added accordingly. Please see the paper for configuration instructions.

### Instructions for Importing Reports
If you are unable to import the JSON package, the Visual Analytics report can be manually imported. To manually import a Visual Analytics report, do the following:

1. Download Pretzel Scenario VA 85 Dashboard.txt to your desktop
2. Log in to SAS Visual Analytics and enter Editor mode
3. Press Ctrl + Alt + B
4. In the pop-up box, click "Open" and select the dashboard .txt file
5. Click "Load"
6. Save the report to /Public
