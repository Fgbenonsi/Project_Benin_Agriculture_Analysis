import os
from biotrade.faostat import faostat

os.environ["BIOTRADE_DATABASE_URL"] = "postgresql://Benin_vegetables@localhost::5433/benin_agri"


print(faostat.pump.datasets)

faostat.pump.update(["crop_production"])
faostat.pump.update(["land_use"])

print("Download complete")