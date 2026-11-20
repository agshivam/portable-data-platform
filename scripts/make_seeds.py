"""Create small deterministic synthetic seed data (no real data). Run: python scripts/make_seeds.py"""
import csv
import random
from datetime import date, timedelta
from pathlib import Path

random.seed(42)
out = Path(__file__).resolve().parent.parent / "dbt" / "seeds"
regions = ["North", "South", "East", "West"]
cats = ["Books", "Games", "Home", "Garden", "Tools"]

products = [(i, f"Product {i}", random.choice(cats), round(random.uniform(5, 120), 2)) for i in range(1, 41)]
customers = [(i, f"Customer {i}", random.choice(regions), (date(2024, 1, 1) + timedelta(days=random.randint(0, 300))).isoformat()) for i in range(1, 201)]
orders, items = [], []
oid = 0
for _ in range(1500):
    oid += 1
    c = random.choice(customers)
    d = date.fromisoformat(c[3]) + timedelta(days=random.randint(0, 400))
    orders.append((oid, c[0], d.isoformat(), random.choice(["placed", "shipped", "returned"])))
    for line in range(random.randint(1, 4)):
        p = random.choice(products)
        items.append((oid * 10 + line, oid, p[0], random.randint(1, 5)))

def write(name, header, rows):
    with open(out / f"{name}.csv", "w", newline="") as f:
        w = csv.writer(f); w.writerow(header); w.writerows(rows)

write("raw_products", ["product_id", "product_name", "category", "unit_price"], products)
write("raw_customers", ["customer_id", "customer_name", "region", "signup_date"], customers)
write("raw_orders", ["order_id", "customer_id", "order_date", "status"], orders)
write("raw_order_items", ["item_id", "order_id", "product_id", "quantity"], items)
print("seeds written:", len(products), len(customers), len(orders), len(items))
