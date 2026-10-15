SELECT DISTINCT "Element" FROM fertilizer_use;



SELECT DISTINCT "Item" FROM fertilizer_use;

SELECT DISTINCT "Element" FROM pesticide_use;

SELECT DISTINCT "Item" FROM pesticide_use;



SELECT DISTINCT "Item" FROM land_use;
SELECT DISTINCT "Element" FROM land_use;



SELECT
    "Element",
    COUNT(*) AS n_rows,
    MIN("Year"::int) AS first_year,
    MAX("Year"::int) AS last_year
FROM fertilizer_use
GROUP BY "Element"
ORDER BY "Element";


CREATE OR REPLACE VIEW fertilizer_yearly AS
SELECT
    "Year"::int AS year,
    SUM("Value"::numeric) AS fertilizer_t
FROM fertilizer_use
WHERE "Element" = 'Agricultural Use'
GROUP BY "Year"
ORDER BY year;

SELECT *
FROM fertilizer_yearly