import pandas as pd
from pathlib import Path

RAW_DIR = Path("data/raw")


# ============================================================
# LOAD DATA
# ============================================================

suppliers = pd.read_csv(RAW_DIR / "suppliers.csv")
categories = pd.read_csv(RAW_DIR / "categories.csv")
products = pd.read_csv(RAW_DIR / "products.csv")
contracts = pd.read_csv(RAW_DIR / "contracts.csv")
purchase_orders = pd.read_csv(RAW_DIR / "purchase_orders.csv")
po_items = pd.read_csv(RAW_DIR / "po_items.csv")
invoices = pd.read_csv(RAW_DIR / "invoices.csv")
payments = pd.read_csv(RAW_DIR / "payments.csv")


# ============================================================
# FUNCTION: CHECK PRIMARY KEY
# ============================================================

def check_primary_key(df, column, table_name):

    duplicates = df[column].duplicated().sum()

    print(f"\n{table_name}")
    print(f"Primary Key : {column}")
    print(f"Duplicate IDs: {duplicates}")

    if duplicates == 0:
        print("STATUS: PASS")
    else:
        print("STATUS: FAIL")


# ============================================================
# PRIMARY KEY CHECKS
# ============================================================

check_primary_key(
    suppliers,
    "supplier_id",
    "SUPPLIERS"
)

check_primary_key(
    categories,
    "category_id",
    "CATEGORIES"
)

check_primary_key(
    products,
    "product_id",
    "PRODUCTS"
)

check_primary_key(
    contracts,
    "contract_id",
    "CONTRACTS"
)

check_primary_key(
    purchase_orders,
    "po_id",
    "PURCHASE ORDERS"
)

check_primary_key(
    po_items,
    "po_item_id",
    "PO ITEMS"
)

check_primary_key(
    invoices,
    "invoice_id",
    "INVOICES"
)

check_primary_key(
    payments,
    "payment_id",
    "PAYMENTS"
)


# ============================================================
# FOREIGN KEY CHECKS
# ============================================================

print("\n")
print("=" * 70)
print("FOREIGN KEY VALIDATION")
print("=" * 70)


# PO supplier → Supplier
invalid_supplier_ids = (
    purchase_orders[
        ~purchase_orders["supplier_id"].isin(
            suppliers["supplier_id"]
        )
    ]
)

print(
    f"\nInvalid PO supplier IDs: "
    f"{len(invalid_supplier_ids)}"
)


# Product category → Category
invalid_category_ids = (
    products[
        ~products["category_id"].isin(
            categories["category_id"]
        )
    ]
)

print(
    f"Invalid product category IDs: "
    f"{len(invalid_category_ids)}"
)


# PO item → PO
invalid_po_ids = (
    po_items[
        ~po_items["po_id"].isin(
            purchase_orders["po_id"]
        )
    ]
)

print(
    f"Invalid PO item PO IDs: "
    f"{len(invalid_po_ids)}"
)


# PO item → Product
invalid_product_ids = (
    po_items[
        ~po_items["product_id"].isin(
            products["product_id"]
        )
    ]
)

print(
    f"Invalid PO item product IDs: "
    f"{len(invalid_product_ids)}"
)


# Invoice → PO
invalid_invoice_po_ids = (
    invoices[
        ~invoices["po_id"].isin(
            purchase_orders["po_id"]
        )
    ]
)

print(
    f"Invalid invoice PO IDs: "
    f"{len(invalid_invoice_po_ids)}"
)


# Payment → Invoice
invalid_payment_invoice_ids = (
    payments[
        ~payments["invoice_id"].isin(
            invoices["invoice_id"]
        )
    ]
)

print(
    f"Invalid payment invoice IDs: "
    f"{len(invalid_payment_invoice_ids)}"
)


# ============================================================
# MISSING VALUES
# ============================================================

print("\n")
print("=" * 70)
print("MISSING VALUE CHECK")
print("=" * 70)


datasets = {
    "Suppliers": suppliers,
    "Categories": categories,
    "Products": products,
    "Contracts": contracts,
    "Purchase Orders": purchase_orders,
    "PO Items": po_items,
    "Invoices": invoices,
    "Payments": payments
}


for name, df in datasets.items():

    total_missing = df.isnull().sum().sum()

    print(
        f"{name:<20} "
        f"Missing values: {total_missing}"
    )


# ============================================================
# NUMERIC VALIDATION
# ============================================================

print("\n")
print("=" * 70)
print("NUMERIC VALIDATION")
print("=" * 70)


print(
    "\nNegative quantities:",
    (po_items["quantity"] < 0).sum()
)

print(
    "Negative unit prices:",
    (po_items["unit_price"] < 0).sum()
)

print(
    "Negative rejected quantities:",
    (po_items["rejected_qty"] < 0).sum()
)

print(
    "Negative invoice amounts:",
    (invoices["invoice_amount"] < 0).sum()
)


# ============================================================
# COMPLETION
# ============================================================

print("\n")
print("=" * 70)
print("DATA QUALITY CHECK COMPLETED")
print("=" * 70)