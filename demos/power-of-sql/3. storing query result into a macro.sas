* storing SQL query in a macro;
*fetch data of a single row from a table into variables.;
LIBNAME dinner 'c:\dinner';
**********************************************************
MANUAL WORK - HARDCODING AVG(HEATSCALE)

**********************************************************;
TITLE 'Which Recipes Have A Moderate Heat Scale';

PROC SQL;
	SELECT * 
		FROM dinner.spices 
			WHERE heatscale <=3;
QUIT;




**********************************************************
BEING ACCURATE & GRABBING AVG(HEATSCALE) FROM THE DATA

**********************************************************;

Title 'What Is The Average Heatscale For All Dishes';

PROC SQL;
	SELECT avg(heatscale) 
		FROM dinner.spices;
QUIT;

TITLE 'Which Dishes Have A Heatscale Less Than The Average Of All Dishes';

PROC SQL;
	SELECT * 
		FROM dinner.spices 
			WHERE heatscale < 2.25;
QUIT;

***********************************************************
PRACTICAL USE OF MACRO TO REUSE DATA VALUE

**********************************************************;

PROC SQL NOPRINT;
	SELECT avg(heatscale) INTO: avgheat 
		FROM dinner.spices;
QUIT;
%PUT &avgheat;

%put &=avgheat;

TITLE "Recipes Where The Heat Scale Is Under The Average Heat Scale Of &avgheat";

PROC SQL;
	SELECT * 
		FROM dinner.spices 
			WHERE heatscale < &avgheat;
QUIT;

***********************************************************
SYNTAX 1 - STORE FIRST ROW OF SQL QUERY RESULT IN A MACRO

**********************************************************;

PROC SQL ;
	SELECT recipename INTO:lowheatrecipe 
		FROM dinner.spices 
			WHERE heatscale <=3;
QUIT;
	
%PUT &=lowheatrecipe;

***********************************************************
SYNTAX 2 - STORE MULTIPLE ROWS IN MULTIPLE MACRO VARIABLES

**********************************************************;

PROC SQL NOPRINT;
	SELECT recipename INTO :lowheat1 - :lowheat6 
		FROM dinner.spices 
			WHERE heatscale <=3;
QUIT;

%PUT &=lowheat1 &=lowheat2 &=lowheat3 &=lowheat4 &=lowheat5 &=lowheat6;




***********************************************************
SYNTAX 3 - STORE A LIST OF VALUES IN A MACRO VARIABLE

**********************************************************;
PROC SQL NOPRINT;
	SELECT recipename INTO :lowheatdish separated by ', '
		FROM dinner.spices
			WHERE heatscale <=3;
QUIT;
%PUT &=lowheatdish;

PROC SQL;
	SELECT * 
		FROM dinner.chef 
			WHERE NAME IN ("&lowheatdish");
QUIT;

PROC SQL NOPRINT;
	SELECT recipename format=$quote40. INTO :lowheatdish separated by ', ' 
		FROM dinner.spices 
			WHERE heatscale <=3;
QUIT;

%PUT &=lowheatdish;

TITLE 'Chefs That Make Low Heat Dishes';
PROC SQL;
	SELECT * 
		FROM dinner.chef 
			WHERE NAME IN (&lowheatdish);
QUIT;






