-- --------------------------------------------
-- Q1: Which fertilizer nutrient dominates in the last 10 years?
-- --------------------------------------------

SELECT
    "Item" AS nutrient,
    SUM("Value"::numeric) AS total_use_t,
    ROUND(
        100.0 * SUM("Value"::numeric) /
        SUM(SUM("Value"::numeric)) OVER (),
        2
    ) AS pct_of_total
FROM fertilizer_use
WHERE "Element" = 'Agricultural Use'
  AND "Year"::int >= 2015
GROUP BY "Item"
ORDER BY total_use_t DESC;


-- --------------------------------------------
-- Q2: How has each nutrient changed over the last 30 years?
-- --------------------------------------------

WITH filtered AS (
    SELECT
        "Year"::int AS year,
        "Item" AS nutrient,
        "Value"::numeric AS value_t
    FROM fertilizer_use
    WHERE "Element" = 'Agricultural Use'
      AND "Year"::int >= 1995
)
SELECT
    nutrient,
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
GROUP BY nutrient
ORDER BY pct_change DESC;


-- --------------------------------------------
-- QPTION A: Q3: How has fertilizer intensity per hectare changed over time?
-- --------------------------------------------

SELECT
    "Year"::int AS year,
    "Item" AS nutrient,
    ROUND("Value"::numeric, 3) AS fertilizer_kg_per_ha
FROM fertilizer_use
WHERE "Element" = 'Use per area of cropland'
  AND "Year"::int >= 1995
ORDER BY year, nutrient;

-- --------------------------------------------
-- OPTION B: Q3: How has fertilizer intensity per hectare changed over time?
-- --------------------------------------------

SELECT
    "Year"::int AS year,
    ROUND(SUM("Value"::numeric), 3) AS fertilizer_kg_per_ha
FROM fertilizer_use
WHERE "Element" = 'Use per area of cropland'
  AND "Year"::int >= 1995
GROUP BY "Year"
ORDER BY year;



-- --------------------------------------------
-- Q4: Is Benin producing fertilizer domestically or relying on imports?
-- --------------------------------------------

SELECT
    "Year"::int AS year,
    "Element",
    ROUND(SUM("Value"::numeric), 2) AS total_t
FROM fertilizer_use
WHERE "Element" IN ('Production', 'Import quantity', 'Export quantity')
  AND "Year"::int >= 2000
GROUP BY "Year", "Element"
ORDER BY year, "Element";