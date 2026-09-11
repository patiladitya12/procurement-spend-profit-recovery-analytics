-- ANALYTICAL VIEWS 
USE ProcurementAnalytics;
SELECT DATABASE();

-- Analytical View 1  Procurement Spend
CREATE OR REPLACE VIEW vw_procurement_spend AS
SELECT
    pi.po_item_id,
    po.po_id,
    po.po_date,
    po.required_date,
    po.buyer_id,
    po.status AS po_status,

    s.supplier_id,
    s.supplier_name,
    s.city,
    s.state,

    p.product_id,
    p.product_name,

    c.category_id,
    c.category_name,

    po.contract_id,

    pi.quantity,
    pi.unit_price,

    ROUND(pi.quantity * pi.unit_price, 2) AS line_spend,

    pi.promised_delivery_date,
    pi.actual_delivery_date,
    pi.received_qty,
    pi.rejected_qty

FROM po_items pi

JOIN purchase_orders po
    ON pi.po_id = po.po_id

JOIN suppliers s
    ON po.supplier_id = s.supplier_id

JOIN products p
    ON pi.product_id = p.product_id

LEFT JOIN categories c
    ON p.category_id = c.category_id;
    
SELECT
    ROUND(SUM(line_spend), 2) AS total_spend
FROM vw_procurement_spend;

-- Analytical view 2 Supplier Spend
CREATE OR REPLACE VIEW vw_supplier_spend AS
SELECT
    supplier_id,
    supplier_name,

    COUNT(DISTINCT po_id) AS total_pos,

    COUNT(DISTINCT po_item_id) AS total_items,

    ROUND(SUM(line_spend), 2) AS total_spend,

    ROUND(
        SUM(line_spend) / 10000000,
        2
    ) AS spend_crore,

    ROUND(
        AVG(line_spend),
        2
    ) AS avg_line_spend

FROM vw_procurement_spend

GROUP BY
    supplier_id,
    supplier_name;
    
SELECT *
FROM vw_supplier_spend
ORDER BY total_spend DESC
LIMIT 20;

-- Analytical View 3 - Category Spend
CREATE OR REPLACE VIEW vw_category_spend AS
SELECT
    category_id,
    category_name,

    COUNT(DISTINCT po_id) AS total_pos,

    COUNT(DISTINCT po_item_id) AS total_items,

    ROUND(SUM(line_spend), 2) AS total_spend,

    ROUND(
        SUM(line_spend) / 10000000,
        2
    ) AS spend_crore

FROM vw_procurement_spend

GROUP BY
    category_id,
    category_name;
    
-- Analytical View 4 - Contract Compliance
CREATE OR REPLACE VIEW vw_contract_spend AS
SELECT
    CASE
        WHEN contract_id IS NULL
            THEN 'Non-Contract'
        ELSE 'Contract-Backed'
    END AS procurement_type,

    COUNT(DISTINCT po_id) AS total_pos,

    COUNT(DISTINCT po_item_id) AS total_items,

    ROUND(SUM(line_spend), 2) AS total_spend,

    ROUND(
        SUM(line_spend) / 10000000,
        2
    ) AS spend_crore

FROM vw_procurement_spend

GROUP BY
    procurement_type;

-- Analytical view 5 delivery performance 
CREATE OR REPLACE VIEW vw_delivery_performance AS
SELECT
    supplier_id,
    supplier_name,

    COUNT(po_item_id) AS delivered_items,

    SUM(
        CASE
            WHEN actual_delivery_date > promised_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_items,

    SUM(
        CASE
            WHEN actual_delivery_date <= promised_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS on_time_items,

    ROUND(
        AVG(
            DATEDIFF(
                actual_delivery_date,
                promised_delivery_date
            )
        ),
        2
    ) AS avg_delay_days,

    MAX(
        DATEDIFF(
            actual_delivery_date,
            promised_delivery_date
        )
    ) AS max_delay_days,

    ROUND(
        100 *
        SUM(
            CASE
                WHEN actual_delivery_date > promised_delivery_date
                THEN 1
                ELSE 0
            END
        )
        / NULLIF(COUNT(po_item_id), 0),
        2
    ) AS late_delivery_percentage

FROM vw_procurement_spend

WHERE actual_delivery_date IS NOT NULL

GROUP BY
    supplier_id,
    supplier_name;
    
-- View 6 Quality Performance
CREATE OR REPLACE VIEW vw_supplier_quality AS
SELECT
    supplier_id,
    supplier_name,

    SUM(received_qty) AS total_received_qty,

    SUM(rejected_qty) AS total_rejected_qty,

    ROUND(
        100 *
        SUM(rejected_qty)
        /
        NULLIF(
            SUM(received_qty + rejected_qty),
            0
        ),
        2
    ) AS rejection_rate_percentage

FROM vw_procurement_spend

GROUP BY
    supplier_id,
    supplier_name;
    
-- view 7 Price Varience
CREATE OR REPLACE VIEW vw_price_variance AS
SELECT

    pi.po_item_id,
    pi.po_id,

    p.product_id,
    p.product_name,

    p.base_unit_cost,

    pi.quantity,

    pi.unit_price,

    ROUND(
        pi.unit_price - p.base_unit_cost,
        2
    ) AS price_variance,

    ROUND(
        100 *
        (pi.unit_price - p.base_unit_cost)
        /
        NULLIF(p.base_unit_cost, 0),
        2
    ) AS price_variance_percentage,

    ROUND(
        CASE
            WHEN pi.unit_price > p.base_unit_cost
            THEN
                (pi.unit_price - p.base_unit_cost)
                * pi.quantity
            ELSE 0
        END,
        2
    ) AS potential_savings

FROM po_items pi

JOIN products p
    ON pi.product_id = p.product_id;
    
-- View 8 invoice and payment Performance
CREATE OR REPLACE VIEW vw_invoice_payment AS
SELECT

    i.invoice_id,
    i.po_id,

    i.invoice_date,
    i.invoice_amount,
    i.tax_amount,

    i.due_date,
    i.paid_date,

    i.payment_status,

    CASE
        WHEN i.paid_date IS NULL
            THEN 'Unpaid'

        WHEN i.paid_date <= i.due_date
            THEN 'Paid On Time'

        ELSE 'Paid Late'
    END AS payment_performance,

    CASE
        WHEN i.paid_date IS NOT NULL
        THEN DATEDIFF(
            i.paid_date,
            i.due_date
        )

        ELSE NULL
    END AS payment_delay_days

FROM invoices i;

SELECT

    payment_performance,

    COUNT(*) AS invoice_count,

    ROUND(
        SUM(invoice_amount),
        2
    ) AS invoice_value

FROM vw_invoice_payment

GROUP BY payment_performance;



