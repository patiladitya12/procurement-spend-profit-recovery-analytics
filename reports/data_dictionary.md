# Procurement Analytics - Data Dictionary

## 1. Suppliers

| Column | Description |
|---|---|
| supplier_id | Unique supplier identifier |
| supplier_name | Supplier/company name |
| city | Supplier city |
| state | Supplier state |
| country | Supplier country |
| payment_terms_days | Agreed payment period |
| supplier_rating | Supplier performance rating |
| lead_time_days | Typical supplier lead time |
| contract_status | Supplier contract status |

## 2. Categories

| Column | Description |
|---|---|
| category_id | Unique category identifier |
| category_name | Procurement category |

## 3. Products

| Column | Description |
|---|---|
| product_id | Unique product identifier |
| product_name | Product/service name |
| category_id | Product category |
| base_unit_cost | Reference/base product cost |

## 4. Contracts

| Column | Description |
|---|---|
| contract_id | Unique contract identifier |
| supplier_id | Supplier associated with contract |
| category_id | Category covered by contract |
| start_date | Contract start date |
| end_date | Contract end date |
| negotiated_discount_pct | Negotiated discount |
| minimum_order_value | Minimum order requirement |
| contract_status | Contract status |

## 5. Purchase Orders

| Column | Description |
|---|---|
| po_id | Unique purchase order identifier |
| supplier_id | Supplier receiving the PO |
| contract_id | Related contract |
| po_date | Purchase order date |
| required_date | Required delivery date |
| buyer_id | Procurement buyer |
| currency | Transaction currency |
| status | Purchase order status |

## 6. PO Items

| Column | Description |
|---|---|
| po_item_id | Unique PO line identifier |
| po_id | Related purchase order |
| product_id | Purchased product |
| quantity | Ordered quantity |
| unit_price | Price paid per unit |
| promised_delivery_date | Promised delivery date |
| actual_delivery_date | Actual delivery date |
| received_qty | Quantity received |
| rejected_qty | Quantity rejected |

## 7. Invoices

| Column | Description |
|---|---|
| invoice_id | Unique invoice identifier |
| po_id | Related purchase order |
| invoice_date | Invoice date |
| invoice_amount | Invoice amount before tax |
| tax_amount | Tax amount |
| due_date | Payment due date |
| paid_date | Actual payment date |
| payment_status | Invoice payment status |

## 8. Payments

| Column | Description |
|---|---|
| payment_id | Unique payment identifier |
| invoice_id | Related invoice |
| payment_date | Payment date |
| payment_amount | Amount paid |