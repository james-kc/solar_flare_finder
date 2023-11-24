import pandas as pd
import matplotlib.pyplot as plt


# Set font to Times New Roman
plt.rcParams['font.family'] = 'Times New Roman'

flare_list_filename = 'instr_observed_flare_list.csv'

df = pd.read_csv(flare_list_filename)
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
instrument_names = [
    'RSI',
    'FERMI',
    'MEGSA',
    'MEGSB',
    'EIS',
    'XRT',
    'SOT',
    'IRIS'
]

# Adding column to count number of observations made by different instruments.
df['INSTR_OBSERVATIONS'] = df[
    [f"{instr}_OBSERVED" for instr in instrument_names]
].sum(axis=1)

# Finding flares observed by all instruments.
fully_obs = df[df['INSTR_OBSERVATIONS'] == 8]

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


# instr_obs_pivot = (
#     df
#     .groupby('INSTR_OBSERVATIONS')
#     .size()
#     .reset_index(name='count')
# )

# instr_obs_pivot = instr_obs_pivot[instr_obs_pivot['INSTR_OBSERVATIONS'] <= 8]

# # Plot histogram
# instr_obs_pivot['count'].plot(
#     kind='bar', edgecolor='black', color='grey', linewidth=1
# )

# # Customize the plot
# plt.title('Multi-Instrument Observations', fontsize=16, fontweight='bold')
# plt.xlabel('Number of Instruments Observed', fontsize=14)
# plt.ylabel('Count', fontsize=14)
# plt.xticks(rotation=0)
# plt.yticks(rotation=0)

# plt.savefig(
#     'stats_out/multi_instr_obs_bar_chart.png',
#     dpi=300,
#     bbox_inches='tight'
# )

# plt.show()


#######################
# Instrument Timeline #
#######################


import plotly.express as px
from datetime import date

instr_info_filename = 'instrument_info/instrument_info.csv'

# Read the CSV into a DataFrame
instr_info = pd.read_csv(
    instr_info_filename, 
    parse_dates=['first_light', 'degraded', 'retired'], 
    dayfirst=True
)

instr_info['retired'] = instr_info['retired'].fillna(pd.to_datetime(date.today()))

# Determine the color based on the degraded time
instr_info['color'] = instr_info.apply(lambda row: 'red' if not pd.isna(row['degraded']) and row['degraded'] < pd.to_datetime(date.today()) else 'tan', axis=1)

fig = px.timeline(instr_info.sort_values('first_light'),
                  x_start="first_light",
                  x_end="retired",
                  y="instrument",
                  text="instrument",
                  color="color",
                  color_discrete_map={'tan': 'tan', 'red': 'red'})
fig.show()

# fig = px.timeline(instr_info.sort_values('first_light'),
#                   x_start="first_light",
#                   x_end="retired",
#                   y="instrument",
#                   text="instrument",
#                   color_discrete_sequence=["tan"])
# fig.show()
