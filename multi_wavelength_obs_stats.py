from datetime import date
import pandas as pd
import matplotlib.pyplot as plt
import plotly.express as px
from upsetplot import UpSet
import numpy as np


# Set font to Times New Roman
plt.rcParams['font.family'] = 'Times New Roman'

FLARE_LIST_FILENAME = 'instr_observed_flare_list.csv'


###################
# Flare List Prep #
###################


df = pd.read_csv(
    FLARE_LIST_FILENAME,
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
    'MEGSA',
    'MEGSB',
    'EIS',
    'SOT',
    'XRT',
    'IRIS',
    'FERMI'
]

# Removing flares with incorrect flare_start -> flare_peak -> flare_end sequence
for instr in instrument_names_short:
    df = df[df[f"{instr}_OBSERVED"] != 255]

# Removing flares with no coordinates (0,0)

no_coords = df[
    (df['AIA_XCEN'] == 0) &
    (df['AIA_YCEN'] == 0)
]

print(f"Number of flares with no coordinates: {len(no_coords)}")

df = df[
    (df['AIA_XCEN'] != 0) &
    (df['AIA_YCEN'] != 0)
]

# Removing stray A-class flares

df = df[
    ~df['CLASS'].str.contains('A')
]

# Adding column to count number of observations made by different instruments.
df['INSTR_OBSERVATIONS'] = df[
    [f"{instr}_OBSERVED" for instr in instrument_names_short]
].sum(axis=1)

df['CLASS_LETTER'] = df['CLASS'].apply(lambda x: x[0])

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

# Finding flares that occurred during the lifetimes of all instruments
# 17/07/2013 -> 27/05/2014

all_instr_flares = df[
    (df['FLARE_START'] > '17/07/2013') &
    (df['FLARE_END'] < '27/05/2014')
]

print()
print(f"Number of flares within all 8 instr's lifetime: {len(all_instr_flares)}")
print(f"Total number of flares: {len(df)}\n")


###################
# Numerical Stats #
###################


# % flares observed
flares_observed = len(df[df['INSTR_OBSERVATIONS'] != 0])
observation_percentage = 100 * (flares_observed / len(df))

print(
    f"% of flares observed by at least 1 instrument: \
        {round(observation_percentage, 1)}%"
)

#####################
# The Average Flare #
#####################


df['flare_durations'] = df['FLARE_END'] - df['FLARE_START']
df['flare_durations_mins_int'] = df['flare_durations'] / pd.Timedelta(minutes=1)

df.boxplot('flare_durations_mins_int', by='CLASS_LETTER', sym ='')

plt.title('')
plt.suptitle('')
plt.xlabel('GOES Class', fontsize=20)
plt.ylabel('Flare Duration (Minutes)', fontsize=20)
plt.xticks(fontsize=13)
plt.yticks(fontsize=13)
plt.grid(axis='x')
plt.ylim(bottom=0)

plt.savefig(
    'stats_out/the_average_flare.png',
    dpi=300,
    bbox_inches='tight'
)
plt.show()

avg_flare_duration = df['flare_durations'].mean()

print(f"Average Flare Duration: {avg_flare_duration}")


############################################################################
# Creating a bar chart for number of instruments observing a single flare. #
############################################################################

# Entire time range
instr_obs_pivot = (
    df
    .groupby('INSTR_OBSERVATIONS')
    .size()
    .reset_index(name='count')
)

print(instr_obs_pivot)

# Plot histogram
ax = instr_obs_pivot['count'].plot(
    kind='bar', edgecolor='black', color='grey', linewidth=1
)

for container in ax.containers:
    ax.bar_label(container, fontsize=13)

# Customize the plot
# plt.title('Multi-Instrument Observations', fontsize=16, fontweight='bold')
plt.xlabel('Number of Instruments Observed', fontsize=20)
plt.ylabel('Count', fontsize=20)
plt.xticks(rotation=0, fontsize=13)
plt.yticks(rotation=0, fontsize=13)

plt.savefig(
    'stats_out/multi_instr_obs_bar_chart.png',
    dpi=300,
    bbox_inches='tight'
)

plt.show()

# Common time range
instr_obs_pivot = (
    all_instr_flares
    .groupby('INSTR_OBSERVATIONS')
    .size()
    .reset_index(name='count')
)

print(instr_obs_pivot)

# Plot histogram
ax = instr_obs_pivot['count'].plot(
    kind='bar', edgecolor='black', color='grey', linewidth=1
)

for container in ax.containers:
    ax.bar_label(container, fontsize=13)

# Customize the plot
# plt.title('Multi-Instrument Observations', fontsize=16, fontweight='bold')
plt.xlabel('Number of Instruments Observed', fontsize=20)
plt.ylabel('Count', fontsize=20)
plt.xticks(rotation=0, fontsize=13)
plt.yticks(rotation=0, fontsize=13)

plt.savefig(
    'stats_out/multi_instr_obs_bar_chart_common_time_range.png',
    dpi=300,
    bbox_inches='tight'
)

plt.show()


#######################
# Instrument Timeline #
#######################


INSTR_OBS_RANGE_INFO_FILENAME = (
    'instrument_info/instrument_observing_range_info.csv'
)

# Read the CSV into a DataFrame
instr_obs_range_info = pd.read_csv(
    INSTR_OBS_RANGE_INFO_FILENAME,
    parse_dates=['range_start', 'range_end'],
    dayfirst=True
)

instr_obs_range_info['range_end'] = (
    instr_obs_range_info['range_end']
    .fillna(pd.to_datetime(date.today()))
)

# fig = px.timeline(instr_obs_range_info.sort_values('range_start'),
#                   x_start="range_start",
#                   x_end="range_end",
#                   y="instrument",
#                   color="degraded",
#                   color_discrete_map={True: 'red', False: 'green'},
#                   labels={'degraded': 'Degraded'}
# )

# # Find the common time range
# common_start = instr_obs_range_info[
#     instr_obs_range_info['instrument'] == 'IRIS'
# ]['range_start'].min()

# common_end = instr_obs_range_info[
#     instr_obs_range_info['instrument'] == 'MEGSA'
# ]['range_end'].max()

# # Overplot the common time range as a shaded area
# fig.add_shape(
#     dict(
#         type="rect",
#         x0=common_start,
#         x1=common_end,
#         y0=-.5,
#         y1=len(instr_obs_range_info['instrument'].unique()),
#         fillcolor="lawngreen",
#         opacity=0.5,
#         layer="above",
#         line=dict(width=0),
#     )
# )

# # Overplot the range of time considered in this study
# # 2010-04-30  -  SDO first light
# # 2019-06-01  -  End of solar cycle 24
# fig.add_shape(
#     dict(
#         type="rect",
#         x0=date(2010, 4, 30),
#         x1=date(2019, 6, 1),
#         y0=-.5,
#         y1=len(instr_obs_range_info['instrument'].unique()),
#         fillcolor="grey",
#         opacity=0.5,
#         layer="below",
#         line=dict(width=0),
#     )
# )

# # Show the figure
# fig.show()


########################################
# Instrument Flare Observation Success #
########################################


# Creating new instrument name list with RSI replaced with RHESSI
instrument_names_full = (
    ['RHESSI' if i == 'RSI' else i for i in instrument_names_short]
)

expected_success_rates = [
    '50%',
    '100%',
    '12.5%',
    '0.5-6%',
    '0.5-8%',
    '25-100%',
    '0.5-3%',
    '50%'
]

success_rate_table = pd.DataFrame(
    {
        'instrument': instrument_names_full,
        'expected_success_rates': expected_success_rates
    }
)

instr_names_zip = zip(instrument_names_short, instrument_names_full)

percent_obs_col = []
lifetime_observable_flares_col = []
lifetime_observed_flares_col = []

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

    percent_obs_col.append(percent_obs)
    lifetime_observable_flares_col.append(no_observable_flares)
    lifetime_observed_flares_col.append(no_flares_observed)

    print()
    print(f"Instrument:         {instr_full}")
    print(f"Launch:             {instr_start}")
    print(f"End:                {instr_end}")
    print(f"Observable Flares:  {no_observable_flares}")
    print(f"Flares Observed:    {no_flares_observed}")
    print(f"% Observed:         {percent_obs}%")


success_rate_table['lifetime_observable_flares'] = lifetime_observable_flares_col
success_rate_table['lifetime_observed_flares'] = lifetime_observed_flares_col
success_rate_table['%_observed_9yr'] = percent_obs_col


######################################################
# Instrument Success Rate Over Identical Time Period #
######################################################


# Creating new instrument name list with RSI replaced with RHESSI
instrument_names_full = (
    ['RHESSI' if i == 'RSI' else i for i in instrument_names_short]
)

instr_names_zip = zip(instrument_names_short, instrument_names_full)

print()

percent_obs_any_frac_col = []
percent_obs_half_frac_col = []

no_observable_flares = len(all_instr_flares)

for instr_short, instr_full in instr_names_zip:

    instr_start = instr_obs_range_info[
        (instr_obs_range_info['instrument'] == instr_full)
    ]['range_start']

    instr_start = instr_start.min()

    instr_end = instr_obs_range_info[
        (instr_obs_range_info['instrument'] == instr_full)
    ]['range_end']

    instr_end = instr_end.max()


    # Two definitions for an "observed" flare (comment out definition not in
    # use):

    # obs_frac > 0 = observation
    no_flares_observed_any_frac = all_instr_flares[f"{instr_short}_OBSERVED"].sum()

    # obs_frac > 0.5 = observation
    if instr_short not in ('MEGSA', 'XRT', 'SOT'):

        frac_obs = (
            all_instr_flares[f"{instr_short}_FRAC_OBS_RISE"] +
            all_instr_flares[f"{instr_short}_FRAC_OBS_FALL"]
        ) / 2

        no_flares_observed_half_frac = len(
            frac_obs[frac_obs > 0.5]
        )

    else:
        # For MEGS-A, XRT and SOT, no "{instr_short}_FRAC_OBS_RISE" exits,
        # therefore we just use the "{instr_short}_OBSERVED" Boolean.
        no_flares_observed_half_frac = all_instr_flares[f"{instr_short}_OBSERVED"].sum()

    percent_obs_any_frac = round(100 * (no_flares_observed_any_frac/no_observable_flares), 1)
    percent_obs_half_frac = round(100 * (no_flares_observed_half_frac/no_observable_flares), 1)

    percent_obs_any_frac_col.append(percent_obs_any_frac)
    percent_obs_half_frac_col.append(percent_obs_half_frac)

success_rate_table['%_observed_any_frac_11mo'] = percent_obs_any_frac_col
success_rate_table['%_observed_half_frac_11mo'] = percent_obs_half_frac_col

print(success_rate_table)

success_rate_table.to_csv('stats_out/success_rate_table.csv', index=False)

##############
# UpSet Plot #
##############


## Upset plots for all flares. ##


# upset_plot_df = df[[f"{instr}_OBSERVED" for instr in instrument_names_short]]
# upset_plot_df.columns = instrument_names_full

# # Convert the DataFrame to a MultiIndex DataFrame
# df_multiindex = pd.MultiIndex.from_frame(upset_plot_df, names=upset_plot_df.columns)
# df_multiindex = upset_plot_df.set_index(df_multiindex)

# # Create an UpSet object
# upset = UpSet(
#     df_multiindex,
#     min_subset_size=200,
#     show_counts=True,
#     sort_by='cardinality',
#     with_lines=False
# )

# # Plot the UpSet plot
# upset.plot()

# plt.savefig(
#     "stats_out/upsetplot_cardinality.png",
#     dpi=300,
#     bbox_inches='tight'
# )


# # Create an UpSet object

# upset = UpSet(
#     df_multiindex,
#     min_subset_size=50,
#     show_counts=True,
#     sort_by='degree',
#     with_lines=False
# )

# # Plot the UpSet plot
# upset.plot()
# plt.savefig("stats_out/upsetplot_degree.png")

# # Create an UpSet object
# upset = UpSet(
#     df_multiindex,
#     show_counts=True,
#     sort_by='degree',
#     with_lines=False
# )

# # Plot the UpSet plot
# upset.plot()

# plt.savefig(
#     "stats_out/upsetplot.png",
#     dpi=300,
#     bbox_inches='tight'
# )



# ## Upset plots for flares with >= 7 instruments observing. ##


# seven_obs = df[df['INSTR_OBSERVATIONS'] >= 7].reset_index(drop=True)

# upset_plot_df = seven_obs[[f"{instr}_OBSERVED" for instr in instrument_names_short]]
# upset_plot_df.columns = instrument_names_full

# # Convert the DataFrame to a MultiIndex DataFrame
# df_multiindex = pd.MultiIndex.from_frame(upset_plot_df, names=upset_plot_df.columns)
# df_multiindex = upset_plot_df.set_index(df_multiindex)

# # Create an UpSet object
# upset = UpSet(
#     df_multiindex,
#     show_counts=True,
#     sort_by='cardinality',
#     with_lines=False
# )

# # Plot the UpSet plot
# upset.plot()

# plt.savefig(
#     "stats_out/upsetplot_7+_cardinality.png",
#     dpi=300,
#     bbox_inches='tight'
# )

# plt.show()


######################################
# Class Distribution of Solar Flares #
######################################


def flare_class_pivot(single_instr_df, instr_name):

    class_pivot = (
        single_instr_df
        .groupby('CLASS_LETTER')
        .size()
        .reset_index(name='count')
    )

    print()
    print(f"Instrument: {instr_name}")
    print(class_pivot)

    class_pivot = (
        single_instr_df
        .groupby('CLASS_LETTER')
        .size()
    )

    # Plot histogram
    class_pivot.plot(
        kind='bar', edgecolor='black', color='grey', linewidth=1
    )

    # Customize the plot
    plt.title(f"{instr_name} Observed Flares", fontsize=16, fontweight='bold')
    plt.xlabel('Flare Class', fontsize=14)
    plt.ylabel('Count', fontsize=14)
    plt.xticks(rotation=0)
    plt.yticks(rotation=0)

    plt.savefig(
        f"stats_out/{instr_name}_flare_classes.png",
        dpi=300,
        bbox_inches='tight'
    )

    plt.show()

# Creating new instrument name list with RSI replaced with RHESSI
instrument_names_full = (
    ['RHESSI' if i == 'RSI' else i for i in instrument_names_short]
)

instr_names_zip = zip(instrument_names_short, instrument_names_full)

# Distribution for all instruments
# flare_class_pivot(df, 'All')

# Distributions for individual instruments
# for instr_short, instr_full in instr_names_zip:
#     flare_class_pivot(df[df[f"{instr_short}_OBSERVED"] == 1], instr_full)

