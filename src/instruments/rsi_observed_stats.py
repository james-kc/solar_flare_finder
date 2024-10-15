import numpy as np
from sunpy.time import parse_time
from sunpy.net import Fido, attrs as a
from sunpy.timeseries import TimeSeries
from astropy import units as u
from matplotlib import pyplot as plt

def rsi_observed_stats(flare_start, flare_peak, flare_end, debug=False, verbose=False):
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
        return {
            "rsi_observed": -1,
            "rsi_flare_triggered": -1,
            "rsi_frac_obs": -1.0,
            "rsi_frac_obs_rise": -1.0,
            "rsi_frac_obs_fall": -1.0
        }

    # Create time range
    time_range = [flare_start.iso, flare_end.iso]
    that_day = [flare_start.strftime('%Y-%m-%d'), flare_end.strftime('%Y-%m-%d') + " 23:59:59"]

    # Query RHESSI data for the given time range
    query = Fido.search(a.Time(time_range[0], time_range[1]), a.Instrument.rhessi)
    if not query:
        return {
            "rsi_observed": 0,
            "rsi_flare_triggered": 0,
            "rsi_frac_obs": 0.0,
            "rsi_frac_obs_rise": 0.0,
            "rsi_frac_obs_fall": 0.0
        }

    result = Fido.fetch(query)
    print(result)
    hsi_data = TimeSeries(result).data['countrate']
    
    # Check if RHESSI observed during flare
    rsi_observed = np.any(hsi_data != 0)

    # Plots for debugging
    if debug:
        TimeSeries(result).plot()

    if rsi_observed:
        # Assume flags are represented in the data (e.g. "FLARE_FLAG", "ECLIPSE_FLAG")
        flare_flag = np.array(hsi_data['flare_flag'])
        saa_flag = np.array(hsi_data['saa_flag'])
        eclipse_flag = np.array(hsi_data['eclipse_flag'])
        observed_flag = ~(saa_flag | eclipse_flag)

        # Plots for debugging flags
        if debug:
            plt.plot(observed_flag)
            plt.ylim([-0.1, 1.1])
            plt.show()

        # Calculate statistics
        total_elements = len(observed_flag)
        elements_to_flare_peak = int((flare_peak - flare_start).to(u.s).value / hsi_data.time_intv)

        if verbose:
            print(f"Flare Start: {flare_start}")
            print(f"Flare Peak: {flare_peak}")
            print(f"Flare End: {flare_end}")
            print(f"Elements to flare peak: {elements_to_flare_peak}")
            print(f"Total Number of Elements: {total_elements}")

        rsi_flare_triggered = np.any(flare_flag != 0)
        rsi_frac_obs = np.sum(observed_flag) / total_elements
        rsi_frac_obs_rise = np.sum(observed_flag[:elements_to_flare_peak]) / elements_to_flare_peak
        rsi_frac_obs_fall = np.sum(observed_flag[elements_to_flare_peak:]) / (total_elements - elements_to_flare_peak)

    else:
        rsi_flare_triggered = 0
        rsi_frac_obs = 0.0
        rsi_frac_obs_rise = 0.0
        rsi_frac_obs_fall = 0.0

    return {
        "rsi_observed": int(rsi_observed),
        "rsi_flare_triggered": int(rsi_flare_triggered),
        "rsi_frac_obs": rsi_frac_obs,
        "rsi_frac_obs_rise": rsi_frac_obs_rise,
        "rsi_frac_obs_fall": rsi_frac_obs_fall
    }

out = rsi_observed_stats('2013-11-09 06:22', '2013-11-09 06:38', '2013-11-09 06:47')

print(out)
