import xarray as xr
import numpy as np
from pprint import pprint
from datetime import datetime

#FLARE SUMMARY___________________________________________________________________________________________ 
flareG16 = xr.open_dataset('sci_xrsf-l2-flsum_g16_d20170906_v2-2-0.nc')
# flareG16.info()

'''
# folder = "downloaded_files/"
# nc_files = [folder + file for file in os.listdir(folder)]

# read_files = [nc.Dataset(fn) for fn in nc_files]

# pprint(read_files[0].variables.keys())

# flare_class = [file.variables['flare_class'][:].tolist() for file in read_files]
# flare_status = [file.variables['status'][:].tolist() for file in read_files]
# flare_times = [file.variables['time'][:].tolist() for file in read_files]
flare_class = flareG16.variables['flare_class'][:].to_dict()
flare_status = flareG16.variables['status'][:].to_dict()
flare_times = flareG16.variables['time'][:].to_dict()

flare_times = np.array(flare_times['data'])
flare_status = np.array(flare_status['data'])

pprint(flare_status)
pprint(flare_times[flare_status == 'EVENT_START'])



flare_status = np.array(flare_status)
# print(flare_status[flare_status == "EVENT_START"])
flare_times = np.array(flare_times)
# print(flare_status)
# print(flare_times)
# print(flare_times[flare_status == "EVENT_START"])

'''



#------------------------

flare_class = flareG16.variables['flare_class'][:]
flare_status = flareG16.variables['status'][:]
flare_times = flareG16.variables['time'][:]

flare_status = np.array(flare_status)
# print(flare_status[flare_status == "EVENT_START"])
flare_times = np.array(flare_times)



flr = zip(flare_status, flare_times)
pprint([f for f in flr])

# pprint(flare_status)
# pprint(flare_times)
# pprint(flare_times[flare_status == "EVENT_START"])