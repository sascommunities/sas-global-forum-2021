* The JSON file this job expects contains the modified JSON message;
* that SAS Visual Analytics sent to the Data-Driven Content object.;
* It contains transformed data and additional column metadata.     ;

*==================================================================;
* Initialization;
*==================================================================;

* This allows for unconventional column names (e.g.: spaces, etc.);
options VALIDVARNAME=any;

* This allows for the stopOnError macro function to run the sas commands after an error occurs;
options NOSYNTAXCHECK;

%macro stopOnError(msg);
  %put &=SYSRC  &=SYSCC  &=SYSFILRC  &=SYSLIBRC  &=SYSERR  SYSERRORTEXT=%superq(syserrortext)  &=MSG;
  %if (&msg eq ) %then %let msg=%superq(syserrortext);
  %if (&syserr > 6 or &msg ne ) %then %do;
    proc json out=_webout nosastags nopretty nokeys;
	  write open object;
	  write values "success" false;
	  write values "retcode" &SYSERR;
	  write values "message" "&MSG";
	  write close;
	run;
    cas mySession terminate;
    %let SYSCC=0;
    %abort cancel;
  %end;
%mend stopOnError;

%macro checkParams;
	%if (not %symexist(castab)) %then %stopOnError(Missing parameter CASTAB);
%mend checkParams;
%checkParams;

* Connect to CAS and assign the CASUSER library;
options cashost="WNSASP02.vwfs.es" casport=5570;
cas mySession;
%stopOnError();

libname casuser CAS caslib="casuser";
%stopOnError();

* Retrieve JSON data from uploaded file;
filename vaJSON filesrvc "&_WEBIN_FILEURI";
%stopOnError();

* Use the JSON engine to provide read-only sequential access to JSON data;
libname jsonLib json fileref=vaJSON;
%stopOnError();

* Create table to assist creation of JSON map file;
* Replace blank spaces in column names with underscore (_);
* Output table contains column name, label, type, format, format width, and format precision;
%macro prepColMetadata;
  %if %sysfunc(exist(jsonLib.columns_format)) %then %do;
	proc sql noprint;
	  create table col_metadata as (
	    select 
	         c.ordinal_columns, translate(trim(c.label),'_',' ') as column, 
	         c.label, 
	         c.type4job as type,
	         f.name4job as fmt_name,
	         f.width4job as fmt_width,
	         f.precision4job as fmt_precision
	    from jsonLib.columns c left join jsonLib.columns_format f
	    on c.ordinal_columns = f.ordinal_columns
	  );
	quit;
	%stopOnError();
  %end;
  %else %do;
    * table columns_format does not exsist;
    * all columns are strings (no format object in the JSON structure);
	proc sql noprint;
	  create table col_metadata as (
	    select 
	         c.ordinal_columns, translate(trim(c.label),'_',' ') as column, 
	         c.label, 
	         c.type4job as type,
	         "" as fmt_name,
	         . as fmt_width,
	         . as fmt_precision
	    from jsonLib.columns c 
	  );
	quit;
	%stopOnError();
  %end;
%mend;

%prepColMetadata;

filename jmap temp lrecl=32767;
%stopOnError();

* Create JSON map file to be used to read VA JSON with proper labels, formats, types, etc.;
data _null_;
  file jmap;
  set col_metadata end=eof;
  if _n_=1 then do;
    put '{"DATASETS":[{"DSNAME": "data_formatted","TABLEPATH": "/root/data","VARIABLES": [';
  end;
  else do;
    put ',';
  end;
  if fmt_name ne "" then
    line=cats('{"PATH":"/root/data/element',ordinal_columns,
              '","NAME":"',column,
              '","LABEL":"',label,
              '","TYPE":"',type,
              '","FORMAT":["',fmt_name,'",',fmt_width,',',fmt_precision,']}');
  else
    line=cats('{"PATH":"/root/data/element',ordinal_columns,
              '","NAME":"',column,
              '","LABEL":"',label,
              '","TYPE":"',type,'"}');
  put line;
  if eof then do;
    put ']}]}';
  end;
run;
%stopOnError();

* Reassign JSON libname engine to provide read-only sequential access to JSON data, now with map;
libname jsonLib json fileref=vaJSON map=jmap;
%stopOnError();

*==================================================================;
* Main Processing;
*==================================================================; 

* Add table to CAS lib casuser (session scope);
data casuser.&CASTAB._TMP;
	set jsonLib.data_formatted;
run;
%stopOnError();

proc means data=casuser.&CASTAB._TMP(drop=bastidor) nway noprint;
class _character_;
var _numeric_;
output out=casuser.frek mean= / autoname;
run;
%stopOnError();

data _null_;
set casuser.&CASTAB._TMP(obs=1);
call symputx('endy', h_until);
call symputx('stepy', h_step);
run;	


data casuser.grid;
do meses=0 to &endy by &stepy;
kms=meses/12*30000;
output;
end;
run;
%stopOnError();

proc sql noprint;
create table work.gridder as 
select a.*, b.*
from casuser.frek a cross join casuser.grid b;
quit;
%stopOnError();

proc sql noprint;
create table WORK.gridded as 
select a.*, b.RV_Mean 
from work.gridder a left join 
(select gr_vr as gru, term, rv_mean
from CASUSER.TARIFAS_VR_COPY B
group by GR_VR 
having START_DATE=max(start_date) and valid) b 
on a.gr_vr=b.gru and a.meses=b.term;
quit;

options nofmterr;
data casuser.&CASTAB._TMP;
set casuser.&CASTAB._TMP (in=a) WORK.gridded(in=b);
format months mes_aplaz.;
origen="data";
if b then origen="grid";
months=meses;
meses_efectivos=put(meses, 8.1);
kms=ifn(lowcase(fuel_type)="diesel", kms, floor(kms*2/3));
label 
sales_res_mean="mean of sales result"
meses_mean="mean of meses"
kms_mean="mean of kms";
drop _freq_ _type_;
run;
%stopOnError();


* Put table on its final destination: casuser and global scope;
proc casutil;
  droptable casdata="&CASTAB" incaslib="casuser" QUIET;
  promote casdata="&CASTAB._TMP" incaslib="casuser" 
          casout="&CASTAB" outcaslib="casuser" DROP;
run;
quit;
%stopOnError();

*==================================================================;
* Finalization;
*==================================================================;

cas mySession terminate;

* The return code to is sent back to the calling client (Data-Driven Content object) in JSON format;
proc json out=_webout nosastags nopretty nokeys;
  write open object;
  write values "success" true;
  write values "retcode" 0;
  write values "message" "success";
  write close;
run;
