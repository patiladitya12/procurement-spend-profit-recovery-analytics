USE ProcurementAnalytics;
SELECT database();
SELECT
    po_item_id,
    po_id,
    product_id,
    quantity,
    unit_price,
    quantity * unit_price AS line_value
FROM po_items
LIMIT 20;

-- TOTAL PROCUREMENT SPEND
SELECT
    ROUND(
        SUM(quantity * unit_price) / 10000000,
        2
    ) AS total_spend_crore
FROM po_items;

-- WHERE OUR PROCUREMENT MONEY GOING
SELECT
    s.supplier_id,
    s.supplier_name,
    ROUND(
        SUM(pi.quantity * pi.unit_price)/10000000,
        2
    ) AS total_spend
FROM suppliers s
JOIN purchase_orders po
    ON s.supplier_id = po.supplier_id
JOIN po_items pi
    ON po.po_id = pi.po_id
GROUP BY
    s.supplier_id,
    s.supplier_name
ORDER BY total_spend DESC;

-- top 10 only add limit 10 at end of query --
SELECT
    s.supplier_id,
    s.supplier_name,
    ROUND(
        SUM(pi.quantity * pi.unit_price)/10000000,
        2
    ) AS total_spend
FROM suppliers s
JOIN purchase_orders po
    ON s.supplier_id = po.supplier_id
JOIN po_items pi
    ON po.po_id = pi.po_id
GROUP BY
    s.supplier_id,
    s.supplier_name
ORDER BY total_spend DESC
limit 10;

-- spend category wise
SELECT
    c.category_id,
    c.category_name,
    ROUND(
        SUM(pi.quantity * pi.unit_price) / 10000000,
        2
    ) AS spend_crore
FROM categories c
JOIN products p
    ON c.category_id = p.category_id
JOIN po_items pi
    ON p.product_id = pi.product_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY spend_crore DESC;

-- category share of total spend
SELECT
    c.category_name,
    c.category_id,

    ROUND(
        SUM(pi.quantity * pi.unit_price) / 10000000,
        2
    ) AS spend_crore,

    ROUND(
        100 * SUM(pi.quantity * pi.unit_price)
        /
        (SELECT SUM(quantity * unit_price)
         FROM po_items),
        2
    ) AS spend_percentage

FROM categories c

JOIN products p
    ON c.category_id = p.category_id

JOIN po_items pi
    ON p.product_id = pi.product_id

GROUP BY
    c.category_id,
    c.category_name

ORDER BY spend_percentage DESC;

-- contract vs non contract 
SELECT
    CASE
        WHEN po.contract_id IS NULL
            THEN 'Non-Contract'
        ELSE 'Contract-Backed'
    END AS procurement_type,

    COUNT(DISTINCT po.po_id) AS po_count,

    ROUND(
        SUM(pi.quantity * pi.unit_price) / 10000000,
        2
    ) AS spend_crore

FROM purchase_orders po

JOIN po_items pi
    ON po.po_id = pi.po_id

GROUP BY
    procurement_type;
    
-- non contract spend percentage
SELECT

    ROUND(
        100 *
        SUM(
            CASE
                WHEN po.contract_id IS NULL
                THEN pi.quantity * pi.unit_price
                ELSE 0
            END
        )
        /
        SUM(pi.quantity * pi.unit_price),
        2
    ) AS non_contract_spend_percentage

FROM purchase_orders po

JOIN po_items pi
    ON po.po_id = pi.po_id;
    
-- delivery delays
SELECT
    po_item_id,
    po_id,
    promised_delivery_date,
    actual_delivery_date,

    DATEDIFF(
        actual_delivery_date,
        promised_delivery_date
    ) AS delivery_delay_days

FROM po_items
WHERE actual_delivery_date IS NOT NULL
LIMIT 20;

-- late delivery rate
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
        COUNT(actual_delivery_date),
        2
    ) AS late_delivery_percentage

FROM po_items
WHERE actual_delivery_date IS NOT NULL;

-- Suplier delivery performance
SELECT
    s.supplier_id,
    s.supplier_name,

    COUNT(pi.po_item_id) AS delivered_items,

    ROUND(
        AVG(
            DATEDIFF(
                pi.actual_delivery_date,
                pi.promised_delivery_date
            )
        ),
        2
    ) AS avg_delivery_delay_days,

    ROUND(
        100 *
        SUM(
            CASE
                WHEN pi.actual_delivery_date >
                     pi.promised_delivery_date
                THEN 1
                ELSE 0
            END
        )
        /
        COUNT(pi.actual_delivery_date),
        2
    ) AS late_delivery_percentage

FROM suppliers s

JOIN purchase_orders po
    ON s.supplier_id = po.supplier_id

JOIN po_items pi
    ON po.po_id = pi.po_id

WHERE pi.actual_delivery_date IS NOT NULL

GROUP BY
    s.supplier_id,
    s.supplier_name

ORDER BY
    late_delivery_percentage DESC;
    
-- rejection rate 
SELECT

    SUM(rejected_qty) AS total_rejected_qty,

    SUM(received_qty) AS total_received_qty,

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

FROM po_items;

-- rejection rate according to supplier
SELECT
    s.supplier_id,
    s.supplier_name,

    SUM(pi.rejected_qty) AS rejected_quantity,

    ROUND(
        100 *
        SUM(pi.rejected_qty)
        /
        NULLIF(
            SUM(pi.received_qty + pi.rejected_qty),
            0
        ),
        2
    ) AS rejection_rate_percentage

FROM suppliers s

JOIN purchase_orders po
    ON s.supplier_id = po.supplier_id

JOIN po_items pi
    ON po.po_id = pi.po_id

GROUP BY
    s.supplier_id,
    s.supplier_name

ORDER BY
    rejection_rate_percentage DESC;
    
-- price varience
SELECT

    pi.po_item_id,
    pi.product_id,

    p.product_name,

    p.base_unit_cost,

    pi.unit_price,

    ROUND(
        pi.unit_price - p.base_unit_cost,
        2
    ) AS price_variance,

    ROUND(
        100 *
        (
            pi.unit_price - p.base_unit_cost
        )
        /
        NULLIF(p.base_unit_cost, 0),
        2
    ) AS price_variance_percentage

FROM po_items pi

JOIN products p
    ON pi.product_id = p.product_id

ORDER BY
    price_variance_percentage DESC
LIMIT 20;

-- potential saving
SELECT

    ROUND(
        SUM(
            CASE
                WHEN pi.unit_price > p.base_unit_cost
                THEN
                    ((
                        pi.unit_price
                        - p.base_unit_cost
                    ) * pi.quantity)/10000000
                ELSE 0
            END
        ),
        2
    ) AS potential_price_savings

FROM po_items pi

JOIN products p
    ON pi.product_id = p.product_id;
    
-- find product with biggest saving
SELECT

    p.product_id,
    p.product_name,

    SUM(pi.quantity) AS total_quantity,

    ROUND(
        SUM(pi.quantity * pi.unit_price)/10000000,
        2
    ) AS actual_spend,

    ROUND(
        SUM(
            CASE
                WHEN pi.unit_price > p.base_unit_cost
                THEN
                    ((
                        pi.unit_price
                        - p.base_unit_cost
                    ) * pi.quantity)/10000000
                ELSE 0
            END
        ),
        2
    ) AS potential_savings

FROM products p

JOIN po_items pi
    ON p.product_id = pi.product_id

GROUP BY
    p.product_id,
    p.product_name

ORDER BY
    potential_savings DESC

LIMIT 20;