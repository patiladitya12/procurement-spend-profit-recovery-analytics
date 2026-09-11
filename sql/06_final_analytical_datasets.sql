-- =========================================================
-- STEP 6: FINAL ANALYTICAL DATASETS
-- Procurement Spend & Profit Recovery Analytics
-- =========================================================

USE ProcurementAnalytics;

-- dataset for python and powerbi ----

-- =========================================================
-- 1. SUPPLIER KPI DATASET
-- =========================================================

CREATE OR REPLACE VIEW vw_supplier_kpi AS

SELECT
    s.supplier_id,
    s.supplier_name,

    ROUND(
        s.total_spend,
        2
    ) AS total_spend,

    ROUND(
        s.spend_crore,
        2
    ) AS spend_crore,

    s.total_pos,
    s.total_items,

    ROUND(
        d.late_delivery_percentage,
        2
    ) AS late_delivery_percentage,

    ROUND(
        d.avg_delay_days,
        2
    ) AS avg_delay_days,

    ROUND(
        q.rejection_rate_percentage,
        2
    ) AS rejection_rate_percentage,

    ROUND(
        100 *
        SUM(
            CASE
                WHEN ps.contract_id IS NULL
                THEN ps.line_spend
                ELSE 0
            END
        )
        /
        NULLIF(SUM(ps.line_spend), 0),
        2
    ) AS non_contract_percentage

FROM vw_supplier_spend s

LEFT JOIN vw_delivery_performance d
    ON s.supplier_id = d.supplier_id

LEFT JOIN vw_supplier_quality q
    ON s.supplier_id = q.supplier_id

LEFT JOIN vw_procurement_spend ps
    ON s.supplier_id = ps.supplier_id

GROUP BY
    s.supplier_id,
    s.supplier_name,
    s.total_spend,
    s.spend_crore,
    s.total_pos,
    s.total_items,
    d.late_delivery_percentage,
    d.avg_delay_days,
    q.rejection_rate_percentage;
    
-- =========================================================
-- 2. PROCUREMENT RECOVERY DATASET
-- =========================================================

CREATE OR REPLACE VIEW vw_procurement_recovery AS

SELECT

    ps.po_item_id,
    ps.po_id,
    ps.po_date,

    ps.supplier_id,
    ps.supplier_name,

    ps.category_id,
    ps.category_name,

    ps.product_id,
    ps.product_name,

    ps.quantity,
    ps.unit_price,

    pv.base_unit_cost,

    pv.price_variance,

    pv.price_variance_percentage,

    pv.potential_savings,

    ps.contract_id,

    CASE
        WHEN ps.contract_id IS NULL
        THEN 'Non-Contract'
        ELSE 'Contract-Backed'
    END AS procurement_type

FROM vw_procurement_spend ps

JOIN vw_price_variance pv
    ON ps.po_item_id = pv.po_item_id;

-- =========================================================
-- 3. SUPPLIER RISK DATASET
-- =========================================================

CREATE OR REPLACE VIEW vw_supplier_risk AS

SELECT

    s.supplier_id,
    s.supplier_name,

    ROUND(
        s.spend_crore,
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

LEFT JOIN vw_delivery_performance d
    ON s.supplier_id = d.supplier_id

LEFT JOIN vw_supplier_quality q
    ON s.supplier_id = q.supplier_id;

-- =========================================================
-- 4. INVOICE ANALYTICS DATASET
-- =========================================================

CREATE OR REPLACE VIEW vw_invoice_analytics AS

SELECT

    invoice_id,
    po_id,

    invoice_date,
    invoice_amount,
    tax_amount,

    due_date,
    paid_date,

    payment_status,
    payment_performance,

    payment_delay_days,

    CASE
        WHEN paid_date IS NULL
        THEN DATEDIFF(
            CURDATE(),
            due_date
        )
        ELSE NULL
    END AS days_overdue

FROM vw_invoice_payment;

SELECT *
FROM vw_invoice_analytics
LIMIT 20;


