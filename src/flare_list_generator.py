"""
Solar Flare Data Extraction Script
Author: James Kavanagh-Cranston
Contact: jkavanaghcranston01@qub.ac.uk

Description:
------------
This script provides a function to generate a list of solar flares within a specified 
time range using the SunPy library and the Heliophysics Event Knowledgebase (HEK). 
The result is returned as a pandas DataFrame with detailed information on each solar flare.

Functions:
----------
- generate_flare_list(start_date, end_date): Searches for solar flare events in the HEK 
  database within the specified date range and returns a pandas DataFrame with flare 
  details such as event times, GOES class, coordinates, and the observing instrument.

Requirements:
-------------
- sunpy
- pandas

"""

from sunpy.net import Fido, attrs as a
import pandas as pd

def generate_flare_list(start_date, end_date):
    """
    Generate a list of solar flares within a specified time range using the SunPy library.

    Parameters:
    -----------
    start_date : str
        The start date for the search in the format 'YYYY-MM-DD'.
    end_date : str
        The end date for the search in the format 'YYYY-MM-DD'.

    Returns:
    --------
    pd.DataFrame
        A pandas DataFrame containing details of solar flares detected by the 
        Heliophysics Event Knowledgebase (HEK) during the specified time range.
        The DataFrame includes the following columns:
        - 'event_starttime': The start time of the solar flare.
        - 'event_peaktime': The peak time of the solar flare.
        - 'event_endtime': The end time of the solar flare.
        - 'fl_goescls': The GOES class of the flare, representing its intensity.
        - 'hpc_x': The helioprojective-cartesian X coordinate of the flare.
        - 'hpc_y': The helioprojective-cartesian Y coordinate of the flare.
        - 'obs_instrument': The instrument that observed the flare.

    Example:
    --------
    >>> generate_flare_list('2022-01-01', '2022-01-31')
    """
    # Search for solar flare events within the specified date range using SunPy's Fido client
    hek_result = Fido.search(
        a.Time(start_date, end_date),
        a.hek.EventType('FL')
    )

    # Extract relevant columns from the search result
    flare_list = hek_result[0][
        'event_starttime',
        'event_peaktime',
        'event_endtime',
        'fl_goescls',
        'hpc_x',
        'hpc_y',
        'obs_instrument'
    ]

    # Convert the search result to a pandas DataFrame and return it
    return flare_list.to_pandas()


start_date = '2013-11-08'
end_date = '2013-11-09'

df = generate_flare_list(start_date, end_date)
print(df)