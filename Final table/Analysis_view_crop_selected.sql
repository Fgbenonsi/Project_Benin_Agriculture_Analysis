----Step 1: Look at the Distribution of Production Values

SELECT
    MIN("Value"::numeric) AS min_prod,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY "Value"::numeric) AS p25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY "Value"::numeric) AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY "Value"::numeric) AS p75,
    MAX("Value"::numeric) AS max_prod
FROM crop_production
WHERE "Element" = 'Production'
  AND "Year" = '2024'
  AND "Item" NOT ILIKE '%Primary%'
  AND "Item" NOT ILIKE '%n.e.c.%';


----how many crops survive each cutoff

SELECT
    COUNT(*) FILTER (WHERE "Value"::numeric > 1000) AS above_1k,
    COUNT(*) FILTER (WHERE "Value"::numeric > 10000) AS above_10k,
    COUNT(*) FILTER (WHERE "Value"::numeric > 50000) AS above_50k,
    COUNT(*) FILTER (WHERE "Value"::numeric > 100000) AS above_100k
FROM crop_production
WHERE "Element" = 'Production'
  AND "Year" = '2024'
  AND "Item" NOT ILIKE '%Primary%'
  AND "Item" NOT ILIKE '%n.e.c.%';


------growth query with the 50,000 t threshold and a 10-year window (2014 → 2024)
WITH recent AS (
    SELECT
        "Item" AS crop,
        "Year"::int AS year,
        "Value"::numeric AS production_t
    FROM crop_production
    WHERE "Element" = 'Production'
      AND "Year"::int IN (2014, 2024)
      AND "Item" NOT ILIKE '%Primary%'
      AND "Item" NOT ILIKE '%n.e.c.%'
),
pivoted AS (
    SELECT
        crop,
        MAX(CASE WHEN year = 2014 THEN production_t END) AS prod_2014,
        MAX(CASE WHEN year = 2024 THEN production_t END) AS prod_2024
    FROM recent
    GROUP BY crop
)
SELECT
    crop,
    prod_2014,
    prod_2024,
    prod_2024 - prod_2014 AS absolute_change,
    ROUND(100.0 * (prod_2024 - prod_2014) / NULLIF(prod_2014, 0), 2) AS pct_change
FROM pivoted
WHERE prod_2014 IS NOT NULL
  AND prod_2024 IS NOT NULL
  AND prod_2014 > 0
  AND prod_2024 > 50000
ORDER BY pct_change DESC;



----Step 6: Create the Analysis View

CREATE OR REPLACE VIEW vegetables_analysis AS
SELECT
    "Item" AS crop,
    "Year"::int AS year,
    MAX(CASE WHEN "Element" = 'Production' THEN "Value"::numeric END) AS production_t,
    MAX(CASE WHEN "Element" = 'Area harvested' THEN "Value"::numeric END) AS area_ha,
    MAX(CASE WHEN "Element" = 'Yield' THEN "Value"::numeric END) AS yield_kg_ha
FROM crop_production
WHERE "Item" IN (
    'Soya beans',
    'Karite nuts (sheanuts)',
    'Sorghum',
    'Rice',
    'Cow peas, dry',
    'Okra',
    'Sweet potatoes',
    'Seed cotton, unginned',
    'Chillies and peppers, green (Capsicum spp. and Pimenta spp.)',
    'Maize (corn)',
    'Pineapples',
    'Groundnuts, excluding shelled',
    'Onions and shallots, dry (excluding dehydrated)',
    'Oil palm fruit',
    'Cassava, fresh',
    'Sugar cane',
    'Cashew nuts, in shell',
    'Yams',
    'Tomatoes'
)
GROUP BY "Item", "Year";


SELECT COUNT(*) AS rows, COUNT(DISTINCT crop) AS crops, MIN(year) AS first, MAX(year) AS last
FROM vegetables_analysis;






SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;