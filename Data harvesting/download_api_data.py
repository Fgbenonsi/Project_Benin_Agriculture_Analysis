import requests
import pandas as pd
from sqlalchemy import create_engine

# --- FAOSTAT Credentials ---
USERNAME = "akomavo.gbenonsi@unesp.br"
PASSWORD = "Francklin123456@"

# --- Step 1: Get a fresh token ---
login_url = "https://faostatservices.fao.org/api/v1/auth/login"
login_response = requests.post(login_url, data={"username": USERNAME, "password": PASSWORD})

if login_response.status_code != 200:
    print(f"Login failed: {login_response.status_code}")
    print(login_response.text)
    exit()

auth_data = login_response.json()
access_token = auth_data["AuthenticationResult"]["AccessToken"]
print("Login successful, token obtained.")

# --- Step 2: Set up headers ---
headers = {"Authorization": f"Bearer {access_token}"}

# --- Step 3: Connect to my database ---
engine = create_engine("postgresql+psycopg://fabriceg@localhost:5433/benin_agri")
benin_code = "53"

# --- Step 4: Fetch and load function ---
def fetch_and_load(domain_code, table_name):
    print(f"\nFetching {domain_code} data for Benin...")
    url = f"https://faostatservices.fao.org/api/v1/en/data/{domain_code}"
    params = {"area": benin_code}

    response = requests.get(url, headers=headers, params=params)

    if response.status_code != 200:
        print(f"Failed to fetch {domain_code}: {response.status_code}")
        print(response.text[:500])
        return

    data = response.json()
    data = data.get("data", data)

    df = pd.DataFrame(data)
    df.to_sql(table_name, engine, if_exists="replace", index=False)
    print(f"Wrote {len(df)} rows to '{table_name}'.")

# --- Execute for all four domains ---
fetch_and_load("QCL", "crop_production")   # Crops and Livestock Products
fetch_and_load("RL",  "land_use")          # Land Use
fetch_and_load("RFN", "fertilizer_use")    # Fertilizers by Nutrient
fetch_and_load("RP",  "pesticide_use")     # Pesticides Use

print("\nDone.")