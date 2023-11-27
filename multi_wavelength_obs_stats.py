import pandas as pd
import matplotlib.pyplot as plt
import plotly.express as px
from datetime import date
from upsetplot import UpSet


# Set font to Times New Roman
plt.rcParams['font.family'] = 'Times New Roman'

flare_list_filename = 'instr_observed_flare_list.csv'


###################
# Flare List Prep #
###################


df = pd.read_csv(
    flare_list_filename,
    parse_dates=['FLARE_START', 'FLARE_PEAK', 'FLARE_END']
)
'''
** COL NAMES **

'INDEX'
'FLARE_START'
'FLARE_PEAK'
'FLARE_END'
'CLASS'
'AIA_LOC'
'AIA_XCEN'
'AIA_YCEN'
'LOC'
'NOAA_AR'

'RSI_OBSERVED'
'RSI_FLARE_TRIGGERED'
'RSI_FRAC_OBS'
'RSI_FRAC_OBS_RISE'
'RSI_FRAC_OBS_FALL'

'FERMI_OBSERVED'
'FERMI_FRAC_OBS'
'FERMI_FRAC_OBS_RISE'
'FERMI_FRAC_OBS_FALL'

'MEGSA_OBSERVED'

'MEGSB_OBSERVED'
'MEGSB_FRAC_OBS'
'MEGSB_FRAC_OBS_RISE'
'MEGSB_FRAC_OBS_FALL'

'EIS_OBSERVED'
'EIS_FRAC_OBS'
'EIS_FRAC_OBS_RISE'
'EIS_FRAC_OBS_FALL'

'XRT_OBSERVED'
'XRT_RISE_OBSERVED'
'XRT_FALL_OBSERVED'

'SOT_OBSERVED'
'SOT_RISE_OBSERVED'
'SOT_FALL_OBSERVED'

'IRIS_OBSERVED'
'IRIS_FRAC_OBS'
'IRIS_FRAC_OBS_RISE'
'IRIS_FRAC_OBS_FALL'
'''

# 8 instruments
instrument_names_short = [
    'RSI',
    'FERMI',
    'MEGSA',
    'MEGSB',
    'EIS',
    'XRT',
    'SOT',
    'IRIS'
]

# Removing flares with incorrect flare_start -> flare_peak -> flare_end sequence
for instr in instrument_names_short:
    df = df[df[f"{instr}_OBSERVED"] != 255]

# Adding column to count number of observations made by different instruments.
df['INSTR_OBSERVATIONS'] = df[
    [f"{instr}_OBSERVED" for instr in instrument_names_short]
].sum(axis=1)

# Finding flares observed by all instruments.
fully_obs = df[df['INSTR_OBSERVATIONS'] == 8].reset_index()

fully_obs = fully_obs[
    [
        'INDEX',
        'FLARE_START',
        'FLARE_PEAK',
        'FLARE_END',
        'CLASS'
    ]
]

print(fully_obs)


############################################################################
# Creating a histogram for number of instruments observing a single flare. #
############################################################################


instr_obs_pivot = (
    df
    .groupby('INSTR_OBSERVATIONS')
    .size()
    .reset_index(name='count')
)

print(instr_obs_pivot)

# Plot histogram
instr_obs_pivot['count'].plot(
    kind='bar', edgecolor='black', color='grey', linewidth=1
)

# Customize the plot
plt.title('Multi-Instrument Observations', fontsize=16, fontweight='bold')
plt.xlabel('Number of Instruments Observed', fontsize=14)
plt.ylabel('Count', fontsize=14)
plt.xticks(rotation=0)
plt.yticks(rotation=0)

plt.savefig(
    'stats_out/multi_instr_obs_bar_chart.png',
    dpi=300,
    bbox_inches='tight'
)

plt.show()


#######################
# Instrument Timeline #
#######################


instr_obs_range_info_filename = (
    'instrument_info/instrument_observing_range_info.csv'
)

# Read the CSV into a DataFrame
instr_obs_range_info = pd.read_csv(
    instr_obs_range_info_filename, 
    parse_dates=['range_start', 'range_end'], 
    dayfirst=True
)

instr_obs_range_info['range_end'] = (
    instr_obs_range_info['range_end']
    .fillna(pd.to_datetime(date.today()))
)

fig = px.timeline(instr_obs_range_info.sort_values('range_start'),
                  x_start="range_start",
                  x_end="range_end",
                  y="instrument",
                  color="degraded",
                  color_discrete_map={True: 'red', False: 'green'},
                  labels={'degraded': 'Degraded'}
)

# Find the common time range
common_start = instr_obs_range_info[
    instr_obs_range_info['instrument'] == 'IRIS'
]['range_start'].min()

common_end = instr_obs_range_info[
    instr_obs_range_info['instrument'] == 'MEGSA'
]['range_end'].max()

# Overplot the common time range as a shaded area
fig.add_shape(
    dict(
        type="rect",
        x0=common_start,
        x1=common_end,
        y0=-.5,
        y1=len(instr_obs_range_info['instrument'].unique()),
        fillcolor="lawngreen",
        opacity=0.5,
        layer="above",
        line=dict(width=0),
    )
)

# Overplot the range of time considered in this study
# 2010-04-30  -  SDO first light
# 2019-06-01  -  End of solar cycle 24
fig.add_shape(
    dict(
        type="rect",
        x0=date(2010, 4, 30),
        x1=date(2019, 6, 1),
        y0=-.5,
        y1=len(instr_obs_range_info['instrument'].unique()),
        fillcolor="grey",
        opacity=0.5,
        layer="below",
        line=dict(width=0),
    )
)

# Show the figure
fig.show()


########################################
# Instrument Flare Observation Success #
########################################


# Creating new instrument name list with RSI replaced with RHESSI
instrument_names_full = (
    ['RHESSI' if i == 'RSI' else i for i in instrument_names_short]
)

instr_names_zip = zip(instrument_names_short, instrument_names_full)

for instr_short, instr_full in instr_names_zip:
    
    instr_start = instr_obs_range_info[
        (instr_obs_range_info['instrument'] == instr_full)
    ]['range_start']

    instr_start = instr_start.min()

    instr_end = instr_obs_range_info[
        (instr_obs_range_info['instrument'] == instr_full)
    ]['range_end']
    
    instr_end = instr_end.max()

    observable_flares_df = df[
        (df['FLARE_START'] > instr_start) &
        (df['FLARE_END'] < instr_end)
    ]

    no_observable_flares = len(observable_flares_df)
    no_flares_observed = observable_flares_df[f"{instr_short}_OBSERVED"].sum()
    percent_obs = round(100 * (no_flares_observed/no_observable_flares), 1)

    print()
    print(f"Instrument:         {instr_full}")
    print(f"Launch:             {instr_start}")
    print(f"End:                {instr_end}")
    print(f"Observable Flares:  {no_observable_flares}")
    print(f"Flares Observed:    {no_flares_observed}")
    print(f"% Observed:         {percent_obs}%")

    
##############
# UpSet Plot #
##############


upset_plot_df = df[[f"{instr}_OBSERVED" for instr in instrument_names_short]]
upset_plot_df.columns = instrument_names_full

# Convert the DataFrame to a MultiIndex DataFrame
df_multiindex = pd.MultiIndex.from_frame(upset_plot_df, names=upset_plot_df.columns)
df_multiindex = upset_plot_df.set_index(df_multiindex)

# Create an UpSet object
upset = UpSet(
    df_multiindex,
    min_subset_size=50,
    show_counts=True,
    sort_by='cardinality'
)

# Plot the UpSet plot
upset.plot()
plt.savefig("stats_out/upsetplot_cardinality.png")

# Create an UpSet object
upset = UpSet(
    df_multiindex,
    min_subset_size=50,
    show_counts=True,
    sort_by='degree'
)

# Plot the UpSet plot
upset.plot()
plt.savefig("stats_out/upsetplot_degree.png")

# Create an UpSet object
upset = UpSet(
    df_multiindex,
    show_counts=True,
    sort_by='degree'
)

# Plot the UpSet plot
upset.plot()
plt.savefig("stats_out/upsetplot.png")

plt.show()