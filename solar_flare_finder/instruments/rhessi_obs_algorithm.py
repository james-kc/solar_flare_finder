"""
RHESSI Solar Flare Observation Algorithm
Author: James Kavanagh-Cranston
Contact: jkavanaghcranston01@qub.ac.uk

Description:
------------
This script processes RHESSI (Ramaty High Energy Solar Spectroscopic Imager) data 
to analyze solar flare events within a specified time range. It queries the RHESSI data, 
analyzes countrate information, and checks observational flags to determine whether RHESSI 
was able to observe the flare, providing statistics on flare observation and triggered flags.

The core function, `rhessi_algorithm`, handles time conversions, querying data, and 
computing observational statistics. Debugging and verbose modes are available for more 
in-depth analysis and visualization of flare events.

Functions:
----------
- rhessi_algorithm(flare_start, flare_peak, flare_end, debug=False, verbose=False):
  Queries RHESSI data for the specified flare time range and computes statistics 
  such as whether RHESSI observed the flare, the fraction of time it was observable, 
  and triggered flags. Returns a dictionary of these metrics.

Requirements:
-------------
- sunpy
- pandas
- astropy
- matplotlib
- numpy
"""

import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
from sunpy.net import Fido, attrs as a
from sunpy.timeseries import TimeSeries
from sunpy.time import parse_time
from astropy import units as u
import astropy.io.fits


def rhessi_algorithm(flare_start, flare_peak, flare_end, debug=False, verbose=False):
    """
    Processes RHESSI (Ramaty High Energy Solar Spectroscopic Imager) data to check
    flare observations within a given time range and calculate observation statistics.

    Parameters
    ----------
    flare_start : str or `~sunpy.time.parse_time` compatible
        The start time of the solar flare event in any format supported by `sunpy.time.parse_time`.

    flare_peak : str or `~sunpy.time.parse_time` compatible
        The peak time of the solar flare event in any format supported by `sunpy.time.parse_time`.

    flare_end : str or `~sunpy.time.parse_time` compatible
        The end time of the solar flare event in any format supported by `sunpy.time.parse_time`.

    debug : bool, optional
        If True, generates debugging plots, including time series plots of the countrate data
        and flag information during the flare (default is False).

    verbose : bool, optional
        If True, prints detailed information about the flare times and element calculations
        during processing (default is False).

    Returns
    -------
    dict
        A dictionary containing the following keys:

        - 'rsi_observed' (int): 1 if RHESSI observed the flare, 0 otherwise.
        - 'rsi_flare_triggered' (int): 1 if RHESSI flare flags were triggered, 0 otherwise.
        - 'rsi_frac_obs' (float): Fraction of time RHESSI was able to observe the flare.
        - 'rsi_frac_obs_rise' (float): Fraction of time RHESSI was observing during the flare's rise phase.
        - 'rsi_frac_obs_fall' (float): Fraction of time RHESSI was observing during the flare's fall phase.

    Notes
    -----
    - This function uses `sunpy.net.Fido` to query RHESSI data within the provided time range
      and uses the queried data to check if RHESSI observed the flare.
    - It checks if RHESSI's eclipse & south atlantic anomoly flags are not set during the flare and uses this
      information to compute the observation statistics.
    - If the input times are malformed (i.e., `flare_start >= flare_peak >= flare_end`), the function
      will return a dictionary with default values of -1 or 0.

    Examples
    --------
    Basic usage example:

    >>> rhessi_algorithm('2013-11-09 06:22', '2013-11-09 06:38', '2013-11-09 06:47')
    {'rsi_observed': 1, 'rsi_flare_triggered': 1, 'rsi_frac_obs': 0.95,
     'rsi_frac_obs_rise': 0.9, 'rsi_frac_obs_fall': 0.98}

    Debugging and verbose example:

    >>> rhessi_algorithm('2010-05-04 05:50', '2010-05-04 06:46', '2010-05-04 08:15', debug=True, verbose=True)
    """

    # Convert input times to Time objects
    flare_start = parse_time(flare_start)
    flare_peak = parse_time(flare_peak)
    flare_end = parse_time(flare_end)

    # Handling case where flare_start equals flare_peak
    if flare_start == flare_peak:
        flare_start -= 60 * u.s  # Subtract 1 min from flare_start

    # Handling case where flare_peak equals flare_end
    if flare_peak == flare_end:
        flare_end += 60 * u.s  # Add 1 min to flare_end

    # Handling malformed time sequence
    if not (flare_start < flare_peak < flare_end):
        out = {
            "rsi_observed": -1,
            "rsi_flare_triggered": -1,
            "rsi_frac_obs": -1.0,
            "rsi_frac_obs_rise": -1.0,
            "rsi_frac_obs_fall": -1.0,
        }

    # Create time range
    time_range = [flare_start.iso, flare_end.iso]

    # Query RHESSI data for the given time range
    query = Fido.search(a.Time(time_range[0], time_range[1]), a.Instrument.rhessi)
    if not query:
        out = {
            "rsi_observed": 0,
            "rsi_flare_triggered": 0,
            "rsi_frac_obs": 0.0,
            "rsi_frac_obs_rise": 0.0,
            "rsi_frac_obs_fall": 0.0,
        }

    result = Fido.fetch(query)

    countrate_data = TimeSeries(result[0]).to_dataframe()

    # Open the RHESSI FITS file using astropy.io.fits
    with astropy.io.fits.open(result[0]) as hdulist:
        # Pulling relevant flag info from fits file
        flag_info = hdulist["HSI_OBSSUMMFLAGINFO"].data
        flag_names = np.array([s.strip().lower() for s in flag_info["FLAG_IDS"][0]])
        flag_data = hdulist["HSI_OBSSUMMFLAGDATA"].data["flags"]

    # Creating and formatting a flag dataframe
    flag_df = pd.DataFrame(flag_data, columns=flag_names)
    flag_df["datetime"] = countrate_data.index
    flag_df = flag_df[
        [  # Pulling relevant flag columns
            "datetime",
            "saa_flag",
            "eclipse_flag",
            "flare_flag",
        ]
    ]
    # Get flag columns except 'datetime'
    flag_columns = flag_df.columns.difference(["datetime"])
    flag_df[flag_columns] = flag_df[flag_columns].astype(bool)
    flag_df["observable"] = ~(flag_df["saa_flag"] | flag_df["eclipse_flag"])

    countrate_data = countrate_data[
        (countrate_data.index > time_range[0]) & (countrate_data.index < time_range[1])
    ]
    flags_during_flare = flag_df[
        (flag_df["datetime"] > time_range[0]) & (flag_df["datetime"] < time_range[1])
    ].reset_index()

    # Check if RHESSI observed during flare
    rsi_observed = np.any(countrate_data != 0)

    # Plots for debugging
    if debug:
        TimeSeries(result).plot()

    if rsi_observed:
        # Assume flags are represented in the data (e.g. "FLARE_FLAG", "ECLIPSE_FLAG")
        flare_flag = np.array(flags_during_flare["flare_flag"])
        observable_flag = np.array(flags_during_flare["observable"])

        # Plots for debugging flags
        if debug:
            plt.plot(observable_flag)
            plt.ylim([-0.1, 1.1])
            plt.show()

            plt.plot(
                countrate_data.index, countrate_data["3 - 6 keV"], label=["3 - 6 keV"]
            )
            # plt.plot(countrate_data.index, countrate_data, label=countrate_data.columns)
            plt.legend()
            plt.show()

        # Calculate statistics
        total_elements = len(observable_flag)
        elements_to_flare_peak = (
            (flags_during_flare["datetime"] - pd.to_datetime(flare_peak.iso))
            .abs()
            .idxmin()
        )

        if verbose:
            print(f"Flare Start: {flare_start}")
            print(f"Flare Peak: {flare_peak}")
            print(f"Flare End: {flare_end}")
            print(f"Elements to flare peak: {elements_to_flare_peak}")
            print(f"Total Number of Elements: {total_elements}")

        rsi_flare_triggered = np.any(flare_flag != 0)
        rsi_frac_obs = np.sum(observable_flag) / total_elements
        rsi_frac_obs_rise = (
            np.sum(observable_flag[:elements_to_flare_peak]) / elements_to_flare_peak
        )
        rsi_frac_obs_fall = np.sum(observable_flag[elements_to_flare_peak:]) / (
            total_elements - elements_to_flare_peak
        )

    else:
        rsi_flare_triggered = 0
        rsi_frac_obs = 0.0
        rsi_frac_obs_rise = 0.0
        rsi_frac_obs_fall = 0.0

    return {
        "rsi_observed": bool(rsi_observed),
        "rsi_flare_triggered": bool(rsi_flare_triggered),
        "rsi_frac_obs": float(rsi_frac_obs),
        "rsi_frac_obs_rise": float(rsi_frac_obs_rise),
        "rsi_frac_obs_fall": float(rsi_frac_obs_fall),
    }


if __name__ == "__main__":
    print(rhessi_algorithm("2013-11-09 06:22", "2013-11-09 06:38", "2013-11-09 06:47"))
    print(rhessi_algorithm("2010-05-04 05:50", "2010-05-04 06:46", "2010-05-04 08:15"))
