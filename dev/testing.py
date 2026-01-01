from sunpy.net import Fido, attrs as a
from pprint import pprint
import pandas as pd
import json

import numpy as np
from sunpy.time import parse_time
from sunpy.timeseries import TimeSeries
from astropy import units as u
from astropy.time import Time
from matplotlib import pyplot as plt
from datetime import datetime, timedelta

import astropy.io.fits

import src.instruments.alg_tools as at

# flare_start, flare_peak, flare_end = '2013-11-09 06:22', '2013-11-09 06:38', '2013-11-09 06:47'
# flare_start, flare_peak, flare_end = '2010-04-17 04:30', '2010-04-17 05:57', '2010-04-17 08:24'
flare_start, flare_peak, flare_end = '2012-01-27 17:37', '2012-01-27 18:37', '2012-01-27 18:56'

debug = False
verbose = True

# Convert input times to Time objects
flare_start = parse_time(flare_start)
flare_peak = parse_time(flare_peak)
flare_end = parse_time(flare_end)

# Query for Fermi GBM data using Fido
query = Fido.search(
    a.Time(flare_start, flare_end),
    a.Instrument.gbm,
    a.Detector('n1'),
    a.Resolution('cspec')
)

# Print query results
print(query)

# Download the files
result = Fido.fetch(query)

# Print the downloaded file paths
print(result)

class fermi_time_handler:
    def __init__(self, MJDREFI, MJDREFF):
        self.MJDREFI = MJDREFI
        self.MJDREFF = MJDREFF

    def __str__(self):
        return f"MJDREFI: {self.MJDREFI}\nMJDREFF: {self.MJDREFF}"

    def to_datetime(self, MJD_in):
        # Step 1: Calculate reference MJD
        MJDREF = self.MJDREFI + self.MJDREFF  # Full MJD reference

        # Step 2: Convert MJD_in from seconds to days
        MJD_in_days = MJD_in / (86400)  # 86400 seconds in a day

        # Step 3: Calculate the MJD corresponding to MJD_in
        MJD = MJDREF + MJD_in_days

        # Step 4: Convert MJD to datetime
        return Time(MJD, format='mjd').datetime

# Open the RHESSI FITS file using astropy.io.fits
with astropy.io.fits.open(result[0]) as hdulist:
    fermi_time = fermi_time_handler(hdulist['GTI'].header['MJDREFI'], hdulist['GTI'].header['MJDREFF'])
    valid_times = pd.DataFrame(hdulist['GTI'].data)

valid_times[["START", "STOP"]] = valid_times[["START", "STOP"]].apply(fermi_time.to_datetime)
valid_times = valid_times[(valid_times['START'] < flare_end.iso) & (valid_times['STOP'] > flare_start.iso)]


df = TimeSeries(result[0]).to_dataframe()

plt.plot(df.index, df['4-15 keV'])
plt.yscale('log')

# Shade the time ranges
for _, row in valid_times.iterrows():
    plt.axvspan(row['START'], row['STOP'], color='orange', alpha=0.5)

plt.show()