-- =========================================================
-- STEP 5: ADVANCED BUSINESS ANALYSIS
-- Procurement Spend & Profit Recovery Analytics
-- =========================================================

USE ProcurementAnalytics;
-- Analysis #1 — Supplier Spend Concentration
USE ProcurementAnalytics;
SELECT DATABASE();
SELECT
    supplier_id,
    supplier_name,
    total_spend,
    spend_crore,

    ROUND(
        100 * total_spend /
        SUM(total_spend) OVER (),
        2
    ) AS spend_percentage

FROM vw_supplier_spend

ORDER BY total_spend DESC;

-- Analysis #2 — Top 10 Supplier Concentration
SELECT
    ROUND(
        100 *
        SUM(total_spend) /
        (
            SELECT SUM(total_spend)
            FROM vw_supplier_spend
        ),
        2
    ) AS top_10_supplier_spend_percentage
FROM
(
    SELECT
        supplier_id,
        total_spend
    FROM vw_supplier_spend
    ORDER BY total_spend DESC
    LIMIT 10
) AS top_suppliers;

-- Analysis #3 — Supplier Spend + Delivery Performance
SELECT
    s.supplier_id,
    s.supplier_name,

    s.total_spend,

    d.delivered_items,
    d.late_items,
    d.on_time_items,

    d.avg_delay_days,
    d.max_delay_days,
    d.late_delivery_percentage

FROM vw_supplier_spend s

JOIN vw_delivery_performance d
    ON s.supplier_id = d.supplier_id

ORDER BY
    s.total_spend DESC;
    
-- Analysis #4 — High-Spend + Poor Delivery Suppliers
SELECT
    s.supplier_id,
    s.supplier_name,

    ROUND(
        s.total_spend / 10000000,
        2
    ) AS spend_crore,

    d.delivered_items,
    d.late_delivery_percentage,
    d.avg_delay_days

FROM vw_supplier_spend s

JOIN vw_delivery_performance d
    ON s.supplier_id = d.supplier_id

WHERE
    s.total_spend >
    (
        SELECT AVG(total_spend)
        FROM vw_supplier_spend
    )

AND d.late_delivery_percentage >= 50

ORDER BY
    s.total_spend DESC;

-- Analysis #5 — High Spend + Late +Poor Quality
SELECT
    s.supplier_id,
    s.supplier_name,

    ROUND(
        s.total_spend / 10000000,
        2
    ) AS spend_crore,

    d.late_delivery_percentage,
    d.avg_delay_days,

    q.rejection_rate_percentage

FROM vw_supplier_spend s

JOIN vw_delivery_performance d
    ON s.supplier_id = d.supplier_id

JOIN vw_supplier_quality q
    ON s.supplier_id = q.supplier_id

WHERE
    s.total_spend >
    (
        SELECT AVG(total_spend)
        FROM vw_supplier_spend
    )

AND d.late_delivery_percentage >= 50

AND q.rejection_rate_percentage >= 3.5

ORDER BY
    s.total_spend DESC;
    
-- Analysis #7 — Contract Leakage by Supplier
SELECT
    supplier_id,
    supplier_name,

    ROUND(
        SUM(
            CASE
                WHEN contract_id IS NULL
                THEN line_spend/10000000
                ELSE 0
            END
        ),
        2
    ) AS non_contract_spend,

    ROUND(
        100 *
        SUM(
            CASE
                WHEN contract_id IS NULL
                THEN line_spend
                ELSE 0
            END
        )
        /
        NULLIF(SUM(line_spend), 0),
        2
    ) AS non_contract_percentage

FROM vw_procurement_spend

GROUP BY
    supplier_id,
    supplier_name

ORDER BY
    non_contract_spend DESC;
    
-- Analysis #8 — Non-Contract Spend by Category
SELECT
    category_id,
    category_name,

    ROUND(
        SUM(
            CASE
                WHEN contract_id IS NULL
                THEN line_spend
                ELSE 0
            END
        ) / 10000000,
        2
    ) AS non_contract_spend_crore,

    ROUND(
        100 *
        SUM(
            CASE
                WHEN contract_id IS NULL
                THEN line_spend
                ELSE 0
            END
        )
        /
        NULLIF(SUM(line_spend), 0),
        2
    ) AS non_contract_percentage

FROM vw_procurement_spend

GROUP BY
    category_id,
    category_name

ORDER BY
    non_contract_spend_crore DESC;
    
-- Analysis #9 — Biggest Price Recovery Opportunities
SELECT
    product_id,
    product_name,

    SUM(quantity) AS total_quantity,

    ROUND(
        SUM(quantity * unit_price),
        2
    ) AS actual_spend,

    ROUND(
        SUM(potential_savings),
        2
    ) AS potential_savings

FROM vw_price_variance

GROUP BY
    product_id,
    product_name

ORDER BY
    potential_savings DESC

LIMIT 20;

-- Analysis #10 — Total Potential Price Recovery
SELECT
    ROUND(
        SUM(potential_savings),
        2
    ) AS total_potential_savings,

    ROUND(
        SUM(potential_savings) / 10000000,
        2
    ) AS potential_savings_crore

FROM vw_price_variance;

-- Analysis #11 — Products With Extreme Price Variance
SELECT
    product_id,
    product_name,

    base_unit_cost,
    unit_price,

    price_variance,
    price_variance_percentage,

    potential_savings

FROM vw_price_variance

WHERE price_variance_percentage > 20

ORDER BY
    price_variance_percentage DESC;
    
-- Analysis #12 — Price Variance by Supplier

SELECT
    ps.supplier_id,
    ps.supplier_name,

    ROUND(
        SUM(pv.quantity * pv.unit_price),
        2
    ) AS total_spend,

    ROUND(
        SUM(pv.potential_savings),
        2
    ) AS potential_savings

FROM vw_procurement_spend ps

JOIN vw_price_variance pv
    ON ps.po_item_id = pv.po_item_id

GROUP BY
    ps.supplier_id,
    ps.supplier_name

ORDER BY
    potential_savings DESC;

-- Analysis #13 — Payment Performance
SELECT
    payment_performance,

    COUNT(*) AS invoice_count,

    ROUND(
        SUM(invoice_amount),
        2
    ) AS invoice_value,

    ROUND(
        100 *
        SUM(invoice_amount)
        /
        SUM(SUM(invoice_amount)) OVER (),
        2
    ) AS invoice_value_percentage

FROM vw_invoice_payment

GROUP BY
    payment_performance

ORDER BY
    invoice_value DESC;
    
-- Analysis #14 — Outstanding Invoice Value
SELECT
    COUNT(*) AS unpaid_invoice_count,

    ROUND(
        SUM(invoice_amount)/10000000,
        2
    ) AS outstanding_invoice_value

FROM vw_invoice_payment

WHERE payment_performance = 'Unpaid';


-- 15. SUPPLIER RISK CLASSIFICATION

SELECT
    s.supplier_id,
    s.supplier_name,

    ROUND(
        s.total_spend / 10000000,
        2
    ) AS spend_crore,

    ROUND(
        d.late_delivery_percentage,
        2
    ) AS late_delivery_percentage,

    ROUND(
        q.rejection_rate_percentage,
        2
    ) AS rejection_rate_percentage,

    CASE

        WHEN d.late_delivery_percentage >
             (
                 SELECT AVG(late_delivery_percentage)
                 FROM vw_delivery_performance
             )
         AND q.rejection_rate_percentage >
             (
                 SELECT AVG(rejection_rate_percentage)
                 FROM vw_supplier_quality
             )
        THEN 'High Risk'

        WHEN d.late_delivery_percentage >
             (
                 SELECT AVG(late_delivery_percentage)
                 FROM vw_delivery_performance
             )
          OR q.rejection_rate_percentage >
             (
                 SELECT AVG(rejection_rate_percentage)
                 FROM vw_supplier_quality
             )
        THEN 'Medium Risk'

        ELSE 'Low Risk'

    END AS supplier_risk

FROM vw_supplier_spend s

JOIN vw_delivery_performance d
    ON s.supplier_id = d.supplier_id

JOIN vw_supplier_quality q
    ON s.supplier_id = q.supplier_id

ORDER BY
    supplier_risk,
    s.total_spend DESC;
    

-- 16. OUTSTANDING INVOICE ANALYSIS

SELECT
    COUNT(*) AS unpaid_invoice_count,

    ROUND(
        SUM(invoice_amount)/10000000,
        2
    ) AS outstanding_invoice_value

FROM vw_invoice_payment

WHERE payment_performance = 'Unpaid';


-- 17. EXECUTIVE PROCUREMENT SUMMARY


SELECT

    -- Potential Price Recovery
    (
        SELECT
            ROUND(
                SUM(potential_savings) / 10000000,
                2
            )
        FROM vw_price_variance
    ) AS potential_price_recovery_crore,

    -- Non-Contract Spend
    (
        SELECT
            ROUND(
                100 *
                SUM(
                    CASE
                        WHEN contract_id IS NULL
                        THEN line_spend
                        ELSE 0
                    END
                )
                /
                NULLIF(SUM(line_spend), 0),
                2
            )
        FROM vw_procurement_spend
    ) AS non_contract_spend_percentage,

    -- Late Delivery
    (
        SELECT
            ROUND(
                100 *
                SUM(
                    CASE
                        WHEN actual_delivery_date >
                             promised_delivery_date
                        THEN 1
                        ELSE 0
                    END
                )
                /
                NULLIF(COUNT(actual_delivery_date), 0),
                2
            )
        FROM vw_procurement_spend
        WHERE actual_delivery_date IS NOT NULL
    ) AS late_delivery_percentage,

    -- Rejection Rate
    (
        SELECT
            ROUND(
                100 *
                SUM(rejected_qty)
                /
                NULLIF(
                    SUM(received_qty + rejected_qty),
                    0
                ),
                2
            )
        FROM vw_procurement_spend
    ) AS rejection_rate_percentage;