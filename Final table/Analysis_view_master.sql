CREATE OR REPLACE VIEW analysis_master AS
SELECT
    c.crop,
    c.year,
    c.production_t,
    c.area_ha,
    c.yield_kg_ha,
    f.fertilizer_t,
    p.pesticide_t
FROM vegetables_analysis c
LEFT JOIN fertilizer_yearly f ON c.year = f.year
LEFT JOIN pesticide_yearly p ON c.year = p.year;



SELECT * FROM analysis_master LIMIT 10;