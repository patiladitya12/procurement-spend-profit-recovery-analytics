import pandas as pd
import numpy as np
from faker import Faker
from pathlib import Path
import random

# ============================================================
# 1. SETTINGS
# ============================================================

fake = Faker("en_IN")

# Make results reproducible
np.random.seed(42)
random.seed(42)
Faker.seed(42)

# Project paths
RAW_DIR = Path("data/raw")
RAW_DIR.mkdir(parents=True, exist_ok=True)


# ============================================================
# 2. BASIC MASTER DATA
# ============================================================

NUM_SUPPLIERS = 100
NUM_PRODUCTS = 250
NUM_CONTRACTS = 150
NUM_POS = 2500


# ============================================================
# 3. CATEGORIES
# ============================================================

categories = [
    ("CAT001", "IT Hardware"),
    ("CAT002", "Software & Licenses"),
    ("CAT003", "Office Supplies"),
    ("CAT004", "Industrial Equipment"),
    ("CAT005", "Raw Materials"),
    ("CAT006", "Packaging"),
    ("CAT007", "Logistics"),
    ("CAT008", "Maintenance"),
    ("CAT009", "Professional Services"),
    ("CAT010", "Facilities"),
]

categories_df = pd.DataFrame(
    categories,
    columns=["category_id", "category_name"]
)


# ============================================================
# 4. SUPPLIERS
# ============================================================

supplier_rows = []

cities = [
    "Mumbai",
    "Pune",
    "Bengaluru",
    "Delhi",
    "Hyderabad",
    "Chennai",
    "Ahmedabad",
    "Nashik",
    "Nagpur",
    "Noida"
]

states = [
    "Maharashtra",
    "Karnataka",
    "Delhi",
    "Telangana",
    "Tamil Nadu",
    "Gujarat",
    "Uttar Pradesh"
]

for i in range(1, NUM_SUPPLIERS + 1):

    supplier_id = f"SUP{i:04d}"

    supplier_rows.append({
        "supplier_id": supplier_id,
        "supplier_name": fake.company(),
        "city": random.choice(cities),
        "state": random.choice(states),
        "country": "India",
        "payment_terms_days": random.choice([15, 30, 45, 60, 90]),
        "supplier_rating": round(np.random.uniform(2.5, 5.0), 2),
        "lead_time_days": random.randint(3, 30),
        "contract_status": random.choice(
            ["Active", "Active", "Active", "Expired"]
        )
    })

suppliers_df = pd.DataFrame(supplier_rows)


# ============================================================
# 5. PRODUCTS
# ============================================================

product_rows = []

product_names = [
    "Laptop",
    "Desktop Computer",
    "Monitor",
    "Printer",
    "Keyboard",
    "Mouse",
    "Server",
    "Network Switch",
    "Software License",
    "Office Chair",
    "Printer Paper",
    "Industrial Motor",
    "Steel Sheet",
    "Copper Wire",
    "Plastic Packaging",
    "Cardboard Box",
    "Transport Service",
    "Maintenance Service",
    "Consulting Service",
    "Cleaning Service"
]

for i in range(1, NUM_PRODUCTS + 1):

    product_id = f"PROD{i:04d}"

    category_id = random.choice(
        categories_df["category_id"].tolist()
    )

    product_rows.append({
        "product_id": product_id,
        "product_name": random.choice(product_names),
        "category_id": category_id,
        "base_unit_cost": round(
            np.random.uniform(100, 150000), 2
        )
    })

products_df = pd.DataFrame(product_rows)


# ============================================================
# 6. CONTRACTS
# ============================================================

contract_rows = []

for i in range(1, NUM_CONTRACTS + 1):

    contract_id = f"CON{i:04d}"

    supplier_id = random.choice(
        suppliers_df["supplier_id"].tolist()
    )

    category_id = random.choice(
        categories_df["category_id"].tolist()
    )

    start_date = fake.date_between(
        start_date="-2y",
        end_date="-6m"
    )

    end_date = fake.date_between(
        start_date="+3m",
        end_date="+1y"
    )

    contract_rows.append({
        "contract_id": contract_id,
        "supplier_id": supplier_id,
        "category_id": category_id,
        "start_date": start_date,
        "end_date": end_date,
        "negotiated_discount_pct": round(
            np.random.uniform(2, 18), 2
        ),
        "minimum_order_value": random.choice(
            [0, 10000, 25000, 50000, 100000]
        ),
        "contract_status": random.choice(
            ["Active", "Active", "Expired"]
        )
    })

contracts_df = pd.DataFrame(contract_rows)


# ============================================================
# 7. PURCHASE ORDERS
# ============================================================

po_rows = []

for i in range(1, NUM_POS + 1):

    po_id = f"PO{i:06d}"

    supplier_id = random.choice(
        suppliers_df["supplier_id"].tolist()
    )

    po_date = fake.date_between(
        start_date="-18m",
        end_date="today"
    )

    required_date = pd.Timestamp(po_date) + pd.Timedelta(
        days=random.randint(7, 45)
    )

    # Some POs will have contracts and some won't
    if random.random() < 0.75:

        supplier_contracts = contracts_df[
            contracts_df["supplier_id"] == supplier_id
        ]

        if len(supplier_contracts) > 0:
            contract_id = random.choice(
                supplier_contracts["contract_id"].tolist()
            )
        else:
            contract_id = None

    else:
        contract_id = None

    po_rows.append({
        "po_id": po_id,
        "supplier_id": supplier_id,
        "contract_id": contract_id,
        "po_date": po_date,
        "required_date": required_date.date(),
        "buyer_id": f"BUY{random.randint(1, 20):03d}",
        "currency": "INR",
        "status": random.choice(
            ["Approved", "Approved", "Approved",
             "Completed", "Cancelled"]
        )
    })

purchase_orders_df = pd.DataFrame(po_rows)


# ============================================================
# 8. PURCHASE ORDER ITEMS
# ============================================================

po_item_rows = []

item_counter = 1

for _, po in purchase_orders_df.iterrows():

    number_of_items = random.randint(1, 6)

    selected_products = random.sample(
        products_df["product_id"].tolist(),
        number_of_items
    )

    for product_id in selected_products:

        product = products_df[
            products_df["product_id"] == product_id
        ].iloc[0]

        quantity = random.randint(1, 100)

        base_price = product["base_unit_cost"]

        # Natural price variation
        price_multiplier = np.random.uniform(
            0.85, 1.25
        )

        unit_price = round(
            base_price * price_multiplier,
            2
        )

        promised_date = pd.Timestamp(
            po["required_date"]
        )

        # Delivery can be early, on time or late
        delivery_delay = random.randint(-5, 25)

        actual_delivery_date = (
            promised_date +
            pd.Timedelta(days=delivery_delay)
        )

        received_qty = int(
            quantity * np.random.uniform(0.90, 1.00)
        )

        rejected_qty = random.randint(
            0,
            max(0, quantity - received_qty)
        )

        po_item_rows.append({
            "po_item_id": f"POITEM{item_counter:07d}",
            "po_id": po["po_id"],
            "product_id": product_id,
            "quantity": quantity,
            "unit_price": unit_price,
            "promised_delivery_date": promised_date.date(),
            "actual_delivery_date": actual_delivery_date.date(),
            "received_qty": received_qty,
            "rejected_qty": rejected_qty
        })

        item_counter += 1


po_items_df = pd.DataFrame(po_item_rows)


# ============================================================
# 9. INVOICES
# ============================================================

invoice_rows = []

for i, (_, po) in enumerate(
    purchase_orders_df[
        purchase_orders_df["status"] != "Cancelled"
    ].iterrows(),
    start=1
):

    po_items = po_items_df[
        po_items_df["po_id"] == po["po_id"]
    ]

    invoice_amount = (
        po_items["quantity"] *
        po_items["unit_price"]
    ).sum()

    invoice_amount = round(float(invoice_amount), 2)

    invoice_date = pd.Timestamp(
        po["po_date"]
    ) + pd.Timedelta(
        days=random.randint(1, 20)
    )

    tax_amount = round(
        invoice_amount * random.choice(
            [0.05, 0.12, 0.18]
        ),
        2
    )

    due_date = invoice_date + pd.Timedelta(
        days=random.choice([15, 30, 45, 60])
    )

    payment_status = random.choice(
        ["Paid", "Paid", "Paid", "Pending", "Overdue"]
    )

    if payment_status == "Paid":

        paid_date = due_date + pd.Timedelta(
            days=random.randint(-10, 20)
        )

    else:

        paid_date = None

    invoice_rows.append({
        "invoice_id": f"INV{i:06d}",
        "po_id": po["po_id"],
        "invoice_date": invoice_date.date(),
        "invoice_amount": invoice_amount,
        "tax_amount": tax_amount,
        "due_date": due_date.date(),
        "paid_date": (
            paid_date.date()
            if paid_date is not None
            else None
        ),
        "payment_status": payment_status
    })


invoices_df = pd.DataFrame(invoice_rows)


# ============================================================
# 10. PAYMENTS
# ============================================================

payment_rows = []

paid_invoices = invoices_df[
    invoices_df["payment_status"] == "Paid"
]

for i, (_, invoice) in enumerate(
    paid_invoices.iterrows(),
    start=1
):

    payment_date = (
        pd.Timestamp(invoice["paid_date"])
    )

    payment_rows.append({
        "payment_id": f"PAY{i:06d}",
        "invoice_id": invoice["invoice_id"],
        "payment_date": payment_date.date(),
        "payment_amount": invoice["invoice_amount"]
    })


payments_df = pd.DataFrame(payment_rows)


# ============================================================
# 11. INTRODUCE REALISTIC RAW-DATA ISSUES
# ============================================================

# Missing supplier rating
missing_supplier_indices = np.random.choice(
    suppliers_df.index,
    size=5,
    replace=False
)

suppliers_df.loc[
    missing_supplier_indices,
    "supplier_rating"
] = np.nan


# Missing actual delivery dates
missing_delivery_indices = np.random.choice(
    po_items_df.index,
    size=30,
    replace=False
)

po_items_df.loc[
    missing_delivery_indices,
    "actual_delivery_date"
] = None


# A few extreme price variations
price_indices = np.random.choice(
    po_items_df.index,
    size=20,
    replace=False
)

po_items_df.loc[
    price_indices,
    "unit_price"
] *= np.random.uniform(
    1.4,
    2.0,
    size=len(price_indices)
)

po_items_df["unit_price"] = po_items_df[
    "unit_price"
].round(2)


# ============================================================
# 12. SAVE CSV FILES
# ============================================================

categories_df.to_csv(
    RAW_DIR / "categories.csv",
    index=False
)

suppliers_df.to_csv(
    RAW_DIR / "suppliers.csv",
    index=False
)

products_df.to_csv(
    RAW_DIR / "products.csv",
    index=False
)

contracts_df.to_csv(
    RAW_DIR / "contracts.csv",
    index=False
)

purchase_orders_df.to_csv(
    RAW_DIR / "purchase_orders.csv",
    index=False
)

po_items_df.to_csv(
    RAW_DIR / "po_items.csv",
    index=False
)

invoices_df.to_csv(
    RAW_DIR / "invoices.csv",
    index=False
)

payments_df.to_csv(
    RAW_DIR / "payments.csv",
    index=False
)


# ============================================================
# 13. DISPLAY SUMMARY
# ============================================================

print("\n==============================================")
print("PROCUREMENT RAW DATA GENERATED SUCCESSFULLY")
print("==============================================")

print(f"Suppliers       : {len(suppliers_df):,}")
print(f"Categories      : {len(categories_df):,}")
print(f"Products        : {len(products_df):,}")
print(f"Contracts       : {len(contracts_df):,}")
print(f"Purchase Orders : {len(purchase_orders_df):,}")
print(f"PO Items        : {len(po_items_df):,}")
print(f"Invoices        : {len(invoices_df):,}")
print(f"Payments        : {len(payments_df):,}")

print("\nFiles saved inside:")
print(RAW_DIR.resolve())

print("\n==============================================")