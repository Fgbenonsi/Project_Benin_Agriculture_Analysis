-- --------------------------------------------
-- Q1: How has cropland changed over time?
-- --------------------------------------------

SELECT
    "Year"::int AS year,
    "Value"::numeric AS cropland_ha
FROM land_use
WHERE "Item" = 'Cropland'
  AND "Element" = 'Area'
ORDER BY year;

-- --------------------------------------------
-- Q2: How has forest land changed over time?
-- --------------------------------------------

SELECT
    "Year"::int AS year,
    "Value"::numeric AS forest_ha
FROM land_use
WHERE "Item" = 'Forest land'
  AND "Element" = 'Area'
ORDER BY year;


-- --------------------------------------------
-- Q3: Is there a forest-to-cropland trade-off?
-- --------------------------------------------

SELECT
    "Year"::int AS year,
    MAX(CASE WHEN "Item" = 'Cropland' THEN "Value"::numeric END) AS cropland_1000ha,
    MAX(CASE WHEN "Item" = 'Forest land' THEN "Value"::numeric END) AS forest_1000ha
FROM land_use
WHERE "Item" IN ('Cropland', 'Forest land')
  AND "Element" = 'Area'
  AND "Year"::int BETWEEN 1990 AND 2024
GROUP BY "Year"
ORDER BY year;