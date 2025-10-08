# World Life Expectancy (Data Cleaning)

# Step 1 - Import data twice and save one as 'raw data'
SELECT *
FROM world_life_expectancy;


# Step 1 - Import data twice and save one as 'raw data'



# Step 2 - Look for duplicates
#		Every country should have only one year, Afghanistan 2016  , Afghanistan 2015 

SELECT *
FROM world_life_expectancy;


SELECT count(concat(country , year))
FROM world_life_expectancy
;
 
SELECT concat(country , year)
FROM world_life_expectancy
GROUP BY concat(country , year)
HAVING count( concat(country , year)) > 1;
;

#      By concating the country and year into a single entity, we have found the duplicates 
#               'Ireland2022'
#               'Senegal2009'
#              'Zimbabwe2019'
#      Now we need to determine the row_id for those three by using Row_NUM to get the count of 2 

SELECT row_id, 
		concat(country , year),
        ROW_NUMBER() OVER(PARTITION BY concat(country,year) 
        ORDER BY  concat(country,year) )as ROW_NUM
    FROM world_life_expectancy;

SELECT * 
FROM (SELECT row_id, 
		concat(country , year),
        ROW_NUMBER() OVER(PARTITION BY concat(country,year) 
        ORDER BY  concat(country,year) ) as ROW_NUM
		FROM world_life_expectancy) as code
    WHERE row_NUM>1;
    
    #   Now we can delete them,  Done and checked.
    
    
    DELETE FROM world_life_expectancy
    WHERE row_id  IN (
		SELECT ROW_id 
			FROM (SELECT row_id, 
		concat(country , year),
        ROW_NUMBER() OVER(PARTITION BY concat(country,year) 
        ORDER BY  concat(country,year) ) as ROW_NUM
		FROM world_life_expectancy) as code
    WHERE row_NUM>1 );
    
    

    
# Step 3 standardize data 

SELECT *
FROM world_life_expectancy;

#  A.  Find nulls in status column.  Determine logic and fill if possible. In this case, looing at other years the country is defind as developiong or developed in all instances.

SELECT *
FROM world_life_expectancy
WHERE status = '' or status IS NULL;

# the country and years below have nothing for status. 
#	Afghanistan	2014	
#	Albania	2021	
#	Georgia	2012	
#	Georgia	2010	
#	United States of America	2021	
#	Vanuatu	2020	
#	Zambia	2016	
#	Zambia	2012	
#  They are all Developing except for the United States.  So will replace all Nulls with developing than go back TO fix united states.

UPDATE world_life_expectancy
SET status = 'Developing'
WHERE status = '' or status IS NULL;

UPDATE world_life_expectancy
SET status = 'Developed'
WHERE Country = 'United States of America' and Year = '2021';


SELECT *
FROM world_life_expectancy
WHERE Country ='Afghanistan' and year='2014' or
Country ='Albania'	and year='2021'	or
Country ='Georgia'	and year='2012'	or
Country ='Georgia'	and year='2010'	or
Country ='United States of America'	and year='2021'	or
Country ='Vanuatu'	and year='2020'	or
Country ='Zambia'	and year='2016'	or
Country ='Zambia'	and year='2012';

# Changed and checked

#   B. Find nulls in Life expectancy.  Determine logic and fill if possible.  In this case, take average of life expectancy in preceeding and post the year.

select *
From world_life_expectancy;

ALTER TABLE world_life_expectancy
RENAME COLUMN `Life expectancy` to `Life_expectancy`;

SELECT *
FROM world_life_expectancy
WHERE Life_expectancy = '' or Life_expectancy IS NULL;

# The following two had nothing for life expectancy.
#	Afghanistan	2018	Developing		275
#	Albania	2018	Developing		88

select *
From world_life_expectancy
Where country = 'Afghanistan' OR country = 'Albania' ;

# Checking to make sure its okay, replace the missing life expectancy by taking the average of the life expectancies  on either side of the missing one.

SELECT t1.Country, t1.Year, t1.Life_expectancy,t2.Country, t2.Year, t2.Life_expectancy
From world_life_expectancy t1
	JOIN world_life_expectancy t2
on t2.year = t1.year + 1
WHERE t1.country='Afghanistan'
;

SELECT t1.Country, t1.Year, t1.Life_expectancy,t2.Country, t2.Year, t2.Life_expectancy,t3.country, t3.Year, t3.Life_expectancy
From world_life_expectancy t1
	JOIN world_life_expectancy t2 
		ON t2.year = t1.year + 1 
	JOIN world_life_expectancy t3
		ON t3.year = t1.year - 1
WHERE t1.country='Afghanistan' AND t2.country='Afghanistan' AND t3.country='Afghanistan';

