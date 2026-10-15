# Benin Agriculture Analysis (1961–2024)

## Overview

This project analyzes Benin's agricultural transformation over six decades using FAOSTAT data. It asks a simple question: has Benin's agricultural growth come from expanding farmland or from improving productivity?

The answer, based on the data, is that growth has been driven overwhelmingly by land expansion — despite a sharp increase in fertilizer and pesticide use since the 1990s.

## Research Question

**Has Benin's crop production growth been driven by area expansion or by yield improvement?**

Sub-questions:
1. How have production, area, and yield changed across Benin's major crops?
2. How have fertilizer and pesticide use changed over the same period?
3. Is there evidence of diminishing returns to input intensification?
4. Which crops show the strongest and weakest input-yield relationships?

## Data Sources

All data comes from FAOSTAT, the statistical database of the Food and Agriculture Organization:

| Domain | Code | Description |
|:---|:---|:---|
| Crops and Livestock Products | QCL | Production, area harvested, yield |
| Land Use | RL | Cropland, forest land |
| Fertilizers by Nutrient | RFN | Nitrogen, phosphate, potash |
| Pesticides Use | RP | Pesticide use by type |

Data is filtered to Benin (area code 53) and covers 1961–2024, with pesticide data starting in 1990.

## Tools

- **Python** — data download, statistical analysis
- **PostgreSQL** — data storage, joins, views
- **DataEase** — dashboard visualization
- **Git** — version control

## Data Analysis

### Q1: How have production, area, and yield changed?

The crop data comes in long format — each row is one element (production, area, or yield) for one crop-year. The first step is a pivot that turns those rows into columns:

```sql
CREATE OR REPLACE VIEW vegetables_analysis AS
SELECT
    "Item" AS crop,
    "Year"::int AS year,
    MAX(CASE WHEN "Element" = 'Production' THEN "Value"::numeric END) AS production_t,
    MAX(CASE WHEN "Element" = 'Area harvested' THEN "Value"::numeric END) AS area_ha,
    MAX(CASE WHEN "Element" = 'Yield' THEN "Value"::numeric END) AS yield_kg_ha
FROM crop_production
WHERE "Item" IN ('Cassava, fresh', 'Yams', 'Maize (corn)', ...)
GROUP BY "Item", "Year";
```
Then the growth for each crop is compared across years:

```sql
WITH pivoted AS (
    SELECT
        "Item" AS crop,
        MAX(CASE WHEN "Year" = '2014' THEN "Value"::numeric END) AS prod_2014,
        MAX(CASE WHEN "Year" = '2024' THEN "Value"::numeric END) AS prod_2024
    FROM crop_production
    WHERE "Element" = 'Production'
    GROUP BY "Item"
)
SELECT
    crop,
    prod_2024 - prod_2014 AS absolute_change,
    ROUND(100.0 * (prod_2024 - prod_2014) / NULLIF(prod_2014, 0), 2) AS pct_change
FROM pivoted
WHERE prod_2014 > 0 AND prod_2024 > 50000
ORDER BY pct_change DESC;
```

### Q2: How have fertilizer and pesticide use changed?

```sql
CREATE OR REPLACE VIEW fertilizer_yearly AS
SELECT
    "Year"::int AS year,
    SUM("Value"::numeric) AS fertilizer_t
FROM fertilizer_use
WHERE "Element" = 'Agricultural Use'
GROUP BY "Year"
ORDER BY year;
```

### Q3: Is there evidence of diminishing returns?

```python
for crop in df_clean["crop"].unique():
    X = sm.add_constant(sub[["fertilizer_t", "pesticide_t", "year"]])
    y = sub["yield_kg_ha"]
    model = sm.OLS(y, X).fit()
    results.append({
        "crop": crop,
        "coef_fert": model.params["fertilizer_t"],
        "pval_fert": model.pvalues["fertilizer_t"],
        "r_squared": model.rsquared
    })
```

### Q4: Which crops show the strongest and weakest input-yield relationships?

```python
area_contrib = (first["yield_kg_ha"] * area_change) / 1000
yield_contrib = (first["area_ha"] * yield_change) / 1000
total = abs(area_contrib) + abs(yield_contrib)
area_pct = round(100 * area_contrib / total, 1)
yield_pct = round(100 * yield_contrib / total, 1)
```

## Key Findings

### 1. Cropland quadrupled, forest halved

Benin's cropland grew from ~973,000 ha in 1961 to ~4,314,600 ha in 2024 (+343%). Over the same period, forest land fell from ~6,980,000 ha in 1990 to ~3,170,000 ha in 2024 (−55%). Approximately 68% of forest loss is explained by cropland expansion.

![Dashboard 1 — Overview](dataease/dashboard_1_overview.png)

### 2. Fertilizer and pesticide use surged after 2017

Fertilizer imports grew from ~35,000 t in 2000 to ~93,000 t in 2024. Pesticide use intensity quadrupled after 2016, reaching 2.06 kg/ha by 2024. Benin has no domestic fertilizer production - it is 100% import-dependent.

![Dashboard 2 — Inputs](dataease/dashboard_2_inputs.png)

### 3. Yields did not respond

Pooled correlation between yield and fertilizer is 0.03; between yield and pesticide, 0.05. Per-crop regression shows a statistically significant fertilizer effect only for soybeans. For 18 of 19 crops, input use has no detectable yield effect.

![Dashboard 3 — Efficiency](dataease/dashboard_3_efficiency.png)

### 4. Growth came from land, not productivity

For 12 of 19 crops, more than 80% of production growth came from area expansion rather than yield improvement. Only sorghum and chillies grew mainly through yield gains.

![Dashboard 4 — Decomposition](dataease/dashboard_4_decomposition.png)

## Repository Structure

.
├── Data harvesting/ # Python scripts for downloading FAOSTAT data
├── Table analysis/ # SQL files for pesticide, fertilizer, land use analysis
├── Final table/ # SQL files for analysis views
├── Stats/ # Jupyter notebook for statistical analysis
├── dataease/ # Dashboard images
└── README.md


## License

Data from FAOSTAT is licensed under CC BY 4.0. Analysis and code in this repository are released under the MIT License.