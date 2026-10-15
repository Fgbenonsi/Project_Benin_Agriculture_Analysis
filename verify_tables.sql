SELECT 'crop_production' AS table_name, COUNT(*) FROM crop_production
UNION ALL
SELECT 'land_use', COUNT(*) FROM land_use
UNION ALL
SELECT 'fertilizer_use', COUNT(*) FROM fertilizer_use
UNION ALL
SELECT 'pesticide_use', COUNT(*) FROM pesticide_use;



SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name IN ('crop_production', 'land_use', 'fertilizer_use', 'pesticide_use')
ORDER BY table_name, ordinal_position;


SELECT DISTINCT "Element" FROM crop_production;

SELECT DISTINCT "Item" FROM crop_production
WHERE "Item" ILIKE '%vegetable%'
   OR "Item" ILIKE '%tomato%'
   OR "Item" ILIKE '%okra%'
   OR "Item" ILIKE '%pepper%'
   OR "Item" ILIKE '%onion%'
   OR "Item" ILIKE '%cabbage%'
   OR "Item" ILIKE '%carrot%'
ORDER BY "Item";


SELECT MIN("Year"::int) AS first_year,
       MAX("Year"::int) AS last_year,
       COUNT(DISTINCT "Year") AS num_years
FROM crop_production;

SELECT DISTINCT "Unit" FROM crop_production;



