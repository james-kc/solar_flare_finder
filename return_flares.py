import pandas as pd

fl_filename = 'instr_observed_flare_list.csv'
flare_list = pd.read_csv(fl_filename)
flare_list['FLARE_PEAK'] = pd.to_datetime(flare_list['FLARE_PEAK'], format='mixed')

flare_search_filename = 'goes_data_reflist.csv'
flares_to_search = pd.read_csv(flare_search_filename)
flares_to_search['FLARE_PEAK'] = pd.to_datetime(flares_to_search['gpeak'], format='mixed')

# out = flare_list[flare_list['FLARE_PEAK'].isin(flares_to_search['gpeak'])]

out = pd.merge(flare_list, flares_to_search, on='FLARE_PEAK', how='inner')

print(out)
out.to_csv('filtered_flare_list.csv', index=False)

