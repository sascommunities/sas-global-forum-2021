/******************************************************************************\
* 1136-2021: Modernizing Scenario Analysis with SAS Viya and Visual Analytics
*
* Name: MyJob Scoring Code.sas
*
* Purpose: This Model Scoring Code is used for the Pretzel Scenario Analysis dashboard.
*
* Author: Stu Sztukowski
*
* Parameters (macro variables): price | Sale price of jumbo pretzels
*                               cost  | Cost per bag of jumbo pretzels
*
* Input Data:  sashelp.snacks          | Dataset to modify and score
*              public.pretzel_forecast | Baseline pretzel forecast. Automatically created if it is not loaded to CASUSER.
* Output Data: public.pretzel_scenario | Promoted CAS table used by the Pretzel Scenario dashboard
*                                         located in /Public/Pretzel Scenario
*   
* Requirements: This program is expected to run from the Job Execution Service in Viya 3.4 or higher.
*
* History: 14APR2019 stsztu | v1.0 - Initial coding
*		   03JUN2021 stsztu | v1.1 - Final output goes to PUBLIC instead of CASUSER
*                                  - Append=force added in case char lengths change on import
\******************************************************************************/

/******* Setup *******/

/* Test values */
/* %let price = 2.49; */
/* %let cost  = .25; */

/* Start a CAS session */
cas;
libname public cas caslib='public';
libname casuser cas caslib='casuser';

/* Current datetime the user ran the scenario */
%let scenario_datetime = %sysfunc(datetime() );

/******* End Setup *******/

/* The below code will create an initial baseline forecast dataset if it does not yet exist in your CAS session.
   In practice, this table will likely always exist and will always be loaded.
*/
%if(%sysfunc(exist(public.pretzel_forecast)) = 0) %then %do;

    data pretzel_forecast_data;
        set sashelp.snacks;
        where     product = "Jumbo pretzel sticks" 
              AND date BETWEEN '01JAN2003'd AND '15JAN2004'd
        ;
    
       /* Shift the date to 2021 for demo purposes. You don't need to do this, but it's fun. */
       date = intnx('day', date, '17MAY2021'd-'01JAN2004'd);
    
    /*  Set future values to missing and modify the forecast time period */
       if(date > '17MAY2021'd) then call missing(QtySold);
    run;

    /* Produce a 2-week forecast */
    proc arima data=pretzel_forecast_data;
        identify var=QtySold crosscorr=(advertised price holiday) noprint;
        estimate p=(1 3 7) input=(advertised price) method=ml noprint;
        forecast lead=14 id=date out=casuser.outfor_forecast(replace=yes) noprint;
    run;

    /* Create an initial forecast dataset for Visual Analytics & scenario analysis */
    data public.pretzel_forecast(promote=yes);
        format forecast_date date9.;
        merge  casuser.outfor_forecast
               pretzel_forecast_data(keep=date advertised price holiday)
        ;
    
        forecast      = round(forecast);
        forecast_date = '17MAY2021'd;
        l95           = round(l95);
        u95           = round(u95);
        Cost          = 0.25;
        
        format qtysold cost price l95 u95 residual forecast dollar32.2;
    run;
%end;

/********* Begin Scenario Analysis Code *********/

/* If the user enters nothing, set the price/cost parameters */
%if(&price. =) %then %do;
    %let price = 2.49;
%end;

%if(&cost. =) %then %do;
    %let cost = .25;
%end;

/* Get the max date and date of forecast from the current scenario data.
   If the data does not exist, set a default value from sashep.snacks
*/
proc sql noprint;
    select max(date)
         , max(forecast_date)
    into :last_actual_date
       , :max_forecast_date
    from public.pretzel_forecast
    where NOT missing(QtySold)
    having forecast_date = max(forecast_date)
    ;
quit;

/* Step 1: Modify */
data pretzel_scenario_data;
    set sashelp.snacks;
    where     product = "Jumbo pretzel sticks" 
          AND date BETWEEN '01JAN2003'd AND '15JAN2004'd
    ;

    /* Shift the date to 2021 for demo purposes. You don't need to do this, but it's fun. */
   date = intnx('day', date, &last_actual_date.-'01JAN2004'd);

   /* Set future values to missing and modify the forecast time period */
   if(date > &last_actual_date.) then do;
       call missing(QtySold);
       Price = &price.;
       Cost  = &cost.;   
   end;
run;

/* Step 2: Score. Produce a 2-week forecast */
proc arima data=pretzel_scenario_data;
    identify var=QtySold crosscorr=(advertised price holiday) noprint;
    estimate p=(1 3 7) input=(advertised price) method=ml noprint;
    forecast lead=14 id=date out=casuser.outfor_scenario(replace=yes) nooutall noprint;
run;

/* Bring in the most recent forecast, current scenario, and current scenario input values */
data casuser.pretzel_scenario_append;
    length user $32.;
    format scenario_datetime datetime.;
    merge /* Original forecast and price. This typically would come from the original forecast data. */
          public.pretzel_forecast(keep  = date price cost forecast forecast_date
                                  where = (forecast_date = &max_forecast_date)
          )
 
          /* Scenario output forecast */
          casuser.outfor_scenario(keep   = date forecast l95 u95                             
                                  rename = (forecast = scenario_forecast
                                            l95       = scenario_l95
                                            u95       = scenario_u95
                                  )
                          
           )

          /* Scenario input values */
          pretzel_scenario_data(keep   = date price cost                                           
                                rename = (price = scenario_price 
                                          cost  = scenario_cost
                               )
          );
          
    by date;

    if(date > &last_actual_date.);

    /* Round these variables */
    array roundVars[*] forecast scenario_forecast scenario_l95 scenario_u95;
    
    /* Add the current datetime */
    scenario_datetime = &scenario_datetime.;

    /* Add the current user */
    user = "&SYS_COMPUTE_SESSION_OWNER.";
    
    /* Set negative values to 0 */
    if(scenario_forecast < 0 AND NOT missing(scenario_forecast) ) then scenario_forecast = 0;
    
    /* Round all variables defined in roundVars[*] */
    do i = 1 to dim(roundVars);
        roundVars[i] = round(roundVars[i]);
    end;
   
    drop i;

    format scenario_forecast scenario_price scenario_cost scenario_l95 scenario_u95 dollar32.2; 
run;

/* Step 3: Append the results to CAS. When appending, it is important to have
           both tables in CAS. If it does not yet exist, create the dataset
*/

%if(%sysfunc(exist(public.pretzel_scenario)) ) %then %do;
    data public.pretzel_scenario(append=force);
        set casuser.pretzel_scenario_append;
    run;
%end;
    %else %do;
        data public.pretzel_scenario;
            set casuser.pretzel_scenario_append;
        run;
    %end;

/* Permanently save the new results to disk */
proc casutil incaslib='public' outcaslib='public';
    save casdata='pretzel_scenario' replace;
run;