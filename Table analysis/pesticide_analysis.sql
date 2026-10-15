-- --------------------------------------------
-- Q1: Cumulative pesticide use in the last 10 years
-- --------------------------------------------

SELECT
    "Item" AS pesticide_type,
    SUM("Value"::numeric) AS total_use_t,
    ROUND(
        100.0 * SUM("Value"::numeric) /
        SUM(SUM("Value"::numeric)) OVER (),
        2
    ) AS pct_of_total
FROM pesticide_use
WHERE "Element" = 'Agricultural Use'
  AND "Item" <> 'Pesticides (total)'
  AND "Year"::int >= 2020
GROUP BY "Item"
ORDER BY total_use_t DESC;



-- --------------------------------------------
-- Q2: Pesticide mix change over the last 30 years
-- --------------------------------------------

WITH filtered AS (
    SELECT
        "Year"::int AS year,
        "Item" AS pesticide_type,
        "Value"::numeric AS value_t
    FROM pesticide_use
    WHERE "Element" = 'Agricultural Use'
      AND "Item" <> 'Pesticides (total)'
      AND "Year"::int >= 1995
)
SELECT
    pesticide_type,
    MIN(year) AS first_year,
    MAX(year) AS last_year,
    MAX(CASE WHEN year = (SELECT MIN(year) FROM filtered) THEN value_t END) AS first_year_use,
    MAX(CASE WHEN year = (SELECT MAX(year) FROM filtered) THEN value_t END) AS last_year_use,
    ROUND(
        100.0 * (
            MAX(CASE WHEN year = (SELECT MAX(year) FROM filtered) THEN value_t END) -
            MAX(CASE WHEN year = (SELECT MIN(year) FROM filtered) THEN value_t END)
        ) / NULLIF(MAX(CASE WHEN year = (SELECT MIN(year) FROM filtered) THEN value_t END), 0),
        2
    ) AS pct_change
FROM filtered
GROUP BY pesticide_type
ORDER BY pct_change DESC;



-- --------------------------------------------
-- Q3: How has pesticide intensity per hectare changed over time?
-- --------------------------------------------

SELECT
    "Year"::int AS year,
    ROUND("Value"::numeric, 3) AS pesticide_kg_per_ha
FROM pesticide_use
WHERE "Element" = 'Use per area of cropland'
  AND "Item" = 'Pesticides (total)'
  AND "Year"::int >= 1995
ORDER BY year;




CREATE OR REPLACE VIEW pesticide_yearly AS
SELECT
    "Year"::int AS year,
    SUM("Value"::numeric) AS pesticide_t
FROM pesticide_use
WHERE "Element" = 'Agricultural Use'
  AND "Item" = 'Pesticides (total)'
GROUP BY "Year"
ORDER BY year;