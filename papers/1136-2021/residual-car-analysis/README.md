# 1136-2021: Modernizing What-If Analysis with SAS Viya and Visual Analytics

Code and Example Data for the second part of the paper, "Advanced Scenario Topics in Visual Analytics."

## Description of Files

### code

- **MyDDCJob.sas**: SAS code to create a job that interfaces with Viya Data Driven Content. For more information, see "Using Data Driven Content to Create Scenario Data in Visual Analytics."
- **blackbox_explanation.sas**: SAS IML used to generate data for black-box model explanations. For more information, see "Unmasking Black-Box Alorithms."

### data

- **sales_data_simple.csv**: Sample simulated vehicle sales data for residual value analysis

## Software Version Requirements
Job and Code: Viya 3.4 or higher

## Instructions for Importing Data
Import the following files as promoted CAS tables to the CASUSER CASLIB:

- sales_data_simple.csv
