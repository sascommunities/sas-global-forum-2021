libname dinner 'c:\dinner';

***********************************************************
INNER JOIN
**********************************************************;
TITLE 'Which Chefs Plan To Make Low Heat dinners - INNER JOIN ON'; 

PROC SQL;
	SELECT *
		FROM dinner.chef INNER JOIN
			dinner.spices
			ON chef.name=spices.Recipename
		WHERE heatscale <=3
	;
QUIT;

TITLE 'Which Chefs Plan To Make Low Heat dinners - INNER JOIN ON'; 

PROC SQL;
	SELECT *
		FROM dinner.chef as C INNER JOIN
			dinner.spices as S
			ON C.name=S.Recipename
		WHERE heatscale <=3
	;
QUIT;

***********************************************************
INNER JOIN - Alternative Syntax & An Efficiency Question
**********************************************************;
TITLE 'Which Chefs Plan To Make Low Heat dinneres - INNER JOIN ALTERNATIVE'; 

PROC SQL;
	SELECT *
		FROM dinner.chef as C, dinner.spices as S
		where C.name=S.Recipename
		AND heatscale <=3

	;
QUIT;
	%put &sqlobs;


***********************************************************
SUBQUERY
**********************************************************;
TITLE 'Which Of The Dinnners Is Moderate Heat-SUBQUERY'; 

*We'd Like To Ask The Chefs For Their Recipes;

proc sql;
	select recipename from dinner.spices
		where heatscale <=3 
	;
QUIT;


TITLE 'Here We Had To Type In Names Manually From The Results Of The Previous Query'; 
PROC SQL;
	SELECT *
		FROM dinner.chef
			where name IN ('Channa Masala',  
				'Chickpea Tacos', 
				'Portugese Chickpea Salad', 
				'Spanish Style Cod and Chickpeas ',
				'Zaatar Chickpeas', 
				'Chickpea Tuna Salad');
QUIT;

TITLE 'Using A Subquery To Join Tables';

PROC SQL;
	SELECT *
		FROM dinner.chef
			where name IN
				(select recipename from dinner.spices
					where heatscale <= 3)
	;

***********************************************************
INLINE VIEW
**********************************************************;
TITLE 'Using An Inline View To Join Tables';
PROC SQL;
	SELECT *
		FROM 
			(select * from dinner.spices where heatscale <= 3),
				dinner.chef
			where name=recipename;

QUIT;





*2.11 	INNER JOIN- if anyone has worked with 3 tables;
TITLE 'collecting information about low heat dinner'; 
PROC SQL;
	SELECT *
		FROM dinner.chef, dinner.ingredients, dinner.spices
		where chef.name=ingredients.name
		and ingredients.name=spices.Recipename
		AND heatscale <=3

	;
	%put &sqlobs;

	*2.12 using the ON clause-an efficiency question;
	PROC SQL;
	SELECT *
		FROM dinner.chef INNER JOIN
			dinner.ingredients
		ON chef.name=ingredients.name 
		INNER JOIN
		dinner.spices
		ON ingredients.name=spices.Recipename
		WHERE heatscale <=3

	;
*2.2 SUBQUERY;

	TITLE 'using a subquery to collect info on low fat dinner'; 
*I'm generally happy with the overall range of heat, and want  the average;
	proc sql;
	select recipename from dinner.spices
where heatscale < =3 
;
*I'd like to know which people are allocated dinner that 
have a spice rating greater than the average; 
*= vs IN;
PROC SQL;
	SELECT *
		FROM dinner.chef, dinner.ingredients
		where chef.name=ingredients.name
		AND chef.name IN
(select recipename from dinner.spices
where heatscale <= 3)
;

*2.3 Inline view;

PROC SQL;
	SELECT *
		FROM 
(select * from dinner.spices where heatscale <= 3) as spice
,dinner.chef, dinner.ingredients
		where chef.name=ingredients.name
		and chef.name=spice.recipename;

*show entity relationship diagram again if confused
		results all the variables and 5 rows;

*****
		*2.11 	INNER JOIN;
TITLE 'collecting information about low heat dinner'; 
PROC SQL;
	SELECT *
		FROM dinner.chef, dinner.spices
		where chef.name=spices.Recipename
		AND heatscale <=3

	;
	%put &sqlobs;

	*2.12 using the ON clause-an efficiency question;
	PROC SQL;
	SELECT *
		FROM dinner.chef INNER JOIN
			dinner.spices
		ON chef.name=spices.Recipename
		WHERE heatscale <=3

	;
*2.2 SUBQUERY;

	TITLE 'using a subquery to collect info on low fat dinner'; 
*I'm generally happy with the overall range of heat, and want  the average;
	proc sql;
	select recipename from dinner.spices
where heatscale < =3 
;
*I'd like to know which people are allocated dinner that 
have a spice rating greater than the average; 
*= vs IN;
PROC SQL;
	SELECT *
		FROM dinner.chef
		where chef.name IN
(select recipename from dinner.spices
where heatscale <= 3)
;

*2.3 Inline view;

PROC SQL;
	SELECT *
		FROM 
(select * from dinner.spices where heatscale <= 3) as spice
,dinner.chef
		where chef.name=spice.recipename;

*show entity relationship diagram again if confused
		results all the variables and 5 rows;




