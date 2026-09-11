import pandas as pd
from pathlib import Path

# ============================================================
# 1. RAW DATA LOCATION
# ============================================================

RAW_DIR = Path("data/raw")


# ============================================================
# 2. FILES TO INSPECT
# ============================================================

files = [
    "categories.csv",
    "suppliers.csv",
    "products.csv",
    "contracts.csv",
    "purchase_orders.csv",
    "po_items.csv",
    "invoices.csv",
    "payments.csv"
]


# ============================================================
# 3. LOAD AND INSPECT EACH FILE
# ============================================================

for file_name in files:

    file_path = RAW_DIR / file_name

    print("\n")
    print("=" * 70)
    print(f"FILE: {file_name}")
    print("=" * 70)

    df = pd.read_csv(file_path)

    print(f"\nRows    : {df.shape[0]:,}")
    print(f"Columns : {df.shape[1]:,}")

    print("\nColumn Names:")
    print(df.columns.tolist())

    print("\nData Types:")
    print(df.dtypes)

    print("\nMissing Values:")
    print(df.isnull().sum())

    print("\nDuplicate Rows:")
    print(df.duplicated().sum())

    print("\nFirst 5 Rows:")
    print(df.head())


# ============================================================
# 4. SUMMARY
# ============================================================

print("\n")
print("=" * 70)
print("RAW DATA INSPECTION COMPLETED")
print("=" * 70)