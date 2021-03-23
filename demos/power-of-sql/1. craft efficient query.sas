options nolabel;
***********************************************************
ASSIGN LIBRARY
**********************************************************;
libname dinner 'c:\dinner';

***********************************************************
SELECT COLUMNS FROM A TABLE
**********************************************************;

TITLE 'The Ingredients Dataset'; 
PROC SQL;
	SELECT *
		FROM dinner.ingredients
	;
QUIT;
%put rows=&sqlobs;

TITLE 'Dish Name, Fat Content And Spice Quotient From The Ingredients Dataset'; 
PROC SQL;
	SELECT Name, OilInTbsp, SpiceQuotient
		FROM dinner.ingredients
	;
QUIT;


***********************************************************
SUBSETTING DATA
**********************************************************;
TITLE 'Which dinners Are Low Fat - WHERE clause'; 
PROC SQL;
	SELECT *
		FROM dinner.ingredients
			WHERE OilInTbsp <=3
	;
QUIT;
%put rows=&sqlobs;

TITLE 'The Ingredients Dataset'; 
PROC SQL;
	SELECT name, oilintbsp, spicequotient
		FROM dinner.ingredients
	;
QUIT;

options label;

***********************************************************
GROUPING DATA
**********************************************************;

TITLE 'What Is The Average Fat Content for Each Level Of SpiceQuotient- GROUP BY'; 

PROC SQL;
	SELECT SpiceQuotient, avg(OilInTbsp) 'Average oil(in tbsp)' 
		FROM dinner.ingredients
			GROUP BY SpiceQuotient
	;
QUIT;

***********************************************************
SUBSETTING GROUPED DATA
***********************************************************;
TITLE 'Which SpiceQuotients Have An Average Oil Value >=4 - HAVING';
PROC SQL;
	SELECT SpiceQuotient, avg(OilInTbsp) AS AvgOil 'Average oil(in tbsp)' 
		FROM dinner.ingredients
			GROUP BY SpiceQuotient
				HAVING AvgOil ge 4
				
	;
QUIT;
%put &sqlobs;

***********************************************************
ORDERING DATA
**********************************************************;

TITLE 'What spice quotients have the max amt of fat - ORDER BY'; 
PROC SQL;
	SELECT SpiceQuotient, avg(OilInTbsp) AS AvgOil 'Average oil(in tbsp)' 
		FROM dinner.ingredients
			GROUP BY SpiceQuotient
				HAVING AvgOil <=4
					ORDER BY 2 desc
	;
QUIT;
