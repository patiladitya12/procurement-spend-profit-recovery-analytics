import mysql.connector

connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password="MyNewPass123!",
    database="ProcurementAnalytics"
)

if connection.is_connected():
    print("Successfully connected to MySQL!")

connection.close()