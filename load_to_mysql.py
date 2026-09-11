import pandas as pd
import mysql.connector
from pathlib import Path


# ============================================================
# 1. DATABASE CONFIGURATION
# ============================================================

DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "MyNewPass123!",
    "database": "ProcurementAnalytics"
}


# ============================================================
# 2. RAW DATA LOCATION
# ============================================================

RAW_DIR = Path("data/raw")


# ============================================================
# 3. TABLE LOADING ORDER
# ============================================================

tables = [
    ("categories.csv", "categories"),
    ("suppliers.csv", "suppliers"),
    ("products.csv", "products"),
    ("contracts.csv", "contracts"),
    ("purchase_orders.csv", "purchase_orders"),
    ("po_items.csv", "po_items"),
    ("invoices.csv", "invoices"),
    ("payments.csv", "payments")
]


# ============================================================
# 4. CONNECT TO MYSQL
# ============================================================

print("\nConnecting to MySQL...")

connection = mysql.connector.connect(
    host=DB_CONFIG["host"],
    user=DB_CONFIG["user"],
    password=DB_CONFIG["password"],
    database=DB_CONFIG["database"]
)

cursor = connection.cursor()

print("Successfully connected to MySQL!")


# ============================================================
# 5. LOAD EACH CSV
# ============================================================

for file_name, table_name in tables:

    print("\n" + "=" * 60)
    print(f"Loading: {file_name}")
    print(f"Target table: {table_name}")
    print("=" * 60)

    file_path = RAW_DIR / file_name

    # Check whether file exists
    if not file_path.exists():

        print(f"ERROR: File not found -> {file_path}")
        continue

    # Read CSV
    df = pd.read_csv(file_path)

    print(f"CSV rows found: {len(df):,}")

    # Convert pandas NaN values to Python None
    # MySQL will store None as SQL NULL
    df = df.astype(object).where(pd.notnull(df), None)

    # --------------------------------------------------------
    # Convert dataframe rows into tuples
    # --------------------------------------------------------

    rows = list(df.itertuples(
        index=False,
        name=None
    ))

    # Get column names
    columns = list(df.columns)

    column_names = ", ".join(
        f"`{column}`" for column in columns
    )

    placeholders = ", ".join(
        ["%s"] * len(columns)
    )

    insert_query = f"""
        INSERT INTO `{table_name}`
        ({column_names})
        VALUES ({placeholders})
    """

    # --------------------------------------------------------
    # Insert rows
    # --------------------------------------------------------

    try:

        cursor.executemany(
            insert_query,
            rows
        )

        connection.commit()

        print(
            f"Successfully inserted: "
            f"{cursor.rowcount:,} rows"
        )

    except Exception as e:

        connection.rollback()

        print(
            f"ERROR while loading {table_name}:"
        )

        print(e)

        break


# ============================================================
# 6. CLOSE CONNECTION
# ============================================================

cursor.close()
connection.close()

print("\n" + "=" * 60)
print("DATA LOADING PROCESS COMPLETED")
print("=" * 60)